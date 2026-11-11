#!/usr/bin/env python3
"""Context budgets: the always-loaded instruction files must stay under a line budget, each
skill file under a byte limit, and all skill files together under a total byte limit.

Usage: tests/check-context-budget.py [--limit N] [--max-bytes N] [--max-total-bytes N] [repo-root]

Why: CLAUDE.md and every `.claude/rules/*.md` without a `paths:` frontmatter are loaded into
every Claude Code session. Each PR adds only a few lines, so the growth is invisible in
review until instruction adherence drops. This check turns the total into a number that CI
refuses to let drift past the budget. Raising a budget is a deliberate decision: change the
constant below and say why in the commit message (template/.claude/rules/documentation-policy.md).
These budgets cover the bare template only; projects using it aim for 1000 lines, leaving
room for their own rules (docs/customization.md "コンテキスト予算の点検").

Counting: lines of each resident file, excluding a YAML frontmatter block (`---` ... `---` at
the top). A rules file is resident when it has no frontmatter, or its frontmatter has no
`paths:`. Scoped files load on demand and are listed but not counted.

`--limit N` overrides every budget; use it to see the check fail on purpose
(`tests/check-context-budget.py --limit 100` must exit 1).

Skill file size: every Markdown file under template/.claude/skills/ (SKILL.md, phases, pitfalls)
and template/.claude/routines/ (the routine procedures, read the same way) must also stay under
SKILL_MAX_BYTES. Claude reads them on demand, often with `cat`, and the
Bash tool returns at most about 30,000 *bytes* inline (Japanese text hits it at about half the
documented 30,000 characters); a larger output is saved to a file and only a 2 KB preview comes
back (template/.claude/skills/issue-start/pitfalls.md "Bash の出力上限は、文字数ではなくバイト数で
効く"). `--max-bytes N` overrides it (`--max-bytes 1000` must exit 1).

Skill files' total: the same files together must stay at or under SKILL_TOTAL_MAX_BYTES, so that the
procedures stop growing one sentence at a time (#296). `--max-total-bytes N` overrides it
(`--max-total-bytes 1000` must exit 1).
"""
import argparse
import glob
import os
import re
import sys

BUDGETS = {
    "template (Claude Code)": {
        "limit": 400,
        "index": "template/CLAUDE.md",
        "rules_glob": "template/.claude/rules/**/*.md",
        "scope_key": "paths",  # present in frontmatter -> loads on demand
    },
}

SKILL_GLOBS = ["template/.claude/skills/**/*.md", "template/.claude/routines/*.md"]
SKILL_MAX_BYTES = 30000  # each file must be smaller than this
# All skill and routine files together must stay at or under this. The total grew 2.9x in 16 days
# (#296), one added sentence at a time; a ceiling makes an addition come with a deletion or a
# deliberate raise of this number (say why in the commit message).
# #338 raised this from 352000 to 356000 for the per-Issue model assignment's new text; #344 removed
# duplicated and outdated text from the procedures (the total went under 350000) and set it back.
SKILL_TOTAL_MAX_BYTES = 352000


def split_frontmatter(lines):
    """Return (frontmatter_lines, body_lines). No closing '---' means no frontmatter."""
    if lines and lines[0].strip() == "---":
        for j in range(1, len(lines)):
            if lines[j].strip() == "---":
                return lines[1:j], lines[j + 1:]
    return [], lines


def is_resident(frontmatter, scope_key):
    for line in frontmatter:
        if re.match(rf"^{re.escape(scope_key)}\s*:", line):
            return False  # a `paths:` key makes a rule path-scoped
    return True


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--limit", type=int, help="override every budget (for testing the failure path)")
    ap.add_argument("--max-bytes", type=int, default=SKILL_MAX_BYTES,
                    help="override the skill file size limit (for testing the failure path)")
    ap.add_argument("--max-total-bytes", type=int, default=SKILL_TOTAL_MAX_BYTES,
                    help="override the skill files' total size limit (for testing the failure path)")
    ap.add_argument("root", nargs="?", default=os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
    args = ap.parse_args()
    os.chdir(args.root)

    failed = False
    for name, budget in BUDGETS.items():
        limit = args.limit if args.limit is not None else budget["limit"]
        files = [budget["index"]] + sorted(glob.glob(budget["rules_glob"], recursive=True))
        total = 0
        rows = []
        for path in files:
            if not os.path.isfile(path):
                rows.append(("MISSING", path))
                failed = True
                continue
            with open(path, encoding="utf-8") as fh:
                lines = fh.read().splitlines()
            frontmatter, body = split_frontmatter(lines)
            if path != budget["index"] and not is_resident(frontmatter, budget["scope_key"]):
                rows.append(("on demand", path))
                continue
            total += len(body)
            rows.append((f"{len(body):4d}", path))
        status = "OK" if total <= limit else "OVER BUDGET"
        print(f"{name}: {total} / {limit} resident lines ... {status}")
        for count, path in rows:
            print(f"  {count:>9}  {path}")
        if total > limit:
            failed = True

    skills = sorted(p for g in SKILL_GLOBS for p in glob.glob(g, recursive=True))
    over = [(os.path.getsize(p), p) for p in skills if os.path.getsize(p) >= args.max_bytes]
    status = "OVER" if over else ("MISSING (no file matches SKILL_GLOBS)" if not skills else "OK")
    print(f"skill files (Claude Code): {len(over)} of {len(skills)} at or over {args.max_bytes} bytes ... {status}")
    for size, path in over:
        print(f"  {size:>9}  {path}")
    if not skills or over:
        failed = True
    total_bytes = sum(os.path.getsize(p) for p in skills)
    status = "OK" if total_bytes <= args.max_total_bytes else "OVER BUDGET"
    print(f"skill files (Claude Code): {total_bytes} / {args.max_total_bytes} bytes in total ... {status}")
    if total_bytes > args.max_total_bytes:
        failed = True

    print("check-context-budget: " + ("FAIL" if failed else "OK"))
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
