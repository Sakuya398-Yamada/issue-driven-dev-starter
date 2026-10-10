#!/usr/bin/env bash
# Regression tests for the guardrail scripts shipped in both templates.
#
#   tests/test-hooks.sh            # run everything
#
# Covers:
#   - template/.claude/hooks/validate-commit-message.sh  (Claude Code PreToolUse hook)
#   - template/.claude/hooks/validate-branch-name.sh     (Claude Code PreToolUse hook)
#   - template/.claude/hooks/session-start-info.sh       (smoke test + template update check)
#   - template-copilot/.githooks/commit-msg              (git commit-msg hook)
#   - template-copilot/.githooks/pre-push                (git pre-push hook)
#   - template-copilot/.github/hooks/*.sh                (Copilot preToolUse hooks; same scripts as Claude's)
#   - the branch / commit regexes being identical in every place they are duplicated
#
# Requires: bash, git, jq. (node / python3 are only needed for the parser-fallback cases
# and those cases are skipped when the interpreter is not installed.)

set -uo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
CLAUDE_COMMIT="$ROOT/template/.claude/hooks/validate-commit-message.sh"
CLAUDE_BRANCH="$ROOT/template/.claude/hooks/validate-branch-name.sh"
CLAUDE_SESSION="$ROOT/template/.claude/hooks/session-start-info.sh"
COPILOT_COMMIT="$ROOT/template-copilot/.githooks/commit-msg"
COPILOT_PUSH="$ROOT/template-copilot/.githooks/pre-push"
COPILOT_CI="$ROOT/template-copilot/.github/workflows/validate-conventions.yml"

pass=0
fail=0
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

ok()   { pass=$((pass + 1)); printf 'PASS  %s\n' "$1"; }
bad()  { fail=$((fail + 1)); printf 'FAIL  %s\n%s\n' "$1" "${2:-}"; }
show() { printf '%s' "$1" | head -c 110 | tr '\n' '⏎'; }

# --- helpers --------------------------------------------------------------

# Run a Claude PreToolUse hook with a Bash command and assert the exit code.
# claude_case <hook> <expected-rc> <command> [branch]
claude_case() {
  local hook="$1" want="$2" cmd="$3" branch="${4:-feature/#1-fixture}"
  local repo="$TMP/claude-${branch//\//_}"
  if [[ ! -d "$repo" ]]; then
    git init -q -b "$branch" "$repo"
    git -C "$repo" -c user.name=t -c user.email=t@example.com commit -q --allow-empty -m "chore: fixture #1"
  fi
  local json out rc
  json=$(jq -cn --arg c "$cmd" '{tool_name:"Bash", tool_input:{command:$c}}')
  out=$(printf '%s' "$json" | CLAUDE_PROJECT_DIR="$repo" bash "$hook" 2>&1)
  rc=$?
  if [[ "$rc" == "$want" ]]; then ok "rc=$rc  $(show "$cmd")"; else bad "rc=$rc want=$want  $(show "$cmd")" "$out"; fi
}

# copilot_commit_case <expected-rc> <branch> <message>
copilot_commit_case() {
  local want="$1" branch="$2" msg="$3"
  local repo="$TMP/copilot-${branch//\//_}"
  if [[ ! -d "$repo" ]]; then git init -q -b "$branch" "$repo"; fi
  printf '%s\n' "$msg" >"$repo/MSG"
  local out rc
  out=$(cd "$repo" && bash "$COPILOT_COMMIT" MSG 2>&1)
  rc=$?
  if [[ "$rc" == "$want" ]]; then ok "rc=$rc  [$branch] $(show "$msg")"; else bad "rc=$rc want=$want  [$branch] $(show "$msg")" "$out"; fi
}

# copilot_push_case <expected-rc> <remote-ref>
copilot_push_case() {
  local want="$1" ref="$2" out rc
  out=$(printf '%s %s %s %s\n' "$ref" 0000 "$ref" 0000 | bash "$COPILOT_PUSH" 2>&1)
  rc=$?
  if [[ "$rc" == "$want" ]]; then ok "rc=$rc  push $ref"; else bad "rc=$rc want=$want  push $ref" "$out"; fi
}

# --- Claude: commit message ------------------------------------------------
echo "## Claude PreToolUse hook: validate-commit-message.sh (issue number required on feature/*)"
C=$CLAUDE_COMMIT
claude_case "$C" 0 'git commit -m "feat: add thing #1"'
claude_case "$C" 0 'git commit -m "feat(api): add thing #1"'
claude_case "$C" 0 'git commit -m "feat!: breaking #1"'
claude_case "$C" 0 'git commit -m "fix(ui)!: breaking #1"'
claude_case "$C" 0 'git commit -sm "chore: signed #1"'
claude_case "$C" 0 $'git commit -m "$(cat <<\'EOF\'\nfeat: heredoc ok #2\n\nbody\nEOF\n)"'
claude_case "$C" 0 $'git commit -m "$(cat <<\'MSG\'\nfeat: other delimiter #3\nMSG\n)"'
claude_case "$C" 0 $'git commit -m "$(cat <<EOF\n\nfeat: blank line first #4\nEOF\n)"'
claude_case "$C" 0 $'git commit -F - <<\'EOF\'\nfeat: via -F stdin #5\nEOF'
claude_case "$C" 0 $'git commit -m "$(cat <<\'EOF\'\nfeat: quote "inside" body #6\nEOF\n)"'
claude_case "$C" 0 'git commit --amend --no-edit'
claude_case "$C" 0 'git commit -F /tmp/msg.txt'
claude_case "$C" 0 'git commit -m "Merge branch main into x"'
claude_case "$C" 0 'git commit -m "Revert \"feat: x\""'
claude_case "$C" 0 'git commit -m "fixup! feat: x"'
claude_case "$C" 0 'echo "git commit -m test" > notes.txt'
claude_case "$C" 0 'ls -la'
claude_case "$C" 0 'git log --oneline'
claude_case "$C" 0 'git merge --no-commit other'
claude_case "$C" 0 'git stash push -m "wip stuff"'
claude_case "$C" 2 'git commit -m "feat: no issue number"'
claude_case "$C" 0 'git commit -m "feat: no issue number"' 'claude/session-abc'
# Only the commit's own options / heredoc count: not text in the heredoc body or a later command.
claude_case "$C" 0 $'git add foo.txt\ngit commit -F - <<\'MSG\'\nfeat: chained with git add #7\nMSG'
claude_case "$C" 0 $'git add foo.txt && git commit -F - <<\'MSG\'\nfeat: chained with && #7\nMSG'
claude_case "$C" 0 $'git add foo.txt\ngit commit -m "$(cat <<\'EOF\'\nfeat: chained heredoc in -m #7\nEOF\n)"'
claude_case "$C" 0 $'git commit -F - <<\'MSG\'\nfeat: body mentions an option #8\n\n- use git commit -m "x" for short ones\nMSG'
claude_case "$C" 0 $'git commit -F msg.txt && cat <<\'EOF\'\nnot a subject\nEOF'
claude_case "$C" 0 'git commit -F msg.txt && git log -m "x"'
claude_case "$C" 0 'git commit -m "fix: a; b & c | d #9"'
# Separators inside quoted option values do not end the command (quote-aware prefix scan).
claude_case "$C" 0 'git commit --author="A & B <a@example.com>" -m "feat: quoted amp #10"'
claude_case "$C" 2 'git commit --author="A & B <a@example.com>" -m "bad"'
claude_case "$C" 2 "git commit --author='A; B' -m 'bad'"
claude_case "$C" 2 'git commit --trailer="Note: a | b" -m "bad"'
claude_case "$C" 2 'git commit --author="A \"&\" B" -m "bad"'
claude_case "$C" 2 'git commit --author=A\&B -m "bad"'
claude_case "$C" 2 $'git commit --author="A\nB" -m "bad"'
claude_case "$C" 0 'git commit --author="A & B" -m "feat: ok #1" && git commit -m "fix: x; y #2"'
claude_case "$C" 2 'git commit --author="A & B" -m "feat: ok #1" && git commit -m "bad second"'
claude_case "$C" 0 $'git commit -F - <<\'MSG\'\nfeat: apostrophe in body #11\n\n- don\'t use -m "x" here\nMSG'
claude_case "$C" 2 $'git commit -F - <<\'MSG\'\nbad subject\n\n- it\'s fine to say -m "feat: ok #1"\nMSG'
claude_case "$C" 0 'git commit -m "feat: no issue number"' 'copilot/task-abc'
claude_case "$C" 2 'git commit -m "feat:no space #1"'
claude_case "$C" 2 'git commit -m "feat:  two spaces #1"'
claude_case "$C" 2 'git commit -m "Feat: capitalized #1"'
claude_case "$C" 2 'git commit -m "test"'
claude_case "$C" 2 "git commit -m 'bad message'"
claude_case "$C" 2 'git commit -am "bad message"'
claude_case "$C" 2 'git commit -a -m "bad message"'
claude_case "$C" 2 'git commit --message="bad message"'
claude_case "$C" 2 'git commit --message "bad message"'
claude_case "$C" 2 'git commit -m test'
claude_case "$C" 2 'git commit -m feat:x'
claude_case "$C" 2 $'git commit -m "$(cat <<\'EOF\'\nbad heredoc\nEOF\n)"'
claude_case "$C" 2 $'git commit -m "$(cat <<\'MSG\'\nbad other delimiter\nMSG\n)"'
claude_case "$C" 2 $'git commit -F - <<\'EOF\'\nbad via -F stdin\nEOF'
claude_case "$C" 2 'git commit --amend -m "bad amend"'
claude_case "$C" 2 'git -C /some/path commit -m "bad"'
claude_case "$C" 2 'git --no-pager commit -m "bad"'
claude_case "$C" 2 'git -c user.name=x commit -m "bad"'
claude_case "$C" 2 'git add . && git commit -m "bad"'
claude_case "$C" 2 $'git add .\ngit commit -m "bad"'
claude_case "$C" 2 'cd sub; git commit -m "bad"'
claude_case "$C" 2 'git stash push -m "wip" && git commit -m "bad"'
claude_case "$C" 2 'git commit -m "feat: ok #1" && git commit -m "bad second"'
claude_case "$C" 2 $'git add foo.txt\ngit commit -F - <<\'MSG\'\nbad chained subject\nMSG'
claude_case "$C" 2 $'git commit -F - <<\'MSG\'\nbad subject\n\n- body mentions -m "feat: ok #1"\nMSG'

# --- Claude: branch name ---------------------------------------------------
echo "## Claude PreToolUse hook: validate-branch-name.sh"
B=$CLAUDE_BRANCH
claude_case "$B" 0 'git checkout -b feature/#42-add-user-model'
claude_case "$B" 0 'git checkout -b "feature/#42-add-user-model"'
claude_case "$B" 0 "git checkout -b 'fix/#5-date-boundary'"
claude_case "$B" 0 'git checkout -b refactor/#10-api-client main'
claude_case "$B" 0 'git checkout -b docs/#7-readme'
claude_case "$B" 0 'git switch -c feature/#1-ok'
claude_case "$B" 0 'git branch feature/#3-ok'
claude_case "$B" 0 'git worktree add -b feature/#8-ok ../wt main'
claude_case "$B" 0 'git worktree add ../wt existing-branch'
claude_case "$B" 0 'git checkout -b claude/session-x'
claude_case "$B" 0 'git checkout -b copilot/fix-123'
claude_case "$B" 0 'git checkout -b main'
claude_case "$B" 0 'git checkout main'
claude_case "$B" 0 'git checkout -- file.txt'
claude_case "$B" 0 'git switch main'
claude_case "$B" 0 'git branch -d test-branch'
claude_case "$B" 0 'git branch -D test-branch'
claude_case "$B" 0 'git branch --list'
claude_case "$B" 0 'git branch -a'
claude_case "$B" 0 'git branch'
claude_case "$B" 0 'git branch -m old new'
claude_case "$B" 0 'git branch --set-upstream-to=origin/main'
claude_case "$B" 0 'git commit -m "docs: mention git checkout -b foo"'
claude_case "$B" 0 'echo "git checkout -b foo"'
claude_case "$B" 0 'grep -r "switch" src/'
claude_case "$B" 2 'git checkout -b feature/#42-addUserModel'
claude_case "$B" 2 'git checkout -b feature/#42-add_user'
claude_case "$B" 2 'git checkout -b feature/#42-'
claude_case "$B" 2 'git checkout -b feature/42-x'
claude_case "$B" 2 'git checkout -b hotfix/#1-x'
claude_case "$B" 2 'git checkout -b test-branch'
claude_case "$B" 2 'git checkout -B test-branch'
claude_case "$B" 2 'git checkout -q -b test-branch'
claude_case "$B" 2 'git checkout --orphan gh-pages'
claude_case "$B" 2 'git switch -c test-branch'
claude_case "$B" 2 'git switch --create test-branch'
claude_case "$B" 2 'git switch -C test-branch'
claude_case "$B" 2 'git switch --create=test-branch'
claude_case "$B" 2 'git branch test-branch'
claude_case "$B" 2 'git branch -f test-branch origin/main'
claude_case "$B" 2 'git worktree add -b test-branch ../wt'
claude_case "$B" 2 'git checkout -b fix/#5-x && git checkout -b bad'
claude_case "$B" 2 'git fetch && git checkout -b bad'
claude_case "$B" 2 $'git fetch\ngit checkout -b bad'
claude_case "$B" 2 'git -C /repo checkout -b bad'

# --- Claude: JSON parser fallback -----------------------------------------
echo "## Claude hooks: JSON parser fallback (jq -> node -> python3 -> warn)"
json=$(jq -cn '{tool_name:"Bash", tool_input:{command:"git commit -m \"bad\""}}')
mkbin() { # mkbin <dir> <extra tools...>: coreutils + git, plus the listed parsers only
  local d="$1"; shift
  rm -rf "$d"; mkdir -p "$d"
  local b
  for b in cat head tail tr sed awk grep git bash printf; do ln -sf "$(command -v "$b")" "$d/$b"; done
  for b in "$@"; do ln -sf "$(command -v "$b")" "$d/$b"; done
}
for parser in jq node python3 none; do
  if [[ "$parser" != none ]] && ! command -v "$parser" >/dev/null 2>&1; then
    printf 'SKIP  parser=%s not installed\n' "$parser"; continue
  fi
  if [[ "$parser" == none ]]; then mkbin "$TMP/bin"; want=1; else mkbin "$TMP/bin" "$parser"; want=2; fi
  out=$(printf '%s' "$json" | PATH="$TMP/bin" CLAUDE_PROJECT_DIR="$ROOT" bash "$CLAUDE_COMMIT" 2>&1); rc=$?
  if [[ "$rc" == "$want" ]]; then ok "parser=$parser rc=$rc"; else bad "parser=$parser rc=$rc want=$want" "$out"; fi
done

# --- Copilot payload format (same scripts, .github/hooks copy) --------------
echo "## Copilot hook payload (toolName/toolArgs as object and as JSON string)"
CP_COMMIT="$ROOT/template-copilot/.github/hooks/validate-commit-message.sh"
CP_BRANCH="$ROOT/template-copilot/.github/hooks/validate-branch-name.sh"
fixture="$TMP/copilot-payload"
git init -q -b feature/#1-x "$fixture"
git -C "$fixture" -c user.name=t -c user.email=t@example.com commit -q --allow-empty -m "chore: fixture #1"
copilot_case() { # copilot_case <hook> <expected-rc> <command> <object|string> [expect-stdout-deny]
  local hook="$1" want="$2" cmd="$3" form="$4" json out rc
  if [[ "$form" == string ]]; then
    json=$(jq -cn --arg c "$cmd" --arg d "$fixture" '{toolName:"bash", toolArgs:({command:$c}|tojson), cwd:$d}')
  else
    json=$(jq -cn --arg c "$cmd" --arg d "$fixture" '{toolName:"bash", toolArgs:{command:$c}, cwd:$d}')
  fi
  out=$(printf '%s' "$json" | env -u CLAUDE_PROJECT_DIR bash "$hook" 2>/dev/null); rc=$?
  if [[ "$rc" != "$want" ]]; then bad "copilot/$form rc=$rc want=$want  $(show "$cmd")" "$out"; return; fi
  if [[ "$want" == 2 ]] && ! printf '%s' "$out" | jq -e '.permissionDecision == "deny" and (.permissionDecisionReason|length > 0)' >/dev/null 2>&1; then
    bad "copilot/$form rc=$rc but no deny JSON on stdout  $(show "$cmd")" "$out"; return
  fi
  ok "copilot/$form rc=$rc  $(show "$cmd")"
}
copilot_case "$CP_COMMIT" 0 'git commit -m "feat: ok #1"' object
copilot_case "$CP_COMMIT" 2 'git commit -m "bad"' object
copilot_case "$CP_COMMIT" 2 'git commit -m "feat: no issue"' string
copilot_case "$CP_COMMIT" 0 'git commit -m "feat: ok #1"' string
copilot_case "$CP_BRANCH" 2 'git checkout -b bad-name' object
copilot_case "$CP_BRANCH" 0 'git checkout -b feature/#2-ok' string
copilot_case "$CP_BRANCH" 2 'git switch -c bad-name' string
echo "## Claude and Copilot hook copies are identical except for the DOC line"
for f in validate-commit-message.sh validate-branch-name.sh; do
  if diff -q <(grep -v '^DOC=' "$ROOT/template/.claude/hooks/$f") <(grep -v '^DOC=' "$ROOT/template-copilot/.github/hooks/$f") >/dev/null; then
    ok "$f copies identical"
  else
    bad "$f copies differ (run: diff template/.claude/hooks/$f template-copilot/.github/hooks/$f)"
  fi
done
if jq -e '.hooks.preToolUse | length == 2' "$ROOT/template-copilot/.github/hooks/validate-conventions.json" >/dev/null; then ok "validate-conventions.json registers both hooks"; else bad "validate-conventions.json malformed"; fi

# --- Claude: SessionStart smoke test --------------------------------------
echo "## Claude SessionStart hook: session-start-info.sh"
out=$(CLAUDE_PROJECT_DIR="$ROOT" bash "$CLAUDE_SESSION" 2>&1); rc=$?
if [[ "$rc" == 0 && "$out" == *"## Repository status"* ]]; then ok "prints the repository banner (rc=$rc)"; else bad "banner rc=$rc" "$out"; fi
out=$(CLAUDE_PROJECT_DIR="$TMP" bash "$CLAUDE_SESSION" 2>&1); rc=$?
if [[ "$rc" == 0 && -z "$out" ]]; then ok "silent outside a git repository"; else bad "outside git rc=$rc" "$out"; fi

# --- Claude: SessionStart template update check ---------------------------
# `git ls-remote` is intercepted by a wrapper on PATH so the cases run offline:
#   FAKE_LATEST=<tag>  -> the remote's newest v* tag;  FAKE_LATEST=  -> the fetch fails (offline).
echo "## Claude SessionStart hook: template update check (cache vs local version)"
mkdir -p "$TMP/fakegit"
cat >"$TMP/fakegit/git" <<EOF
#!/usr/bin/env bash
if [[ "\$1" == ls-remote ]]; then
  [[ -n "\${FAKE_LATEST:-}" ]] || exit 128
  printf '%s\trefs/tags/%s\n' 0000 "\$FAKE_LATEST"; exit 0
fi
exec "$(command -v git)" "\$@"
EOF
chmod +x "$TMP/fakegit/git"
tvrepo="$TMP/tv-repo"
git init -q -b main "$tvrepo"
mkdir -p "$tvrepo/.claude"
# tv_case <name> <local> <cache|-> <remote|-> <expect: update|uptodate|unknown> [expected-cache|-]
tv_case() {
  local name="$1" local_v="$2" cache_v="$3" remote_v="$4" want="$5" want_cache="${6:--}" out rc cache_file
  printf 'repo=example/template\nversion=%s\n' "$local_v" >"$tvrepo/.claude/template-version"
  cache_file="$tvrepo/.git/template-version-check"
  rm -f "$cache_file"
  [[ "$cache_v" != - ]] && printf '%s\n' "$cache_v" >"$cache_file"   # fresh cache (mtime = now)
  [[ "$remote_v" == - ]] && remote_v=""
  out=$(PATH="$TMP/fakegit:$PATH" FAKE_LATEST="$remote_v" CLAUDE_PROJECT_DIR="$tvrepo" bash "$CLAUDE_SESSION" 2>&1); rc=$?
  local got=other
  case "$out" in
    *"Template update available"*) got=update ;;
    *"Latest: unknown"*) got=unknown ;;
    *"up to date"*) got=uptodate ;;
  esac
  if [[ "$rc" != 0 || "$got" != "$want" ]]; then bad "$name: got=$got want=$want rc=$rc" "$out"; return; fi
  if [[ "$want_cache" != - ]]; then
    local c; c=$(tr -d '[:space:]' <"$cache_file" 2>/dev/null || true)
    if [[ "$c" != "$want_cache" ]]; then bad "$name: cache=$c want=$want_cache" "$out"; return; fi
  fi
  ok "$name"
}
tv_case "no cache, remote == local"                       v2.0.1 -      v2.0.1 uptodate v2.0.1
tv_case "no cache, remote newer"                          v2.0.1 -      v2.1.0 update   v2.1.0
tv_case "no cache, remote newer (sort -V, not lexical)"   v2.9.0 -      v2.10.0 update  v2.10.0
tv_case "no cache, remote older than local -> no warning" v2.0.1 -      v2.0.0 uptodate v2.0.0
tv_case "no cache, offline"                               v2.0.1 -      -      unknown
tv_case "fresh cache == local, offline -> cache used"     v2.0.1 v2.0.1 -      uptodate v2.0.1
tv_case "fresh cache newer than local -> warn from cache" v2.0.1 v2.1.0 -      update   v2.1.0
tv_case "stale cache (older than local) -> refetched"     v2.0.1 v2.0.0 v2.0.1 uptodate v2.0.1
tv_case "stale cache, remote even newer -> warn"          v2.0.1 v2.0.0 v2.1.0 update   v2.1.0
tv_case "stale cache, offline -> unknown, no warning"     v2.0.1 v2.0.0 -      unknown  v2.0.0

# --- Copilot: commit-msg ---------------------------------------------------
echo "## Copilot git hook: commit-msg"
copilot_commit_case 0 'feature/#1-x' 'feat: ok #1'
copilot_commit_case 0 'feature/#1-x' 'feat(api)!: ok #1'
copilot_commit_case 0 'feature/#1-x' "Merge branch 'main' into x"
copilot_commit_case 0 'feature/#1-x' 'Revert "feat: x #1"'
copilot_commit_case 0 'feature/#1-x' $'# comment line\nfeat: after comment #2'
copilot_commit_case 0 'copilot/task-1' 'feat: no issue on agent branch'
copilot_commit_case 0 'claude/session-1' 'feat: no issue on agent branch'
copilot_commit_case 1 'feature/#1-x' 'test'
copilot_commit_case 1 'feature/#1-x' 'feat: no issue'
copilot_commit_case 1 'feature/#1-x' 'feat:no space #1'
copilot_commit_case 1 'feature/#1-x' 'Feat: capitalized #1'

# --- Copilot: pre-push -----------------------------------------------------
echo "## Copilot git hook: pre-push"
copilot_push_case 0 'refs/heads/feature/#1-x'
copilot_push_case 0 'refs/heads/copilot/abc'
copilot_push_case 0 'refs/heads/claude/abc'
copilot_push_case 0 'refs/heads/main'
copilot_push_case 0 'refs/tags/v1.0.0'
copilot_push_case 1 'refs/heads/feature/#1-addUser'
copilot_push_case 1 'refs/heads/test-branch'

# --- Regex synchronisation -------------------------------------------------
echo "## Regex sync across Claude hooks, Copilot hooks and CI"
BRANCH_RE='^(feature|fix|refactor|docs)/#[0-9]+-[a-z0-9]+(-[a-z0-9]+)*$'
COMMIT_RE='^(feat|fix|refactor|test|docs|chore|style)(\([^)]+\))?!?: [^[:space:]]'
for f in "$CLAUDE_BRANCH" "$ROOT/template-copilot/.github/hooks/validate-branch-name.sh" "$COPILOT_PUSH" "$COPILOT_CI"; do
  if grep -qF -- "$BRANCH_RE" "$f"; then ok "branch regex present in ${f#"$ROOT"/}"; else bad "branch regex missing/different in ${f#"$ROOT"/}"; fi
done
for f in "$CLAUDE_COMMIT" "$ROOT/template-copilot/.github/hooks/validate-commit-message.sh" "$COPILOT_COMMIT" "$COPILOT_CI"; do
  if grep -qF -- "$COMMIT_RE" "$f"; then ok "commit regex present in ${f#"$ROOT"/}"; else bad "commit regex missing/different in ${f#"$ROOT"/}"; fi
done

echo
echo "passed=$pass failed=$fail"
[[ "$fail" -eq 0 ]]
