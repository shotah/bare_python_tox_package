#!/usr/bin/env python3
"""Bump __version__ in src/hello_world/__init__.py (semver X.Y.Z only)."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INIT = ROOT / "src" / "hello_world" / "__init__.py"
VERSION_RE = re.compile(
    r'^(__version__\s*=\s*)(["\'])([^"\']+)(["\'])',
    re.MULTILINE,
)


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument(
        "kind",
        nargs="?",
        default="patch",
        choices=("patch", "minor", "major"),
        help="Which part to increment (default: patch)",
    )
    p.add_argument(
        "-q",
        "--quiet",
        action="store_true",
        help="Update file only; print the new version once (for CI automation)",
    )
    return p.parse_args()


def bump_semver(current: str, kind: str) -> str:
    parts = current.split(".")
    if len(parts) != 3 or not all(p.isdigit() for p in parts):
        msg = f"Version {current!r} must be semver X.Y.Z with numeric segments"
        raise SystemExit(msg)
    major, minor, patch = (int(parts[0]), int(parts[1]), int(parts[2]))
    if kind == "patch":
        return f"{major}.{minor}.{patch + 1}"
    if kind == "minor":
        return f"{major}.{minor + 1}.0"
    if kind == "major":
        return f"{major + 1}.0.0"
    raise SystemExit(f"Unknown kind: {kind!r}")


def main() -> None:
    args = parse_args()
    text = INIT.read_text(encoding="utf-8")
    m = VERSION_RE.search(text)
    if not m:
        sys.exit(f"Could not find __version__ in {INIT}")

    current = m.group(3)
    new_ver = bump_semver(current, args.kind)

    def _repl(match: re.Match[str]) -> str:
        return f"{match.group(1)}{match.group(2)}{new_ver}{match.group(4)}"

    new_text = VERSION_RE.sub(_repl, text, count=1)
    INIT.write_text(new_text, encoding="utf-8", newline="\n")

    if args.quiet:
        print(new_ver)
        return

    print(f"Bumped {current} -> {new_ver}")
    print()
    print("Suggested next steps:")
    print(
        f'  git add src/hello_world/__init__.py && git commit -m "Bump version to {new_ver}" && git push'
    )
    print(
        "  Push a feature branch for CI patch bump, or merge to main for Release; on main only, bump locally before push."
    )


if __name__ == "__main__":
    main()
