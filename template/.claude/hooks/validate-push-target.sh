#!/usr/bin/env bash
# Pre-tool-use hook — direct push to the default branch guardrail.
#
# Changes reach the default branch only through a pull request that a person merges (CLAUDE.md
# 「開発フロー」5). settings.json allows `git push` / `git push origin *` / `git push -u origin *`
# without a prompt so that Issue branches can be pushed, and a permission deny only matches the
# command text: it stops `git push origin main`, but not `git push` while on main or
# `git -C . push origin main`. This hook works out which remote branches each `git push` writes
# and blocks it (exit 2) when one of them is protected:
#   main, master, and the branch refs/remotes/<remote>/HEAD points to (when it is set)
#
# Destination of each push:
#   <src>:<dst>, :<dst>, +...   <dst> (refs/heads/ is stripped; other refs/* such as tags are not branches)
#   <name>                      <name>; HEAD and @ are the current branch
#   -d / --delete <name>...     each <name>
#   no refspec                  by push.default (git config, or `git -c push.default=...` in the command):
#                               upstream / tracking -> the upstream branch, nothing -> none,
#                               matching -> blocked when a protected branch exists locally,
#                               current / simple (the default) -> the current branch
#   --all / --branches          blocked when a protected branch exists locally
#   --mirror                    always blocked
# The current branch and its upstream are read in the payload's cwd (or CLAUDE_PROJECT_DIR), after
# any `git -C <dir>`; a `cd` earlier in the command is not followed. A refspec, or a -C directory
# needed to read the current branch, built from a variable or a command substitution cannot be
# checked and is blocked. `git` is found at a command position (start, after ; & | ( ` or a newline,
# also behind env / timeout N / VAR=value ... and a path), not inside quoted heredoc bodies.
#
# Not covered, because the command text does not show the push: `sh -c '...'`, a git alias, a
# script or a make target that pushes, remote.<name>.push refspecs. GitHub branch protection stops
# those too (the template's docs/customization.md "settings.json の権限").
#
# Works under two hosts (the payload arrives as JSON on stdin), like the other validate-* hooks:
#   {"tool_name":"Bash","tool_input":{"command":"..."},"cwd":"..."}  or  {"toolName":"bash","toolArgs":...}
# Exit 2 denies the tool call (Claude Code feeds stderr back to Claude). Exit 0 allows it. JSON is
# parsed with jq, node or python3, whichever exists; with none of them the call is denied. If the
# hook itself crashes or times out, Claude Code blocks the call through "onFailure": "block".

set -euo pipefail

DOC=".claude/rules/git-conventions.md"

input=$(cat)

# Fast path: skip the JSON parse unless the payload can contain a git push.
case "$input" in
  *push*) ;;
  *) exit 0 ;;
esac

extract() { # extract <command|cwd>  — reads the hook payload from stdin
  local field="$1"
  if command -v jq >/dev/null 2>&1; then
    jq -r --arg f "$field" '
      def args: (.toolArgs // {}) | if type == "string" then (fromjson? // {}) else . end;
      if $f == "command" then (.tool_input.command // (args | .command) // "") else (.cwd // "") end'
  elif command -v node >/dev/null 2>&1; then
    node -e '
      let s = ""; process.stdin.on("data", d => s += d).on("end", () => {
        try {
          const j = JSON.parse(s); const f = process.argv[1];
          if (f === "cwd") { process.stdout.write(j.cwd || ""); return; }
          let a = j.toolArgs; if (typeof a === "string") { try { a = JSON.parse(a); } catch (e) { a = {}; } }
          process.stdout.write((j.tool_input && j.tool_input.command) || (a && a.command) || "");
        } catch (e) {}
      });' "$field"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -I -c '
import json, sys
try:
    j = json.load(sys.stdin); f = sys.argv[1]
    if f == "cwd":
        sys.stdout.write(j.get("cwd") or "")
    else:
        a = j.get("toolArgs") or {}
        if isinstance(a, str):
            try:
                a = json.loads(a)
            except Exception:
                a = {}
        sys.stdout.write((j.get("tool_input") or {}).get("command") or (a or {}).get("command") or "")
except Exception:
    pass' "$field"
  else
    return 1
  fi
}

deny() { # deny <message> — blocks the tool call and reports the reason on both hosts
  local msg="$1"
  if command -v jq >/dev/null 2>&1; then
    jq -cn --arg m "$msg" '{permissionDecision: "deny", permissionDecisionReason: $m}'
  fi
  printf '%s\n' "$msg" >&2
  exit 2
}

if ! cmd=$(printf '%s' "$input" | extract command); then
  deny "[hook:validate-push-target] No JSON parser found (install jq, node or python3), so the push destination cannot be checked. The command is blocked instead of being let through unchecked."
fi
cwd=$(printf '%s' "$input" | extract cwd || true)
cwd=${cwd:-${CLAUDE_PROJECT_DIR:-$PWD}}

NL=$'\n'

# strip_quoted_heredocs <text> — <text> without the bodies of quoted heredocs (text such as a PR
# body). Unquoted heredoc bodies stay: their `...` and $(...) do run.
strip_quoted_heredocs() {
  local line cmp out="" delim="" strip_tabs=0
  local hd_re="(^|[^<])<<(-?)[[:space:]]*(\\\\([A-Za-z0-9_]+)|'([^']+)'|\"([^\"]+)\")"
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ -n "$delim" ]]; then
      cmp=$line
      if [[ $strip_tabs == 1 ]]; then cmp=${line#"${line%%[!$'\t']*}"}; fi
      if [[ "$cmp" == "$delim" ]]; then delim=""; fi
      continue
    fi
    out+="$line$NL"
    if [[ "$line" =~ $hd_re ]]; then
      delim="${BASH_REMATCH[4]}${BASH_REMATCH[5]}${BASH_REMATCH[6]}"
      if [[ "${BASH_REMATCH[2]}" == "-" ]]; then strip_tabs=1; else strip_tabs=0; fi
    fi
  done <<<"$1"
  printf '%s' "$out"
}

# words <text> — splits the simple command at the start of <text> into shell words with the
# quotes removed, stopping at an unquoted ; & | ) ` or newline. WORDS gets the words; DYN[i] is 1
# when word i contains an expansion ($var, ${...}, $(...), `...`) the hook cannot evaluate.
words() {
  local s="$1" n=${#1} i=0 c nc w="" have=0 dyn=0 q=""
  WORDS=(); DYN=()
  while [[ $i -lt $n ]]; do
    c=${s:i:1}; nc=${s:i+1:1}
    if [[ "$q" == "'" ]]; then
      if [[ "$c" == "'" ]]; then q=""; else w+=$c; fi
    elif [[ "$q" == '"' ]]; then
      case "$c" in
        '"') q="" ;;
        \\) if [[ "$nc" == "$NL" ]]; then i=$((i + 1))
            elif [[ -n "$nc" && '"\$`' == *"$nc"* ]]; then w+=$nc; i=$((i + 1))
            else w+=$c; fi ;;
        '`') dyn=1; w+=$c ;;
        '$') if is_expansion "$nc"; then dyn=1; fi; w+=$c ;;
        *) w+=$c ;;
      esac
    else
      case "$c" in
        ' '|$'\t')
          if [[ $have == 1 ]]; then WORDS+=("$w"); DYN+=("$dyn"); w=""; have=0; dyn=0; fi
          i=$((i + 1)); continue ;;
        ';'|'&'|'|'|')'|'`'|"$NL") break ;;
        "'"|'"') q=$c ;;
        \\)
          i=$((i + 2))
          if [[ "$nc" == "$NL" ]]; then continue; fi # line continuation: not part of any word
          w+=$nc; have=1; continue ;;
        '$') if is_expansion "$nc" || [[ "$nc" == "'" || "$nc" == '"' ]]; then dyn=1; fi; w+=$c ;;
        *) w+=$c ;;
      esac
    fi
    have=1; i=$((i + 1))
  done
  if [[ $have == 1 ]]; then WORDS+=("$w"); DYN+=("$dyn"); fi
}

is_expansion() { # is_expansion <char after $>
  [[ -n "$1" ]] && { [[ "$1" == [A-Za-z0-9_] ]] || [[ '{(@*#?!$-' == *"$1"* ]]; }
}

# `git` at a command position, optionally behind reserved words, prefix commands, VAR=value
# assignments and a path. The last group is the text after it.
lead='((if|then|do|else|elif|while|until|time|!|[{]|sudo|nohup|command|exec|env|xargs|nice|timeout[[:space:]]+[^[:space:]]+|[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*)[[:space:]]+)*'
git_re='(^|[;&|(`'"$NL"'])[[:space:]]*'"$lead"'([^[:space:];&|()`]*/|\\)?git([[:space:]]+(.*))?$'

g() { git -C "$dir" "$@" 2>/dev/null; } # git in the directory the push runs in
is_protected() { local p; for p in "${protected[@]}"; do [[ "$1" == "$p" ]] && return 0; done; return 1; }
protected_local() { # prints the first protected branch that exists locally
  local p
  for p in "${protected[@]}"; do g show-ref --verify --quiet "refs/heads/$p" && { echo "$p"; return 0; }; done
  return 1
}
redir_only='^[0-9]*(>|>>|<|<<<)$' # a redirection whose target is the next word
redir='^[0-9]*[<>]'               # a redirection with its target attached

blocked() { # blocked <branch> <command words>
  deny "[hook:validate-push-target] This push writes to '$1', the default branch (protected here: ${protected[*]}).

  Changes reach the default branch only through a pull request that a person merges.
  Push the Issue branch instead:  git push -u origin <branch>
  Committed on the default branch by mistake? Keep the commits on an Issue branch first:
    git switch -c <type>/#<issue>-<description>
  Blocked: $2
  See $DOC (自動検証)."
}

rest=$(strip_quoted_heredocs "$cmd")
while [[ "$rest" =~ $git_re ]]; do
  rest=${BASH_REMATCH[${#BASH_REMATCH[@]} - 1]}
  words "$rest"

  # git's own options, up to the subcommand
  dir=$cwd dir_dyn=0 push_default="" j=0
  while [[ $j -lt ${#WORDS[@]} ]]; do
    w=${WORDS[j]}
    case "$w" in
      -C)
        j=$((j + 1)); d=${WORDS[j]:-}
        [[ ${DYN[j]:-0} == 1 ]] && dir_dyn=1
        if [[ "$d" == /* ]]; then dir=$d; else dir="$dir/$d"; fi ;;
      -c)
        j=$((j + 1)); kv=${WORDS[j]:-}
        k=${kv%%=*}; k=$(printf '%s' "$k" | tr '[:upper:]' '[:lower:]')
        if [[ "$k" == "push.default" ]]; then push_default=${kv#*=}; fi ;;
      --git-dir|--work-tree|--namespace|--config-env|--super-prefix) j=$((j + 1)) ;;
      -*) ;;
      *) break ;;
    esac
    j=$((j + 1))
  done
  [[ "${WORDS[j]:-}" == "push" ]] || continue
  shown="git ${WORDS[*]}"

  # push's own options and arguments
  remote="" repo_opt="" refspecs=() refdyn=() all=0 mirror=0 delete=0 take=0 tag=0 opts_done=0
  for ((j = j + 1; j < ${#WORDS[@]}; j++)); do
    w=${WORDS[j]}
    if [[ $take == 1 ]]; then take=0; continue; fi
    if [[ $tag == 1 ]]; then tag=0; continue; fi # `tag <name>` pushes refs/tags/<name>
    if [[ "$w" =~ $redir_only ]]; then take=1; continue; fi
    if [[ "$w" =~ $redir ]]; then continue; fi
    if [[ $opts_done == 0 && "$w" == "--" ]]; then opts_done=1; continue; fi
    if [[ $opts_done == 0 && "$w" == --?* ]]; then
      case "${w%%=*}" in
        --all|--branches) all=1 ;;
        --mirror) mirror=1 ;;
        --delete) delete=1 ;;
        --repo) if [[ "$w" == *=* ]]; then repo_opt=${w#*=}; else take=1; fi ;;
        --push-option|--receive-pack|--exec) [[ "$w" == *=* ]] || take=1 ;;
      esac
      continue
    fi
    if [[ $opts_done == 0 && "$w" == -?* ]]; then
      [[ "$w" == *d* ]] && delete=1
      [[ "$w" == *o ]] && take=1
      continue
    fi
    if [[ -z "$remote" ]]; then remote=$w; continue; fi
    if [[ "$w" == "tag" ]]; then tag=1; continue; fi
    refspecs+=("$w"); refdyn+=("${DYN[j]}")
  done
  remote=${remote:-$repo_opt}

  cur=""
  if [[ $dir_dyn == 0 ]]; then cur=$(g symbolic-ref --quiet --short HEAD || true); fi
  if [[ -z "$remote" && -n "$cur" ]]; then
    remote=$(g config --get "branch.$cur.pushRemote" || g config --get remote.pushDefault || g config --get "branch.$cur.remote" || true)
  fi
  remote=${remote:-origin}
  protected=(main master)
  head=$(g symbolic-ref --quiet --short "refs/remotes/$remote/HEAD" || true)
  head=${head#"$remote"/}
  if [[ -n "$head" && "$head" != main && "$head" != master ]]; then protected+=("$head"); fi


  if [[ $mirror == 1 ]]; then blocked "${protected[0]}" "$shown"; fi
  if [[ $all == 1 ]]; then
    if p=$(protected_local); then blocked "$p" "$shown"; fi
    continue
  fi

  needs_cur=0
  [[ ${#refspecs[@]} -eq 0 ]] && needs_cur=1
  for r in "${refspecs[@]}"; do [[ $delete == 0 && ( "${r#+}" == HEAD || "${r#+}" == @ ) ]] && needs_cur=1; done
  if [[ $dir_dyn == 1 && $needs_cur == 1 ]]; then
    deny "[hook:validate-push-target] The directory of this push is built from a variable or a command substitution, so the branch it pushes cannot be checked against the default branch. Write the path and the branch literally (git push -u origin <branch>).
  Blocked: $shown"
  fi

  if [[ ${#refspecs[@]} -eq 0 ]]; then
    [[ -n "$cur" ]] || continue # detached HEAD or not a repository: git pushes nothing
    push_default=${push_default:-$(g config --get push.default || true)}
    case "${push_default:-simple}" in
      nothing) continue ;;
      matching) if p=$(protected_local); then blocked "$p" "$shown"; fi; continue ;;
      upstream|tracking) dst=$(g config --get "branch.$cur.merge" || true); dst=${dst#refs/heads/} ;;
      *) dst=$cur ;;
    esac
    if [[ -n "$dst" ]] && is_protected "$dst"; then blocked "$dst" "$shown"; fi
    continue
  fi

  for ((k = 0; k < ${#refspecs[@]}; k++)); do
    r=${refspecs[k]#+}
    if [[ ${refdyn[k]} == 1 ]]; then
      deny "[hook:validate-push-target] The refspec '$r' is built from a variable or a command substitution, so it cannot be checked against the default branch. Write the branch name literally, or use HEAD (git push -u origin HEAD).
  Blocked: $shown"
    fi
    if [[ "$r" == *:* ]]; then
      dst=${r#*:}
    elif [[ $delete == 0 && ( "$r" == HEAD || "$r" == @ ) ]]; then
      dst=$cur
    else
      dst=$r
    fi
    dst=${dst#refs/heads/}
    [[ "$dst" == refs/* ]] && continue
    if [[ -n "$dst" ]] && is_protected "$dst"; then blocked "$dst" "$shown"; fi
  done
done

exit 0
