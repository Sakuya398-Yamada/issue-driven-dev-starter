#!/usr/bin/env python3
"""Every YAML frontmatter block in the template's Markdown must parse as strict YAML.

Usage: tests/check-frontmatter.py [repo-root]

Why: Claude Code reads skill, agent and rule frontmatter leniently, so an unquoted value with
": " inside (a skill description that quotes "refactor: ...") still loads there, but strict YAML
parsers and linters reject it (`mapping values are not allowed here`). Tools other than Claude
Code (linters, the projects' own checks) then cannot read the file (#297). Quote such values.

Checked: every *.md under template/ that starts with a `---` line; the block runs to the next
`---` line. Needs PyYAML (`python3-yaml` on Debian/Ubuntu).
"""
import glob
import os
import sys

try:
    import yaml
except ImportError:
    sys.exit("check-frontmatter: PyYAML is required (apt-get install python3-yaml / pip install pyyaml)")


def frontmatter(text):
    lines = text.split("\n")
    if not lines or lines[0].rstrip("\r") != "---":
        return None
    for j in range(1, len(lines)):
        if lines[j].rstrip("\r") == "---":
            return "\n".join(lines[1:j])
    return None  # no closing line: not a frontmatter block


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
    os.chdir(root)
    files = sorted(glob.glob("template/**/*.md", recursive=True) + glob.glob("template/.*/**/*.md", recursive=True))
    checked = 0
    errors = []
    for path in sorted(set(files)):
        with open(path, encoding="utf-8") as f:
            block = frontmatter(f.read())
        if block is None:
            continue
        checked += 1
        try:
            data = yaml.safe_load(block)
        except yaml.YAMLError as e:
            errors.append(f"{path}: {str(e).splitlines()[0]}")
            continue
        if data is not None and not isinstance(data, dict):
            errors.append(f"{path}: frontmatter is not a mapping")
    for e in errors:
        print(e)
    print(f"check-frontmatter: {checked} frontmatter block(s), {len(errors)} error(s)")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
