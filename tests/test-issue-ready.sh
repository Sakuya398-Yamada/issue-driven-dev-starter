#!/usr/bin/env bash
# Tests for the issue-ready script shipped in the template:
#   - template/.claude/scripts/issue-ready.sh
#
#   tests/test-issue-ready.sh
#
# A fake `gh` serves fixture JSON per REST endpoint and applies `--jq` with the real jq, so the
# script runs without network. Requires: bash, jq.

set -uo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
SCRIPT="$ROOT/template/.claude/scripts/issue-ready.sh"

pass=0
fail=0
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

ok()  { pass=$((pass + 1)); printf 'PASS  %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf 'FAIL  %s\n%s\n' "$1" "${2:-}"; }

# --- fake gh ---------------------------------------------------------------
# gh api <endpoint> [--jq <expr>]: serves $FX/<endpoint with / ? & = replaced by _>.json, logs the
# endpoint to $FX/calls.log, and fails like gh on a 404 when there is no fixture.
mkdir -p "$TMP/bin"
cat >"$TMP/bin/gh" <<'EOF'
#!/usr/bin/env bash
[[ "${1:-}" == api ]] || { echo "fake gh: only 'api' is supported" >&2; exit 1; }
shift
ep="" jqx=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --jq) jqx="$2"; shift 2 ;;
    -*) shift ;;
    *) ep="$1"; shift ;;
  esac
done
ep=${ep//"{owner}/{repo}"/o/r}
printf '%s\n' "$ep" >>"$FX/calls.log"
f="$FX/$(printf '%s' "$ep" | tr '/?&=' '____').json"
[[ -f "$f" ]] || { echo "gh: Not Found (HTTP 404)" >&2; exit 1; }
if [[ -n "$jqx" ]]; then "${FAKE_JQ:-jq}" -r "$jqx" "$f"; else cat "$f"; fi
EOF
chmod +x "$TMP/bin/gh"

# fx <dir> <endpoint> <json>: write one fixture
fx() { printf '%s\n' "$3" >"$1/$(printf '%s' "$2" | tr '/?&=' '____').json"; }

# issue <repo> <number> <title> <labels csv> <body> [sub_total sub_done total_blocked_by state state_reason]
issue() {
  jq -cn --arg repo "$1" --argjson n "$2" --arg t "$3" --arg l "$4" --arg b "$5" \
    --argjson st "${6:-0}" --argjson sd "${7:-0}" --argjson tb "${8:-0}" \
    --arg s "${9:-open}" --arg sr "${10:-}" '{
      id: (1000 + $n), number: $n, title: $t, body: $b, state: $s,
      state_reason: (if $sr == "" then null else $sr end),
      repository_url: ("https://api.github.com/repos/" + $repo),
      labels: ($l | split(",") | map(select(. != "") | {name: .})),
      sub_issues_summary: {total: $st, completed: $sd, percent_completed: 0},
      issue_dependencies_summary: {blocked_by: 0, total_blocked_by: $tb, blocking: 0, total_blocking: 0}
    }'
}

# run <fixture dir> <args...>: run the script with the fake gh; sets out / rc
run() {
  local dir="$1"; shift
  : >"$dir/calls.log"
  out=$(FX="$dir" PATH="$TMP/bin:$PATH" bash "$SCRIPT" "$@" 2>&1)
  rc=$?
}

# --- file mode -------------------------------------------------------------
echo "## File mode"
if [[ -x "$SCRIPT" ]]; then ok "the script is executable"; else bad "template/.claude/scripts/issue-ready.sh is not executable"; fi

# --- main scenario ---------------------------------------------------------
echo "## Classification (repository o/r)"
M="$TMP/main"; mkdir -p "$M"
fx "$M" "repos/o/r" '{"full_name":"o/r"}'
items=(
  "$(issue o/r 1 'meta: 知見ボード' meta '依存: #10')"
  "$(issue o/r 10 'ready A' feature '')"
  "$(issue o/r 11 'blocked B' feature $'## 関連Issue\n依存: #10' 0 0 1)"
  "$(issue o/r 12 'body only' bug $'## 関連Issue\n- 依存: #10')"
  "$(issue o/r 13 'relation only, closed' feature '' 0 0 1)"
  "$(issue o/r 14 'not planned dep' feature '依存: #6' 0 0 1)"
  "$(issue o/r 15 'missing dep' feature '依存: #999')"
  "$(issue o/r 16 'prose only' docs $'本文で「依存: #10」と書いた\n依存: other/x#10')"
  "$(issue o/r 17 'external blocker' feature '' 0 0 1)"
  "$(issue o/r 18 'parent' feature '' 2 1)"
  "$(issue o/r 20 'full-width colon, closed' feature '依存：#8')"
  "$(issue o/r 21 'self' feature '依存: #21')"
  '{"number":30,"title":"a pull request","pull_request":{"url":"x"},"labels":[],"body":"依存: #10"}'
)
page=$(printf '%s\n' "${items[@]}" | jq -cs 'sort_by(-.number)')  # newest first, like the API
fx "$M" "repos/o/r/issues?state=open&per_page=100&page=1" "$page"
fx "$M" "repos/o/r/issues/11/dependencies/blocked_by?per_page=100" "[$(issue o/r 10 'ready A' feature '')]"
fx "$M" "repos/o/r/issues/13/dependencies/blocked_by?per_page=100" "[$(issue o/r 5 'done' feature '' 0 0 0 closed completed)]"
fx "$M" "repos/o/r/issues/14/dependencies/blocked_by?per_page=100" "[$(issue o/r 6 'dropped' feature '' 0 0 0 closed not_planned)]"
fx "$M" "repos/o/r/issues/17/dependencies/blocked_by?per_page=100" "[$(issue x/y 7 'elsewhere' feature '')]"
fx "$M" "repos/o/r/issues/8" "$(issue o/r 8 'done too' feature '' 0 0 0 closed completed)"

run "$M" --repo o/r
want="## 着手できる (7)
- #10 ready A（塞いでいる: #11 #12）
- #13 relation only, closed
- #14 not planned dep
- #15 missing dep
- #16 prose only
- #20 full-width colon, closed
- #21 self
## 依存待ち (3)
- #11 blocked B ← #10
- #12 body only ← #10
- #17 external blocker ← x/y#7
## 親（子の完了待ち） (1)
- #18 parent（sub-issue 1/2 完了）
## 注意 (6)
- #12: 本文だけにある依存: #10 / blocked by だけにある依存: なし
- #13: 本文だけにある依存: なし / blocked by だけにある依存: #5
- #14: 依存 #6 は not_planned で閉じている（依存した変更は入っていない）
- #15: 依存 #999 が見つからない
- #15: 本文だけにある依存: #999 / blocked by だけにある依存: なし
- #20: 本文だけにある依存: #8 / blocked by だけにある依存: なし"
if [[ $rc == 0 && "$out" == "$want" ]]; then ok "human-readable output"; else bad "human-readable output (rc=$rc)" "$(diff <(printf '%s\n' "$want") <(printf '%s\n' "$out"))"; fi

calls=$(cat "$M/calls.log")
if grep -qxF 'repos/o/r/issues/11/dependencies/blocked_by?per_page=100' <<<"$calls" &&
   ! grep -qF 'issues/12/dependencies' <<<"$calls" && ! grep -qF 'issues/10/dependencies' <<<"$calls"; then
  ok "blocked-by is read only for Issues whose summary has total_blocked_by > 0"
else bad "blocked-by calls" "$calls"; fi
if grep -qxF 'repos/o/r/issues/8' <<<"$calls" && grep -qxF 'repos/o/r/issues/999' <<<"$calls" &&
   ! grep -qxF 'repos/o/r/issues/10' <<<"$calls" && ! grep -qxF 'repos/o/r/issues/5' <<<"$calls"; then
  ok "only body-only dependencies that are not open are fetched one by one"
else bad "per-Issue fetches" "$calls"; fi

run "$M" --repo o/r --json
if ! jq -e . >/dev/null 2>&1 <<<"$out"; then
  bad "--json prints valid JSON (rc=$rc)" "$out"
else
  ok "--json prints valid JSON"
  check() { # check <description> <jq expression that must be true>
    if jq -e "$2" >/dev/null <<<"$out"; then ok "$1"; else bad "$1" "$(jq -c "$2" <<<"$out")"; fi
  }
  check "repo is the full name" '.repo == "o/r" and .notes == []'
  check "meta Issue and pull request are left out" '[.issues[].number] == [10,11,12,13,14,15,16,17,18,20,21]'
  check "ready Issue lists what it blocks" '.issues[] | select(.number == 10) | .status == "ready" and .blocking == [11,12] and .labels == ["feature"]'
  check "blocked by an open Issue in both sources" '.issues[] | select(.number == 11) | .status == "blocked" and .blocked_by == [10] and .body_only == [] and .relation_only == [] and .notes == []'
  check "body-only dependency still blocks and is reported" '.issues[] | select(.number == 12) | .status == "blocked" and .body_only == [10] and (.notes | length) == 1'
  check "relation-only closed dependency is reported" '.issues[] | select(.number == 13) | .status == "ready" and .relation_only == [5]'
  check "not_planned dependency is noted" '.issues[] | select(.number == 14) | .status == "ready" and (.notes[0] | contains("not_planned"))'
  check "missing dependency is noted" '.issues[] | select(.number == 15) | .notes[0] == "依存 #999 が見つからない"'
  check "prose and owner/repo#N are not dependencies" '.issues[] | select(.number == 16) | .status == "ready" and .body_only == [] and .notes == []'
  check "open blocker in another repository" '.issues[] | select(.number == 17) | .status == "blocked" and .blocked_by == [] and .external_blocked_by == ["x/y#7"] and .notes == []'
  check "parent with sub-issues" '.issues[] | select(.number == 18) | .status == "parent" and .sub_issues == {"total":2,"completed":1}'
  check "full-width colon counts" '.issues[] | select(.number == 20) | .body_only == [8]'
  check "self-dependency is ignored" '.issues[] | select(.number == 21) | .status == "ready" and .notes == []'
fi

# --- chains, order by blocking count, closed external blocker --------------------
echo "## Chains and order"
C="$TMP/chain"; mkdir -p "$C"
fx "$C" "repos/o/r" '{"full_name":"o/r"}'
fx "$C" "repos/o/r/issues?state=open&per_page=100&page=1" "$( {
  issue o/r 1 one feature ''
  issue o/r 2 two feature ''
  issue o/r 3 three feature '依存: #1'
  issue o/r 4 four feature '依存: #2'
  issue o/r 5 five feature '依存: #2'
  issue o/r 6 six feature '依存: #3'
  issue o/r 7 parent feature '' 2 0
  issue o/r 8 eight feature '依存: #7'
  issue o/r 9 'closed external' feature '' 0 0 1
} | jq -cs 'sort_by(-.number)')"
fx "$C" "repos/o/r/issues/9/dependencies/blocked_by?per_page=100" "[$(issue x/y 3 'done elsewhere' feature '' 0 0 0 closed completed)]"
run "$C" --repo o/r
want="## 着手できる (3)
- #2 two（塞いでいる: #4 #5）
- #1 one（塞いでいる: #3）
- #9 closed external
## 依存待ち (5)
- #3 three ← #1（塞いでいる: #6）
- #4 four ← #2
- #5 five ← #2
- #6 six ← #3
- #8 eight ← #7
## 親（子の完了待ち） (1)
- #7 parent（sub-issue 0/2 完了、塞いでいる: #8）"
got=$(sed '/^## 注意/,$d' <<<"$out")
if [[ $rc == 0 && "$got" == "$want" ]]; then ok "most-blocking first; blocked and parent lines show what they block; closed external blocker does not block"; else bad "chains (rc=$rc)" "$(diff <(printf '%s\n' "$want") <(printf '%s\n' "$got"))"; fi

# --- titles that need JSON escaping ------------------------------------------
echo "## Titles with quotes and backslashes"
Q="$TMP/quote"; mkdir -p "$Q"
fx "$Q" "repos/o/r" '{"full_name":"o/r"}'
fx "$Q" "repos/o/r/issues?state=open&per_page=100&page=1" "[$(issue o/r 2 'say "hi" \ tab	end' bug '')]"
run "$Q" --repo o/r --json
if jq -e '.issues[0].title == "say \"hi\" \\ tab\tend"' >/dev/null 2>&1 <<<"$out"; then ok "title is escaped in JSON"; else bad "title escaping" "$out"; fi

# --- pagination ---------------------------------------------------------------
echo "## Pagination (page 1 has 100 items including a pull request)"
P="$TMP/page"; mkdir -p "$P"
fx "$P" "repos/o/r" '{"full_name":"o/r"}'
p1=$( { for n in $(seq 1 99); do issue o/r "$n" "issue $n" feature ''; done
        printf '%s\n' '{"number":100,"title":"pr","pull_request":{},"labels":[]}'; } | jq -cs .)
fx "$P" "repos/o/r/issues?state=open&per_page=100&page=1" "$p1"
fx "$P" "repos/o/r/issues?state=open&per_page=100&page=2" "[$(issue o/r 101 'last' feature '依存: #1')]"
run "$P" --repo o/r --json
if jq -e '(.issues | length) == 100 and (.issues[] | select(.number == 101) | .status == "blocked" and .blocked_by == [1]) and (.issues[] | select(.number == 1) | .blocking == [101])' >/dev/null 2>&1 <<<"$out"; then
  ok "page 2 is read and joined with page 1"
else bad "pagination" "$(head -c 400 <<<"$out")"; fi
if ! grep -qF 'page=3' "$P/calls.log"; then ok "page 3 is not requested after a short page"; else bad "requested page 3" "$(cat "$P/calls.log")"; fi

# --- no dependency summary (e.g. GitHub Enterprise Server without the feature) ---
echo "## No issue_dependencies_summary in the API"
G="$TMP/ghes"; mkdir -p "$G"
fx "$G" "repos/o/r" '{"full_name":"o/r"}'
fx "$G" "repos/o/r/issues?state=open&per_page=100&page=1" "$( { issue o/r 1 'base' feature ''; issue o/r 2 'next' feature '依存: #1'; } | jq -cs 'map(del(.issue_dependencies_summary))')"
run "$G" --repo o/r
want="## 着手できる (1)
- #1 base（塞いでいる: #2）
## 依存待ち (1)
- #2 next ← #1
## 親（子の完了待ち） (0)
## 注意 (1)
- blocked by を API から読めない Issue がある（本文の「依存:」だけで判定した）"
if [[ $rc == 0 && "$out" == "$want" ]]; then ok "body only, one note, no mismatch notes"; else bad "no summary (rc=$rc)" "$(diff <(printf '%s\n' "$want") <(printf '%s\n' "$out"))"; fi

# --- empty repository, default repo, errors -------------------------------------
echo "## Empty repository, default repository, errors"
E="$TMP/empty"; mkdir -p "$E"
fx "$E" "repos/o/r" '{"full_name":"o/r"}'
fx "$E" "repos/o/r/issues?state=open&per_page=100&page=1" '[]'
run "$E"
want="## 着手できる (0)
## 依存待ち (0)
## 親（子の完了待ち） (0)
## 注意 (0)"
if [[ $rc == 0 && "$out" == "$want" ]]; then ok "no open Issues, {owner}/{repo} by default"; else bad "empty repository (rc=$rc)" "$out"; fi
run "$E" --json
if [[ $rc == 0 && "$out" == '{"repo":"o/r","notes":[],"issues":[]}' ]]; then ok "no open Issues as JSON"; else bad "empty JSON (rc=$rc)" "$out"; fi

# Only bash, gh and a few coreutils on PATH: no jq, node or python3 (the fake gh stands in for
# gh's built-in jq with an absolute path).
mkdir -p "$TMP/min"
for b in bash env cat tr sed sort cut grep; do ln -sf "$(command -v "$b")" "$TMP/min/$b"; done
ln -sf "$TMP/bin/gh" "$TMP/min/gh"
: >"$M/calls.log"
out=$(FX="$M" FAKE_JQ="$(command -v jq)" PATH="$TMP/min" "$BASH" "$SCRIPT" --repo o/r 2>&1); rc=$?
if [[ $rc == 0 && "$out" == *"- #11 blocked B ← #10"* ]] && ! PATH="$TMP/min" command -v jq node python3 >/dev/null 2>&1; then
  ok "runs with bash and gh only (no jq, node or python3 on PATH)"
else bad "minimal PATH (rc=$rc)" "$out"; fi

out=$(PATH="$TMP/nowhere" "$BASH" "$SCRIPT" 2>&1); rc=$?
if [[ $rc == 1 && "$out" == *"gh (GitHub CLI) is required"* ]]; then ok "exit 1 without gh"; else bad "without gh (rc=$rc)" "$out"; fi
run "$E" --bogus
if [[ $rc == 2 ]]; then ok "exit 2 on an unknown option"; else bad "unknown option (rc=$rc)" "$out"; fi
run "$E" --help
if [[ $rc == 0 && "$out" == *"Usage: issue-ready.sh"* && "$out" != *"set -euo"* ]]; then ok "--help prints the header only"; else bad "--help (rc=$rc)" "$out"; fi

echo
echo "passed=$pass failed=$fail"
[[ "$fail" -eq 0 ]]
