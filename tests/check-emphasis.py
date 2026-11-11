#!/usr/bin/env python3
"""In-sentence emphasis: the procedure files must not gain `**...**` emphasis inside a sentence.

Usage: tests/check-emphasis.py [repo-root]

Why: template/.claude/rules/documentation-policy.md says to use emphasis only for the one line that
must stand out. Each PR added a few `**...**` and they passed 120 before #324 removed all but a
few; current models follow a plainly written line, and stacked emphasis makes them apply rules too
broadly (Claude Code best practices, "What you can stop doing"). A written rule alone did not stop
the growth, so this check fails CI when a new one appears (#332).

Checked files: template/CLAUDE.md and template/.claude/**/*.md. Hooks' output and the human-facing
docs (docs/, README) are not checked.

Counting (#324's, with code spans left out as #332 says): every `**...**` is in-sentence emphasis,
except these labels used as headings and these literals:
  - at the start of a line, after indentation, list markers (`-`, `*`, `+`, `1.`, `1)`) and `>`
  - at the start of any table cell, right after a `|` (spaces allowed). Every cell counts, not only
    the first one of the row; reading only the first one would also count two second-column cells
    of template/.claude/skills/issue-start/phases/01-issue-analysis.md that #324 treated as labels
  - directly followed by `:` or `：`
  - inside a code span (backticks) or a fenced code block

Allowlist: ALLOWED maps (file, phrase) to the reason it stays. Add an entry only when the sentence
states a rule that cannot be undone or that reaches outside the repository (a public repository,
a merge), and no hook or permission deny enforces it; write that reason in the entry. Otherwise
remove the `**`, or enforce the rule with a hook or a deny and then remove it. An entry whose phrase
is no longer emphasized also fails the check, so the list does not keep stale exceptions.
"""
import glob
import os
import re
import sys

ALLOWED = {
    ("template/.claude/rules/workflow-feedback.md", "公開リポジトリ"):
        "what goes into an upstream feedback Issue cannot be taken back (caches, notifications), "
        "and no hook or deny checks what the Issue body says",
}

EMPHASIS_RE = re.compile(r"\*\*(?=\S)(.+?)(?<=\S)\*\*")
CODE_SPAN_RE = re.compile(r"(`+).+?\1")
FENCE_RE = re.compile(r"^\s*(```|~~~)")
LINE_START_RE = re.compile(r"^\s*(?:(?:[-*+]|\d+[.)]|>)\s*)*$")
CELL_START_RE = re.compile(r"\|\s*$")


def in_sentence(path):
    """Yield (line number, phrase) for each in-sentence emphasis in the file."""
    fence = None
    with open(path, encoding="utf-8") as fh:
        for n, line in enumerate(fh.read().split("\n"), 1):
            m = FENCE_RE.match(line)
            if m:
                fence = None if fence == m.group(1) else (fence or m.group(1))
                continue
            if fence:
                continue
            masked = CODE_SPAN_RE.sub(lambda c: "\0" * len(c.group(0)), line)
            for e in EMPHASIS_RE.finditer(masked):
                before, after = masked[:e.start()], masked[e.end():e.end() + 1]
                if LINE_START_RE.match(before) or CELL_START_RE.search(before) or after in (":", "："):
                    continue
                yield n, e.group(1)


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
    os.chdir(root)
    files = ["template/CLAUDE.md"] + sorted(glob.glob("template/.claude/**/*.md", recursive=True))
    found = [(path, n, phrase) for path in files if os.path.isfile(path) for n, phrase in in_sentence(path)]
    new = [f for f in found if (f[0], f[2]) not in ALLOWED]
    stale = sorted(set(ALLOWED) - {(path, phrase) for path, _, phrase in found})

    for path, n, phrase in new:
        print(f"{path}:{n}: in-sentence emphasis **{phrase}**")
    for path, phrase in stale:
        print(f"{path}: allowlisted emphasis **{phrase}** no longer found; remove it from ALLOWED in tests/check-emphasis.py")
    if new:
        print("Remove the `**`, or enforce the rule with a hook or a deny. Keep it only for a rule that cannot be undone or"
              " reaches outside the repository and is not enforced; then add it to ALLOWED with that reason"
              " (see the docstring of tests/check-emphasis.py).")
    allowed = len(found) - len(new)
    print(f"check-emphasis: {len(files)} file(s), {allowed} allowlisted, {len(new)} new, {len(stale)} stale")
    return 1 if new or stale or not os.path.isfile(files[0]) else 0


if __name__ == "__main__":
    sys.exit(main())
