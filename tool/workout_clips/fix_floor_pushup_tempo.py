# -*- coding: utf-8 -*-
"""Upload a slowed floor-push-up demo and update exercise_clips metadata."""

from __future__ import annotations

import os
import sys

import requests

HERE = os.path.dirname(__file__)
ENV_PATH = os.path.join(HERE, "..", "..", "celia-admin", ".env.local")
BUCKET = "exercise-clips"
SLUG = "floor-push-up"
CLIP_SECONDS = 3.1


def load_env() -> tuple[str, str]:
    values: dict[str, str] = {}
    with open(ENV_PATH, encoding="utf-8") as handle:
        for line in handle:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                key, value = line.split("=", 1)
                values[key.strip()] = value.strip()
    url = values.get("NEXT_PUBLIC_SUPABASE_URL")
    key = values.get("SUPABASE_SERVICE_ROLE_KEY")
    if not url or not key:
        sys.exit("missing Supabase env in celia-admin/.env.local")
    return url.rstrip("/"), key


def main() -> None:
    path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(
        os.environ.get("TEMP", "/tmp"), "floor-push-up-slow.mp4"
    )
    if not os.path.exists(path):
        sys.exit(f"missing slowed clip: {path}")

    base_url, key = load_env()
    headers = {"Authorization": f"Bearer {key}", "apikey": key}

    with open(path, "rb") as handle:
        upload = requests.post(
            f"{base_url}/storage/v1/object/{BUCKET}/{SLUG}.mp4",
            headers={
                **headers,
                "Content-Type": "video/mp4",
                "x-upsert": "true",
            },
            data=handle,
            timeout=300,
        )
    print("upload", upload.status_code, upload.text[:200])
    upload.raise_for_status()

    # Cache-bust so already-installed apps reload the new bytes.
    video_url = (
        f"{base_url}/storage/v1/object/public/{BUCKET}/{SLUG}.mp4?v=slow-3p1"
    )
    patch = requests.patch(
        f"{base_url}/rest/v1/exercise_clips?slug=eq.{SLUG}",
        headers={
            **headers,
            "Content-Type": "application/json",
            "Prefer": "return=representation",
        },
        json={
            "clip_seconds": CLIP_SECONDS,
            "reps_per_loop": 1,
            "video_url": video_url,
        },
        timeout=60,
    )
    print("patch", patch.status_code, patch.text[:500])
    patch.raise_for_status()
    print("done")


if __name__ == "__main__":
    main()
