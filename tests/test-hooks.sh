#!/usr/bin/env bash
# Regression tests for the guardrail scripts shipped in template/.
#
#   tests/test-hooks.sh            # run everything
#
# Covers:
#   - template/.claude/hooks/validate-commit-message.sh  (Claude Code PreToolUse hook)
#   - template/.claude/hooks/validate-branch-name.sh     (Claude Code PreToolUse hook)
#   - template/.claude/hooks/validate-pkill-pattern.sh   (Claude Code PreToolUse hook)
#   - template/.claude/hooks/validate-push-target.sh     (Claude Code PreToolUse hook)
#   - template/.claude/hooks/session-start-info.sh       (smoke test + template update check)
#   - the Copilot preToolUse payload format, which the commit / branch hooks also parse
#
# Requires: bash, git, jq. (node / python3 are only needed for the parser-fallback cases
# and those cases are skipped when the interpreter is not installed.)

set -uo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
CLAUDE_COMMIT="$ROOT/template/.claude/hooks/validate-commit-message.sh"
CLAUDE_BRANCH="$ROOT/template/.claude/hooks/validate-branch-name.sh"
CLAUDE_PKILL="$ROOT/template/.claude/hooks/validate-pkill-pattern.sh"
CLAUDE_PUSH="$ROOT/template/.claude/hooks/validate-push-target.sh"
CLAUDE_SESSION="$ROOT/template/.claude/hooks/session-start-info.sh"

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

# --- Claude: self-matching pkill -f / pgrep -f --------------------------------
# The Bash tool's shell has the whole command text on its own command line, so a -f pattern
# that matches that text kills (pkill) or lists (pgrep) the shell itself (#80, #163).
echo "## Claude PreToolUse hook: validate-pkill-pattern.sh"
K=$CLAUDE_PKILL
claude_case "$K" 0 'pkill node'
claude_case "$K" 0 'pkill -f "[n]ode dev-server"'
claude_case "$K" 0 'pkill -f -- "[n]ode dev-server"'
claude_case "$K" 0 "pkill -f '^node dev'"
claude_case "$K" 0 'pkill -A -f node'
claude_case "$K" 0 'pkill --ignore-ancestors -f node'
claude_case "$K" 0 'pkill -fx node'
claude_case "$K" 0 "pkill -fu node '[v]ite'"
claude_case "$K" 0 'echo node; pgrep -f "[N]ODE"'
claude_case "$K" 0 "pkill -f '(unclosed'"
claude_case "$K" 0 'git commit -m "fix: stop pkill -f from matching itself"'
claude_case "$K" 0 'echo "pkill -f node"'
claude_case "$K" 2 'pkill -f "node dev-server"'
claude_case "$K" 2 'pgrep -fa node'
claude_case "$K" 2 'pkill -af node'
claude_case "$K" 2 'pkill --full node'
claude_case "$K" 2 'pkill -9 -f node'
claude_case "$K" 2 'pkill -STOP -f node'
claude_case "$K" 2 'pkill -ABRT -f node'
claude_case "$K" 2 'pgrep node -f'
claude_case "$K" 2 "pkill -fu root vite"
claude_case "$K" 2 "pkill -f ''"
claude_case "$K" 2 'node dev-server.js & sleep 1; pkill -f "[n]ode dev-server"'
claude_case "$K" 2 'echo node; pgrep -fi "[N]ODE"'
claude_case "$K" 2 $'echo a\npkill -f "[a] pkill"'
claude_case "$K" 2 'pkill -f -- -node-dev'
claude_case "$K" 0 "pkill -f --euid node '[v]ite'"
claude_case "$K" 2 'npm stop; pkill -f vite && npm run clean'
claude_case "$K" 2 'kill $(pgrep -f node)'
claude_case "$K" 2 'pkill -f "$PAT"'
claude_case "$K" 2 'pkill -f "$(cat pattern.txt)"'
# Behind reserved words, prefix commands and paths; `while pgrep -f x` would never end.
claude_case "$K" 2 'if pgrep -f vite >/dev/null; then echo up; fi'
claude_case "$K" 2 'if pgrep -f vite >/dev/null; then pkill -f "[v]ite"; fi'
claude_case "$K" 2 'if pgrep -f "[v]ite" >/dev/null; then pkill -f vite; fi'
claude_case "$K" 2 'while pgrep -f "node dev" >/dev/null; do sleep 1; done'
claude_case "$K" 2 'for p in vite node; do pkill -f "$p"; done'
claude_case "$K" 2 '{ pkill -f vite; }'
claude_case "$K" 2 '! pgrep -f vite'
claude_case "$K" 2 'sudo pkill -f vite'
claude_case "$K" 2 'timeout 5 pkill -f vite'
claude_case "$K" 2 'FOO=1 pkill -f vite'
claude_case "$K" 2 '/usr/bin/pkill -f vite'
claude_case "$K" 0 'if pgrep -f "[v]ite" >/dev/null; then pkill -f "[v]ite"; fi'
claude_case "$K" 0 'git commit -m "fix: then pkill -f node"'
# A line continuation is not a word: the shell runs `pkill -f vite`.
claude_case "$K" 2 $'pkill \\\n  -f vite'
claude_case "$K" 2 $'pkill -f \\\n  vite'
# A quoted heredoc body is text (a PR body), not commands; an unquoted one runs `...`.
claude_case "$K" 0 $'gh pr create --body-file - <<\'EOF\'\n- `pkill -f "node dev-server"` を止める\nEOF'
claude_case "$K" 0 $'cat <<"EOF" >notes.md\npgrep -fa node\nEOF'
claude_case "$K" 2 $'cat <<EOF >notes.md\n`pgrep -fa node`\nEOF'
claude_case "$K" 2 $'cat <<\'EOF\' >notes.md\nnode dev-server\nEOF\npkill -f "[n]ode dev-server"'

# A long command (a large heredoc) must stay well inside the 10 s timeout in settings.json.
big="printf '%s\\n' '$(for _ in $(seq 2000); do printf 'line of text for the body, about sixty characters long\n'; done)' >a.md; pkill -f '[n]ode dev'"
start=$(date +%s)
claude_case "$K" 0 "$big"
elapsed=$(( $(date +%s) - start ))
if [[ $elapsed -le 3 ]]; then ok "about 110 KB of command text checked in ${elapsed}s"; else bad "about 110 KB of command text took ${elapsed}s (timeout is 10s)"; fi

# --- Claude: push to the default branch --------------------------------------
# Changes reach main only through a PR a person merges, so Claude's pushes to main / master / the
# branch origin/HEAD points to are blocked, whichever way the command names them (#333).
echo "## Claude PreToolUse hook: validate-push-target.sh"
PUSH_REMOTE="$TMP/push-remote.git"
PUSH_REPO="$TMP/push-clone"
pgit() { git -C "$PUSH_REPO" -c user.name=t -c user.email=t@example.com "$@"; }
git init -q --bare -b main "$PUSH_REMOTE"
git clone -q "$PUSH_REMOTE" "$PUSH_REPO" 2>/dev/null
pgit commit -q --allow-empty -m "chore: fixture #1"
pgit push -q origin main 2>/dev/null
pgit symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main
pgit branch -q develop && pgit push -q origin develop 2>/dev/null
pgit branch -q --track 'feature/#2-tracks-main' origin/main
pgit switch -q -c 'feature/#1-fixture' && pgit push -q -u origin 'feature/#1-fixture' 2>/dev/null
mkdir -p "$TMP/not-a-repo"

# push_case <expected-rc> <command> [branch|--detach] [cwd] — runs the hook in the clone, on <branch>
# (default: the Issue branch, pushed with -u).
push_case() {
  local want="$1" cmd="$2" branch="${3:-feature/#1-fixture}" dir="${4:-$PUSH_REPO}" json out rc
  if [[ "$branch" == --detach ]]; then pgit checkout -q --detach; else pgit switch -q "$branch"; fi
  json=$(jq -cn --arg c "$cmd" --arg d "$dir" '{tool_name:"Bash", tool_input:{command:$c}, cwd:$d}')
  out=$(printf '%s' "$json" | CLAUDE_PROJECT_DIR="$dir" bash "$CLAUDE_PUSH" 2>&1)
  rc=$?
  # exit 2 must come from the hook's own deny, not from a command failing under set -e
  if [[ "$rc" == 2 && "$out" != *"[hook:validate-push-target]"* ]]; then rc="2 without the reason"; fi
  if [[ "$rc" == "$want" ]]; then ok "rc=$rc  [$branch] $(show "$cmd")"; else bad "rc=$rc want=$want  [$branch] $(show "$cmd")" "$out"; fi
}
# On the Issue branch: pushing it, tags, other subcommands and text that only mentions a push.
push_case 0 'git push'
push_case 0 'git push -u origin HEAD'
push_case 0 'git push -u origin feature/#1-fixture'
push_case 0 "git push -u origin 'feature/#1-fixture'"
push_case 0 'git push origin HEAD:feature/#1-fixture'
push_case 0 'git push origin HEAD:refs/heads/feature/#1-fixture'
push_case 0 'git push origin main:feature/#1-fixture'
push_case 0 'git push origin feature/#1-keep-main-green'
push_case 0 'git push origin HEAD:maintenance'
push_case 0 'git push origin --delete feature/#9-old'
push_case 0 'git push --tags origin'
push_case 0 'git push origin tag main'
push_case 0 'git push origin refs/tags/main'
push_case 0 'git push -o ci.skip origin feature/#1-fixture'
push_case 0 'git push --push-option main origin feature/#1-fixture'
push_case 0 'git push origin feature/#1-fixture 2>&1 | tail -5'
push_case 0 'git push origin feature/#1-fixture > /tmp/main'
push_case 0 'git log --oneline origin/main..HEAD && git push -u origin HEAD'
push_case 0 'git stash push -m main'
push_case 0 'echo git push origin main'
push_case 0 'git commit -m "fix: stop git push origin main #1"'
push_case 0 'git -C "$DIR" push origin feature/#1-fixture'
push_case 0 'git -c push.default=nothing push' main
push_case 0 'git push origin HEAD:feature/#1-fixture' main
# Quoted heredoc bodies are text (a PR body); an unquoted one runs its `...`.
push_case 0 $'gh pr create --body-file - <<\'EOF\'\n- `git push origin main` を止める\nEOF'
push_case 2 $'cat <<EOF >notes.md\n`git push origin main`\nEOF'
# Naming the default branch, however the command is written.
push_case 2 'git push origin main'
push_case 2 'git push -u origin main'
push_case 2 'git push origin main --no-verify'
push_case 2 'git push origin HEAD:main'
push_case 2 "git push origin 'HEAD:main'"
push_case 2 'git push origin HEAD:refs/heads/main'
push_case 2 'git push origin refs/heads/main'
push_case 2 'git push origin @:main'
push_case 2 'git push origin +HEAD:main'
push_case 2 'git push origin feature/#1-fixture main'
push_case 2 'git push origin master'
push_case 2 'git push origin :main'
push_case 2 'git push origin --delete main'
push_case 2 'git push -d origin main'
push_case 2 'git push --all origin'
push_case 2 'git push --mirror origin'
push_case 2 'git -C . push origin main'
push_case 2 'git -c push.default=current push origin main'
push_case 2 'git --no-pager push origin main'
push_case 2 'git add . && git commit -m "feat: x #1" && git push origin main'
push_case 2 $'git status\ngit push origin main'
push_case 2 'timeout 60 git push origin main'
push_case 2 'GIT_TRACE=1 git push origin main'
push_case 2 '/usr/bin/git push origin main'
push_case 2 '\git push origin main'
push_case 2 'git push origin main' main "$TMP/not-a-repo"
# A refspec, or a -C directory the current branch is read in, the hook cannot evaluate.
push_case 2 'git push origin "$BRANCH"'
push_case 2 'git push origin "HEAD:$(git branch --show-current)"'
push_case 2 'git -C "$DIR" push'
# On the default branch: no refspec, HEAD and @ resolve to it.
push_case 2 'git push' main
push_case 2 'git push origin' main
push_case 2 'git push -u origin HEAD' main
push_case 2 'git push origin HEAD' main
push_case 2 'git push origin @' main
push_case 2 'git -C . push' main
push_case 0 'git push' main "$TMP/not-a-repo"
# push.default decides where a bare `git push` goes.
push_case 0 'git push' 'feature/#2-tracks-main'
push_case 2 'git -c push.default=upstream push' 'feature/#2-tracks-main'
push_case 2 'git -c push.default=tracking push' 'feature/#2-tracks-main'
push_case 2 'git -c push.default=matching push'
pgit config push.default upstream
push_case 2 'git push' 'feature/#2-tracks-main'
pgit config --unset push.default
# Detached HEAD: git pushes nothing without a destination.
push_case 0 'git push' --detach
push_case 0 'git push origin HEAD' --detach
# The branch origin/HEAD points to is protected too.
push_case 0 'git push origin develop'
pgit symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/develop
push_case 2 'git push origin develop'
push_case 2 'git push' develop
pgit symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main

big="printf '%s\\n' '$(for _ in $(seq 2000); do printf 'line of text for the body, about sixty characters long\n'; done)' >a.md; git push -u origin HEAD"
start=$(date +%s)
push_case 0 "$big"
elapsed=$(( $(date +%s) - start ))
if [[ $elapsed -le 3 ]]; then ok "about 110 KB of command text checked in ${elapsed}s"; else bad "about 110 KB of command text took ${elapsed}s (timeout is 10s)"; fi

# --- Claude: JSON parser fallback -----------------------------------------
echo "## Claude hooks: JSON parser fallback (jq -> node -> python3 -> deny)"
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
  if [[ "$parser" == none ]]; then mkbin "$TMP/bin"; else mkbin "$TMP/bin" "$parser"; fi; want=2
  out=$(printf '%s' "$json" | PATH="$TMP/bin" CLAUDE_PROJECT_DIR="$ROOT" bash "$CLAUDE_COMMIT" 2>&1); rc=$?
  if [[ "$rc" == "$want" ]]; then ok "parser=$parser rc=$rc"; else bad "parser=$parser rc=$rc want=$want" "$out"; fi
done

# No parser at all: every PreToolUse hook denies with the reason instead of passing the command
# unvalidated (#153). The payload hits every fast path; without a parser its shape does not
# matter.
mkbin "$TMP/bin"
json=$(jq -cn '{tool_name:"Bash", tool_input:{command:"git checkout -b bad && git commit -m \"bad\"; pkill -f bad; git push origin main"}}')
for hook in "$CLAUDE_COMMIT" "$CLAUDE_BRANCH" "$CLAUDE_PKILL" "$CLAUDE_PUSH"; do
  name=${hook#"$ROOT/"}
  out=$(printf '%s' "$json" | PATH="$TMP/bin" CLAUDE_PROJECT_DIR="$ROOT" bash "$hook" 2>&1); rc=$?
  if [[ "$rc" == 2 && "$out" == *"No JSON parser found"*"blocked"* ]]; then ok "no parser denies: $name"
  else bad "no parser: $name rc=$rc want=2 with the reason" "$out"; fi
done

for f in validate-branch-name.sh validate-commit-message.sh validate-pkill-pattern.sh validate-push-target.sh; do
  if jq -e --arg f "$f" '[.hooks.PreToolUse[] | select(.matcher == "Bash") | .hooks[].command | contains($f)] | any' \
      "$ROOT/template/.claude/settings.json" >/dev/null; then
    ok "settings.json: $f is registered for the Bash tool"
  else
    bad "settings.json: $f is not registered under PreToolUse matcher Bash"
  fi
done

# A hook that times out, cannot start or crashes must block the call, not let it through (#153).
if jq -e '[.hooks.PreToolUse[].hooks[] | .onFailure == "block"] | all' "$ROOT/template/.claude/settings.json" >/dev/null; then
  ok 'settings.json: every PreToolUse hook has "onFailure": "block"'
else
  bad 'settings.json: a PreToolUse hook lacks "onFailure": "block"' "$(jq -c '.hooks.PreToolUse' "$ROOT/template/.claude/settings.json")"
fi

# --- Copilot payload format ------------------------------------------------
# The commit / branch hooks also parse the Copilot preToolUse payload (toolName / toolArgs).
echo "## Copilot hook payload (toolName/toolArgs as object and as JSON string)"
CP_COMMIT=$CLAUDE_COMMIT
CP_BRANCH=$CLAUDE_BRANCH
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

# --- Claude: SessionStart smoke test --------------------------------------
echo "## Claude SessionStart hook: session-start-info.sh"
out=$(CLAUDE_PROJECT_DIR="$ROOT" bash "$CLAUDE_SESSION" 2>&1); rc=$?
if [[ "$rc" == 0 && "$out" == *"## Repository status"* ]]; then ok "prints the repository banner (rc=$rc)"; else bad "banner rc=$rc" "$out"; fi
if [[ "$out" == *'- Checkout: `'*'` (where this hook ran'* ]]; then ok "banner names the checkout the hook ran in"; else bad "banner lacks the Checkout line" "$out"; fi
out=$(CLAUDE_PROJECT_DIR="$TMP" bash "$CLAUDE_SESSION" 2>&1); rc=$?
if [[ "$rc" == 0 && -z "$out" ]]; then ok "silent outside a git repository"; else bad "outside git rc=$rc" "$out"; fi

# --- Claude: SessionStart ghost worktree detection --------------------------
# The launch path is compared with `git worktree list`, which prints physical paths.
# Opening a registered worktree through a symlink (macOS /tmp -> /private/tmp, a linked
# work directory) must not be reported as a ghost (#142); a real ghost must still be.
echo "## Claude SessionStart hook: ghost worktree detection"
gwrepo="$TMP/gw-repo"
git init -q -b main "$gwrepo"
git -C "$gwrepo" -c user.email=t@t -c user.name=t commit -q --allow-empty -m init
git -C "$gwrepo" worktree add -q --detach "$gwrepo/.claude/worktrees/ok"
mkdir -p "$gwrepo/.claude/worktrees/ghost"
ln -s "$gwrepo" "$TMP/gw-link"
# gw_case <name> <project dir> <expect: ghost|none>
gw_case() {
  local name="$1" dir="$2" want="$3" out got=none
  out=$(CLAUDE_PROJECT_DIR="$dir" bash "$CLAUDE_SESSION" 2>&1) || { bad "$name: rc=$?" "$out"; return; }
  [[ "$out" == *"## ⚠ Ghost worktree detected"* ]] && got=ghost
  if [[ "$got" == "$want" ]]; then ok "$name"; else bad "$name: got=$got want=$want" "$out"; fi
}
gw_case "registered worktree via its physical path is not a ghost" "$gwrepo/.claude/worktrees/ok" none
gw_case "registered worktree via a symlinked path is not a ghost" "$TMP/gw-link/.claude/worktrees/ok" none
gw_case "unregistered worktree dir is a ghost" "$gwrepo/.claude/worktrees/ghost" ghost
gw_case "unregistered worktree dir via a symlinked path is a ghost" "$TMP/gw-link/.claude/worktrees/ghost" ghost

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
# tv_case <name> <local> <cache|-> <remote|-> <expect: update|uptodate|default|unknown> [expected-cache|-]
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
    *"Template update available"*"Local \`"*"Latest \`"*) got=update ;;  # same Local / Latest wording as the other lines (#213)
    *"Latest: unknown"*) got=unknown ;;
    *"up to date on the default branch"*) got=default ;;
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
# Online, the remote always wins over a fresh cache (#61: a cache written before a new
# release reported `up to date` for up to 24h).
tv_case "cache == local, remote newer -> fetched, warn (#61)" v2.0.1 v2.0.1 v2.1.0 update v2.1.0
tv_case "cache newer than remote, online -> remote used"  v2.0.1 v2.1.0 v2.0.1 uptodate v2.0.1
tv_case "cache older than local, online -> remote used"   v2.0.1 v2.0.0 v2.0.1 uptodate v2.0.1
tv_case "cache older than local, remote newer -> warn"    v2.0.1 v2.0.0 v2.1.0 update   v2.1.0
# Offline, the cache is the fallback (unless it predates the adopted version).
tv_case "cache == local, offline -> cache used"           v2.0.1 v2.0.1 -      uptodate v2.0.1
tv_case "cache newer than local, offline -> warn from cache" v2.0.1 v2.1.0 -   update   v2.1.0
tv_case "cache older than local, offline -> unknown, no warning" v2.0.1 v2.0.0 - unknown v2.0.0

# The banner says when the version came from the cache, so a stale value can be doubted.
# tv_cached_note <name> <cache|-> <remote|-> <expect: yes|no>  (local is v2.0.1)
tv_cached_note() {
  local name="$1" cache_v="$2" remote_v="$3" want="$4" out got=no
  printf 'repo=example/template\nversion=v2.0.1\n' >"$tvrepo/.claude/template-version"
  rm -f "$tvrepo/.git/template-version-check"
  [[ "$cache_v" != - ]] && printf '%s\n' "$cache_v" >"$tvrepo/.git/template-version-check"
  [[ "$remote_v" == - ]] && remote_v=""
  out=$(PATH="$TMP/fakegit:$PATH" FAKE_LATEST="$remote_v" CLAUDE_PROJECT_DIR="$tvrepo" bash "$CLAUDE_SESSION" 2>&1)
  [[ "$out" == *'(cached '*'h ago; fetch failed'* ]] && got=yes
  if [[ "$got" == "$want" ]]; then ok "$name"; else bad "$name: cached note got=$got want=$want" "$out"; fi
}
tv_cached_note "offline, cache used -> banner marks it cached"  v2.1.0 -      yes
tv_cached_note "online -> banner has no cached mark"            v2.0.1 v2.1.0 no

# The default branch's version (origin/HEAD -> origin/main) also counts as adopted: a worktree
# whose branch is merely behind the default branch must not prompt for a duplicate update issue.
# set_default_version <tag>: commit .claude/template-version at <tag> and point origin/main at it.
set_default_version() {
  printf 'repo=example/template\nversion=%s\n' "$1" >"$tvrepo/.claude/template-version"
  git -C "$tvrepo" add .claude/template-version
  git -C "$tvrepo" -c user.name=t -c user.email=t@example.com commit -q --allow-empty -m "chore: default at $1 #1"
  git -C "$tvrepo" update-ref refs/remotes/origin/main HEAD
  git -C "$tvrepo" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main
}
set_default_version v2.0.3
tv_case "branch behind default (default == latest) -> adopted, no warning" v2.0.2 -      v2.0.3 default  v2.0.3
tv_case "branch behind default, latest newer than both -> warn"            v2.0.2 -      v2.1.0 update   v2.1.0
tv_case "branch == default, latest newer -> warn"                          v2.0.3 -      v2.1.0 update   v2.1.0
tv_case "branch behind default, cache older than default, online -> fetched" v2.0.2 v2.0.2 v2.0.3 default  v2.0.3
tv_case "branch behind default, cache older than default, offline -> unknown" v2.0.2 v2.0.2 -      unknown  v2.0.2
tv_case "branch behind default, offline -> unknown"                        v2.0.2 -      -      unknown
set_default_version v2.0.2
tv_case "branch ahead of default -> judged by this branch"                 v2.0.3 -      v2.0.3 uptodate v2.0.3

# --- Windows (Git Bash / MSYS) path-conversion guard ------------------------
# `origin/main:.claude/template-version` looks like a path list to MSYS and is rewritten to
# `origin\main;.claude\template-version`, so the default-branch read must disable the
# conversion (#42). Linux CI cannot reproduce the rewrite itself; this keeps the fix from
# being dropped in a refactor.
echo "## MSYS path-conversion guard in session-start-info.sh"
if grep -qF -- 'MSYS_NO_PATHCONV=1 git show "$default_ref:' "$CLAUDE_SESSION"; then
  ok "default-branch git show is wrapped with MSYS_NO_PATHCONV=1"
else
  bad "default-branch git show lacks MSYS_NO_PATHCONV=1 (Git Bash would rewrite ref:path)"
fi

echo
echo "passed=$pass failed=$fail"
[[ "$fail" -eq 0 ]]
