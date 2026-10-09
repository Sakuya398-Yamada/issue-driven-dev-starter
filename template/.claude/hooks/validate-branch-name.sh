#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash) — branch name guardrail.
#
# Blocks branch creation when the new name violates the project convention:
#   <feature|fix|refactor|docs>/#<issue>-<kebab-case-description>
#
# Covered commands:
#   git checkout -b|-B <name>        git checkout --orphan <name>
#   git switch -c|-C <name>          git switch --create|--force-create|--orphan <name>
#   git branch [-f|-t|...] <name>    git worktree add [...] -b|-B <name> <path>
#
# Exempt:
#   claude/* , copilot/*       agent session branches (Claude Code on the web / Copilot coding agent)
#   main / master / develop    long-lived branches
#
# Protocol: the hook payload (JSON) arrives on stdin. Exit 2 blocks the tool call and
# feeds stderr back to Claude; exit 0 allows it. Exit 1 is a non-blocking warning.
# JSON is parsed with jq, node or python3 (whichever is found first).

set -euo pipefail

input=$(cat)

# Fast path: skip the JSON parse unless the payload can contain a branch-creating command.
case "$input" in
  *checkout*|*switch*|*branch*|*worktree*) ;;
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
  echo "[hook:validate-branch-name] No JSON parser found (install jq, node or python3). Branch name was NOT validated." >&2
  exit 1
fi

NL=$'\n'
# `git [global options] <subcommand>` at a command position.
git_re='(^|[;&|(`'"$NL"'])[[:space:]]*git([[:space:]]+(-C|-c|--git-dir|--work-tree|--namespace)[[:space:]]+[^[:space:]]+|[[:space:]]+-[^[:space:]]+)*[[:space:]]+'
opt='([[:space:]]+-[^[:space:]]+)*'
# A branch name token, optionally quoted (group captured by the caller).
name='["'"'"']?([^[:space:]"'"'"';&|()`-][^[:space:]"'"'"';&|()`]*)'
checkout_re="^checkout${opt}[[:space:]]+(-b|-B|--orphan)[[:space:]]+${name}"
switch_re="^switch${opt}[[:space:]]+(-c|-C|--create|--force-create|--orphan)(=|[[:space:]]+)${name}"
branch_re='^branch([[:space:]]+(-f|--force|-t|--track|--no-track|-q|--quiet))*[[:space:]]+'"${name}"
worktree_re="^worktree[[:space:]]+add${opt}[[:space:]]+(-b|-B)[[:space:]]+${name}"
convention_re='^(feature|fix|refactor|docs)/#[0-9]+-[a-z0-9]+(-[a-z0-9]+)*$'

candidates=()
rest="$cmd"
while [[ "$rest" =~ $git_re ]]; do
  rest="${rest#*"${BASH_REMATCH[0]}"}"
  if [[ "$rest" =~ $checkout_re ]]; then
    candidates+=("${BASH_REMATCH[3]}")
  elif [[ "$rest" =~ $switch_re ]]; then
    candidates+=("${BASH_REMATCH[4]}")
  elif [[ "$rest" =~ $branch_re ]]; then
    candidates+=("${BASH_REMATCH[3]}")
  elif [[ "$rest" =~ $worktree_re ]]; then
    candidates+=("${BASH_REMATCH[3]}")
  fi
done

[[ ${#candidates[@]} -eq 0 ]] && exit 0

for branch in "${candidates[@]}"; do
  case "$branch" in
    claude/*|copilot/*|main|master|develop) continue ;;
  esac
  if [[ ! "$branch" =~ $convention_re ]]; then
    cat >&2 <<EOF
[hook:validate-branch-name] Branch name '$branch' violates the project convention.

  Expected: <feature|fix|refactor|docs>/#<issue-number>-<kebab-case-description>
  Example:  feature/#42-add-user-model
            fix/#5-date-boundary

  Description: lowercase letters, digits and single hyphens only.
  Exempt: claude/*, copilot/*, main, master, develop.
  See .claude/rules/git-conventions.md for details.
EOF
    exit 2
  fi
done

exit 0
