#!/usr/bin/env python3
"""Cross-reference check: every file path mentioned in the repository's Markdown must exist.

Usage: tests/check-refs.py [repo-root]

Why: the templates and docs cite each other by path (rules, phases, hooks, workflows).
A rename that misses one citation silently breaks the workflow for Claude/Copilot,
which follow those paths literally.

Resolution roots for a path found in a Markdown file:
  - files under template/          -> template/            (+ .claude/ and the issue-start skill dir as shorthand)
  - files under template-copilot/  -> template-copilot/    (+ .github/ and the issue-start skill dir as shorthand)
  - README / docs                  -> repo root, then both templates and their shorthand roots
Paths starting with 'template/' or 'template-copilot/' always resolve from the repo root.
A bare file name (no '/') is accepted when any file with that name exists in the repository.
"""
import glob
import os
import re
import sys

ROOT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
os.chdir(ROOT)

PATH_RE = re.compile(r"`([A-Za-z0-9_./-]+\.(?:md|sh|json|yml|yaml|txt))`")
DIR_RE = re.compile(r"`((?:\.claude|\.github|\.githooks|docs|phases|template|template-copilot)/[A-Za-z0-9_./-]*/)`")
LINK_RE = re.compile(r"\]\(([^)#\s]+)(?:#[^)]*)?\)")

# Paths that are examples, or files the *user's* project provides rather than this repository.
ALLOW = {
    "path/to/file.ts", "src/data/items.ts", "src/.../big-file.ts", "user-data.ts", "file.txt", "notes.txt",
    "AGENTS.md", "SPEC.md", "REVIEW.md", "NOTES.md", "package.json", "msg.txt",
    ".vscode/mcp.json", ".github/workflows/copilot-setup-steps.yml", ".claude/settings.local.json",
    "node_modules/", "src/", ".claude/worktrees/",
    # cited from inside the templates, but lives in the upstream (this) repository root
    ".github/ISSUE_TEMPLATE/template-feedback.md",
    # removed files named in migration notes, and a placeholder pattern
    ".github/prompts/issue-start.prompt.md", "issue-plan.prompt.md", "docs/migration-vN.md",
}

ROOTS = {
    "template/": ["template/", "template/.claude/", "template/.claude/skills/issue-start/"],
    "template-copilot/": ["template-copilot/", "template-copilot/.github/", "template-copilot/.github/skills/issue-start/"],
}


def roots_for(md: str):
    for prefix, roots in ROOTS.items():
        if md.startswith(prefix):
            return roots
    return [""] + ROOTS["template/"] + ROOTS["template-copilot/"]


def resolves(path: str, md: str) -> bool:
    if path.startswith(("http://", "https://", "mailto:")):
        return True
    if path in ALLOW or "<" in path or "*" in path or "..." in path or path.endswith((".ts", ".tsx")):
        return True
    if path.startswith(("template/", "template-copilot/")):
        return os.path.exists(path)
    if md.startswith("docs/"):
        rel = os.path.normpath(os.path.join("docs", path))
        if os.path.exists(rel):
            return True
    for root in roots_for(md):
        if os.path.exists(os.path.join(root, path)):
            return True
    if "/" not in path and any(os.path.basename(f) == path for f in ALL_FILES):
        return True
    return False


ALL_FILES = [f for f in glob.glob("**/*", recursive=True, include_hidden=True)
             if os.path.isfile(f) and not f.startswith((".git/", "node_modules/"))]

problems = 0
for md in sorted(glob.glob("**/*.md", recursive=True, include_hidden=True)):
    if md.startswith((".git/", "node_modules/")):
        continue
    text = open(md, encoding="utf-8").read()
    refs = set(PATH_RE.findall(text)) | set(DIR_RE.findall(text)) | set(LINK_RE.findall(text))
    for ref in sorted(refs):
        if not resolves(ref, md):
            print(f"{md}: unresolved path reference -> {ref}")
            problems += 1

print(f"check-refs: {problems} unresolved reference(s)")
sys.exit(1 if problems else 0)
