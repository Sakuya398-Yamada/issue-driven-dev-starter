#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash) — commit message guardrail.
#
# Blocks `git commit` when the subject line violates the project convention:
#   <type>[(scope)][!]: <subject> #<issue>
#   type = feat | fix | refactor | test | docs | chore | style
#
# - "(scope)" and "!" (breaking change) are optional and follow Conventional Commits.
# - The issue number is required, except on agent session branches (claude/*, copilot/*).
# - Subjects that git generates itself (Merge/Revert/fixup!/squash!) are exempt.
#
# Protocol: the hook payload (JSON) arrives on stdin. Exit 2 blocks the tool call and
# feeds stderr back to Claude; exit 0 allows it. Exit 1 is a non-blocking warning.
# JSON is parsed with jq, node or python3 (whichever is found first).
#
# Extraction is conservative on purpose: if no message can be found in the command
# (e.g. `git commit -F file`, `--amend --no-edit`) the command is allowed through
# instead of producing a false positive. git itself still refuses empty messages.

set -euo pipefail

input=$(cat)

# Fast path: skip the JSON parse entirely unless the payload mentions "commit".
case "$input" in
  *commit*) ;;
  *) exit 0 ;;
esac

extract_command() {
  if command -v jq >/dev/null 2>&1; then
    jq -r '.tool_input.command // empty'
  elif command -v node >/dev/null 2>&1; then
    node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{process.stdout.write(JSON.parse(s)?.tool_input?.command||"")}catch(e){}})'
  elif command -v python3 >/dev/null 2>&1; then
    python3 -I -c 'import json,sys
try:
    sys.stdout.write(json.load(sys.stdin).get("tool_input",{}).get("command","") or "")
except Exception:
    pass'
  else
    return 1
  fi
}

if ! cmd=$(printf '%s' "$input" | extract_command); then
  echo "[hook:validate-commit-message] No JSON parser found (install jq, node or python3). Commit message was NOT validated." >&2
  exit 1
fi

NL=$'\n'
# `git [global options] commit` at a command position (start of line / after ; & | ( or a backtick).
git_commit_re='(^|[;&|(`'"$NL"'])[[:space:]]*git([[:space:]]+(-C|-c|--git-dir|--work-tree|--namespace)[[:space:]]+[^[:space:]]+|[[:space:]]+-[^[:space:]]+)*[[:space:]]+commit([[:space:]]|$)'
# -m "...", -m '...', -am "...", --message="...", --message ... (value captured in group 4)
msg_dq_re='(^|[[:space:]])(-[a-zA-Z]*m|--message)(=|[[:space:]]+)"([^"]*)"'
msg_sq_re="(^|[[:space:]])(-[a-zA-Z]*m|--message)(=|[[:space:]]+)'([^']*)'"
msg_bare_re='(^|[[:space:]])(-[a-zA-Z]*m|--message)(=|[[:space:]]+)([^[:space:]"'"'"'$]+)'
# heredoc body: first non-empty line after `<<EOF` / `<<-'EOF'` / `<<"MSG"` (any delimiter name)
heredoc_re='<<-?[[:space:]]*["'"'"']?[A-Za-z_][A-Za-z0-9_]*["'"'"']?[^'"$NL"']*'"$NL"'+([^'"$NL"']+)'
type_re='^(feat|fix|refactor|test|docs|chore|style)(\([^)]+\))?!?: [^[:space:]]'

current_branch_of() {
  local dir="$1"
  git -C "$dir" symbolic-ref --short -q HEAD 2>/dev/null \
    || git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null \
    || echo ""
}

rest="$cmd"
while [[ "$rest" =~ $git_commit_re ]]; do
  matched="${BASH_REMATCH[0]}"
  rest="${rest#*"$matched"}"

  # Honour `git -C <dir> commit` when detecting the current branch.
  repo_dir="${CLAUDE_PROJECT_DIR:-.}"
  if [[ "$matched" =~ -C[[:space:]]+[\"\']?([^[:space:]\"\']+) ]]; then
    repo_dir="${BASH_REMATCH[1]}"
  fi

  msg=""
  if [[ "$rest" =~ $msg_dq_re ]] || [[ "$rest" =~ $msg_sq_re ]] || [[ "$rest" =~ $msg_bare_re ]]; then
    msg="${BASH_REMATCH[4]}"
  fi
  # `-m "$(cat <<'EOF' ...)"` or `-F - <<'EOF'`: the subject is the first heredoc line.
  if [[ -z "$msg" || "$msg" == \$\(* ]]; then
    if [[ "$rest" =~ $heredoc_re ]]; then
      msg="${BASH_REMATCH[1]}"
    else
      msg=""
    fi
  fi

  # Nothing extractable (e.g. -F <file>, --amend --no-edit): let git decide.
  [[ -z "$msg" ]] && continue

  first_line="${msg%%"$NL"*}"
  # Trim surrounding whitespace.
  first_line="${first_line#"${first_line%%[![:space:]]*}"}"
  first_line="${first_line%"${first_line##*[![:space:]]}"}"

  case "$first_line" in
    Merge\ *|Revert\ *|fixup!\ *|squash!\ *) continue ;;
  esac

  if [[ ! "$first_line" =~ $type_re ]]; then
    cat >&2 <<EOF
[hook:validate-commit-message] Commit message violates the project convention.

  First line: $first_line
  Expected:   <type>[(scope)][!]: <subject> #<issue>
  type:       feat | fix | refactor | test | docs | chore | style
  Example:    feat: ユーザーデータモデルを追加 #1

  See .claude/rules/git-conventions.md for details.
EOF
    exit 2
  fi

  current_branch=$(current_branch_of "$repo_dir")
  case "$current_branch" in
    claude/*|copilot/*) issue_optional=1 ;;
    *) issue_optional=0 ;;
  esac

  if [[ "$issue_optional" -eq 0 && ! "$first_line" =~ \#[0-9]+ ]]; then
    cat >&2 <<EOF
[hook:validate-commit-message] Commit message is missing the issue number.

  First line:     $first_line
  Current branch: ${current_branch:-unknown}
  Expected:       <type>: <subject> #<issue>
  Example:        fix: 日付計算の境界条件を修正 #5

  Only agent session branches (claude/*, copilot/*) may omit the issue number.
  See .claude/rules/git-conventions.md for details.
EOF
    exit 2
  fi
done

exit 0
