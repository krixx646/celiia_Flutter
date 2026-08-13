"""Lists the user-facing English still hardcoded in the Dart sources.

Translating an app is mostly a bookkeeping problem: the risk is not getting a
phrase wrong, it is missing one entirely and leaving a stray English label in
the middle of a Spanish screen. This walks lib/ and reports every string
literal sitting somewhere the user can read it, grouped by file, so the ARB
files can be written against the real inventory instead of a guess.

Run again after the conversion: anything it still reports is a string that
never made it into the translations.

Usage: python tool/i18n/extract_strings.py [--summary]
"""

import os
import re
import sys

ROOT = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), "lib")

# Where a literal is read by a human. Widget text, form labels, buttons,
# dialogs, snackbars, tooltips and the like.
PATTERNS = [
    re.compile(r"""\bText\(\s*(['"])(.*?)\1""", re.S),
    re.compile(r"""\b(?:labelText|hintText|helperText|errorText|tooltip|semanticLabel|message|title|subtitle|label|placeholder)\s*:\s*(['"])(.*?)\1""", re.S),
    re.compile(r"""SnackBar\([^)]*content:\s*Text\(\s*(['"])(.*?)\1""", re.S),
]

# Literals that are never shown: identifiers, routes, asset paths, keys.
SKIP = re.compile(
    r"^(?:$|\s*$|[a-z_]+/[a-z_/]+|assets/|https?://|[a-z_]+\.(?:png|jpg|svg|json|mp4)$|#[0-9a-fA-F]{3,8}$)"
)


def looks_translatable(text: str) -> bool:
    if SKIP.match(text):
        return False
    if not re.search(r"[A-Za-z]", text):
        return False
    # A single lowercase token is almost always a key or an enum value, not a
    # sentence someone reads.
    if re.fullmatch(r"[a-z0-9_]+", text):
        return False
    return True


def main() -> int:
    summary = "--summary" in sys.argv
    total = 0
    by_file = {}

    for folder, _dirs, files in os.walk(ROOT):
        for name in sorted(files):
            if not name.endswith(".dart") or name.endswith(".g.dart"):
                continue
            path = os.path.join(folder, name)
            with open(path, encoding="utf-8") as handle:
                source = handle.read()

            found = []
            for pattern in PATTERNS:
                for match in pattern.finditer(source):
                    text = match.group(2).strip()
                    if looks_translatable(text) and text not in found:
                        found.append(text)

            if found:
                rel = os.path.relpath(path, ROOT).replace("\\", "/")
                by_file[rel] = found
                total += len(found)

    for rel in sorted(by_file, key=lambda k: -len(by_file[k])):
        strings = by_file[rel]
        print(f"\n{rel}  ({len(strings)})")
        if not summary:
            for text in strings:
                print(f"    {text}")

    print(f"\n{total} strings across {len(by_file)} files")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
