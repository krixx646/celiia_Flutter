"""Checks every locale ARB against the English source.

Silent missing translations still compile and show English to the user, so
this comparison is what catches them.

Usage: python tool/i18n/check_arb.py
Exits non-zero if anything is wrong.
"""

from __future__ import annotations

import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
L10N = os.path.join(os.path.dirname(os.path.dirname(HERE)), "lib", "l10n")

PLACEHOLDER = re.compile(r"\{(\w+)")

# Values that are legitimately identical across many languages (brand, units).
SAME_OK = {
    "appName",
    "authContinueWithGoogle",
    "authContinueWithApple",
    "playerStepCounter",
    "nutritionKcal",
    "generateSheetMinutes",
    "scannerItemCalories",
    "profileNutrition",
    "homeNutrition",
    "nutritionTitle",
    "categoryCardio",
    "categoryMindfulness",
    "categoryHiit",
    "categoryYoga",
    "navChat",
    "routineDurationMinutes",
    "scannerFieldPro",
    "scannerMacroCarb",
    "scannerMacroPro",
    "coachRep",
    "coachCountdown",
}


def load(name: str) -> dict:
    with open(os.path.join(L10N, name), encoding="utf-8") as handle:
        return json.load(handle)


def locale_files() -> list[str]:
    return sorted(
        name
        for name in os.listdir(L10N)
        if name.startswith("app_") and name.endswith(".arb") and name != "app_en.arb"
    )


def check_locale(en: dict, name: str) -> list[str]:
    other = load(name)
    en_keys = {k for k in en if not k.startswith("@")}
    other_keys = {k for k in other if not k.startswith("@")}
    problems: list[str] = []

    for key in sorted(en_keys - other_keys):
        problems.append(f"{name}: missing {key}")
    for key in sorted(other_keys - en_keys):
        problems.append(f"{name}: extra {key}")

    for key in sorted(en_keys & other_keys):
        en_places = set(PLACEHOLDER.findall(en[key]))
        other_places = set(PLACEHOLDER.findall(other[key]))
        if en_places != other_places:
            problems.append(
                f"{name}: placeholder mismatch in {key}: "
                f"en={sorted(en_places)} other={sorted(other_places)}"
            )

    return problems


def main() -> int:
    en = load("app_en.arb")
    files = locale_files()
    if not files:
        print("No locale ARB files found next to app_en.arb")
        return 1

    problems: list[str] = []
    for name in files:
        problems.extend(check_locale(en, name))

    print(f"{len(files)} locale file(s) checked against English ({len([k for k in en if not k.startswith('@')])} keys)")
    if problems:
        print(f"\n{len(problems)} problem(s):")
        for problem in problems[:80]:
            print(f"  {problem}")
        if len(problems) > 80:
            print(f"  … and {len(problems) - 80} more")
        return 1

    print("All locales complete and placeholder-consistent.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
