# -*- coding: utf-8 -*-
"""Put the original, untrimmed premium equipment clips back in storage.

These clips are full how-to demonstrations. They are shown once from start to
finish in the app's how-to section and must never be cut into loops.

    python tool/workout_clips/restore_premium_originals.py
    python tool/workout_clips/restore_premium_originals.py --start 40
"""

from __future__ import annotations

import argparse
import json
import sys
import tempfile
import time
from pathlib import Path

import requests

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

from upload_premium_equipment import (  # noqa: E402
    DEFAULT_ROOT,
    find_premium_root,
    load_env,
    probe_seconds,
    upload as upload_once,
    write_poster,
)

CATALOG_PATH = HERE / "premium_equipment_catalog.json"
RETRIES = 15


def with_retry(label: str, action):
    last = None
    for attempt in range(1, RETRIES + 1):
        try:
            return action()
        except Exception as exc:
            last = exc
            print(f"retry {attempt}/{RETRIES} for {label}: {exc}", flush=True)
            time.sleep(min(30.0, 1.5 * attempt))
    raise last  # type: ignore[misc]


def patch_clip(base_url: str, key: str, slug: str, patch: dict) -> None:
    response = requests.patch(
        f"{base_url}/rest/v1/exercise_clips?slug=eq.{slug}",
        headers={
            "Authorization": f"Bearer {key}",
            "apikey": key,
            "Content-Type": "application/json",
            "Prefer": "return=minimal",
        },
        json=patch,
        timeout=60,
    )
    if response.status_code not in (200, 204):
        raise RuntimeError(f"{response.status_code} {response.text}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    parser.add_argument("--start", type=int, default=0, help="0-based index to resume from")
    parser.add_argument("--slugs", nargs="*", help="only restore these slugs")
    args = parser.parse_args()

    catalog = json.loads(CATALOG_PATH.read_text(encoding="utf-8"))[args.start :]
    if args.slugs:
        catalog = [item for item in catalog if item["slug"] in set(args.slugs)]
    premium = find_premium_root(args.root)
    base_url, key = load_env()
    temp_dir = Path(tempfile.mkdtemp(prefix="celia-premium-restore-"))
    done = 0
    failed: list[str] = []

    for index, item in enumerate(catalog, start=args.start + 1):
        source = premium / item["file"]
        if not source.exists():
            print(f"[{index}] missing original {item['file']}")
            continue

        try:
            with_retry(
                f"{item['slug']}.mp4",
                lambda: upload_once(base_url, key, f"{item['slug']}.mp4", source),
            )
            patch = {"clip_seconds": probe_seconds(source)}
            poster_path = temp_dir / f"{item['slug']}.jpg"
            if write_poster(source, poster_path):
                try:
                    patch["poster_url"] = with_retry(
                        f"{item['slug']}.jpg",
                        lambda: upload_once(base_url, key, f"{item['slug']}.jpg", poster_path),
                    )
                except Exception as exc:
                    print(f"[{index}] poster skipped for {item['slug']}: {exc}", flush=True)
            with_retry(item["slug"], lambda: patch_clip(base_url, key, item["slug"], patch))
        except Exception as exc:
            failed.append(item["slug"])
            print(f"[{index}] FAILED {item['slug']}: {exc}", flush=True)
            continue
        done += 1
        print(f"[{index}] restored {item['slug']} ({patch['clip_seconds']}s)", flush=True)

    print(f"\nrestored {done} original clips")
    if failed:
        print("failed: " + " ".join(failed))


if __name__ == "__main__":
    main()
