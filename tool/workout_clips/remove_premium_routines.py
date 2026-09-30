# -*- coding: utf-8 -*-
"""Remove workout routines built from the premium equipment clips.

Equipment clips are how-to demonstrations only, so no routine may play them.
Lists every routine whose steps reference one, then deletes them with --apply.

    python tool/workout_clips/remove_premium_routines.py
    python tool/workout_clips/remove_premium_routines.py --apply
"""

from __future__ import annotations

import argparse
import json
import sys
import time
from pathlib import Path

import requests

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

from upload_premium_equipment import load_env  # noqa: E402

CATALOG_PATH = HERE / "premium_equipment_catalog.json"
RETRIES = 15


def call(method: str, url: str, **kwargs) -> requests.Response:
    last = None
    for attempt in range(1, RETRIES + 1):
        try:
            return requests.request(method, url, timeout=60, **kwargs)
        except (requests.exceptions.SSLError, requests.exceptions.ConnectionError) as exc:
            last = exc
            time.sleep(min(20.0, 1.5 * attempt))
    raise last  # type: ignore[misc]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--only-admin", action="store_true", help="delete only routines created by admin")
    args = parser.parse_args()

    premium = {row["slug"] for row in json.loads(CATALOG_PATH.read_text(encoding="utf-8"))}
    base_url, key = load_env()
    headers = {"apikey": key, "Authorization": f"Bearer {key}"}

    matches = []
    offset = 0
    while True:
        response = call(
            "GET",
            f"{base_url}/rest/v1/routines?select=id,title,created_by,steps&order=id&limit=100&offset={offset}",
            headers=headers,
        )
        if response.status_code != 200:
            sys.exit(f"could not list routines: {response.status_code} {response.text}")
        page = response.json()
        for routine in page:
            steps = routine.get("steps") or []
            used = sorted({s.get("exercise_slug") for s in steps if s.get("exercise_slug") in premium})
            if used:
                matches.append((routine, used))
        if len(page) < 100:
            break
        offset += 100

    for routine, used in matches:
        print(f"{routine['id']}  {routine['title']!r}  by={routine.get('created_by')}  uses={len(used)}")
    print(f"\n{len(matches)} routines use equipment clips")

    if not args.apply:
        return
    if args.only_admin:
        matches = [(r, used) for r, used in matches if r.get("created_by") == "admin"]
    for routine, _ in matches:
        response = call("DELETE", f"{base_url}/rest/v1/routines?id=eq.{routine['id']}", headers=headers)
        if response.status_code not in (200, 204):
            sys.exit(f"delete failed for {routine['id']}: {response.status_code} {response.text}")
    print(f"deleted {len(matches)} routines")


if __name__ == "__main__":
    main()
