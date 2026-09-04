# -*- coding: utf-8 -*-
"""Upload the client's demo clips to Supabase and seed the exercise_clips table.

Reads the manifest produced by analyze_clips.py and the reviewed facts in
clip_overrides.json, pushes each clip plus a generated poster frame to public
storage, and upserts one row per exercise.

Safe to re-run: storage uploads overwrite by path and rows upsert on slug, so
a failed run can simply be repeated.

    python tool/workout_clips/upload_clips.py --root "<clips folder>"
    python tool/workout_clips/upload_clips.py --root "<clips folder>" --dry-run
"""

from __future__ import annotations

import argparse
import json
import mimetypes
import os
import sys
import tempfile

import cv2
import requests

HERE = os.path.dirname(__file__)
ENV_PATH = os.path.join(HERE, "..", "..", "celia-admin", ".env.local")
MANIFEST_PATH = os.path.join(HERE, "clip_manifest.json")
OVERRIDES_PATH = os.path.join(HERE, "clip_overrides.json")
LOOPS_PATH = os.path.join(HERE, "clip_loops.json")

BUCKET = "exercise-clips"

# The client's folder names mapped to the movement patterns the routine
# generator reasons about.
PATTERNS = {
    "01_Squat": "squat",
    "02_Hinge": "hinge",
    "03_Lunge": "lunge",
    "04_Push": "push",
    "05_Pull": "pull",
    "06_Carry": "carry",
    "07_Core_Rotation": "core",
    "08_Recovery": "recovery",
}

# Far enough in to clear any fade-in, early enough to show the starting
# position rather than the middle of a rep.
POSTER_POSITION = 0.15


def load_env() -> tuple[str, str]:
    if not os.path.exists(ENV_PATH):
        sys.exit(f"missing {ENV_PATH}")

    values = {}
    with open(ENV_PATH, encoding="utf-8") as handle:
        for line in handle:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                key, value = line.split("=", 1)
                values[key.strip()] = value.strip()

    url = values.get("NEXT_PUBLIC_SUPABASE_URL")
    key = values.get("SUPABASE_SERVICE_ROLE_KEY")
    if not url or not key:
        sys.exit("NEXT_PUBLIC_SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set in celia-admin/.env.local")
    return url.rstrip("/"), key


def ensure_bucket(base_url: str, key: str) -> None:
    headers = {"Authorization": f"Bearer {key}", "apikey": key}
    existing = requests.get(f"{base_url}/storage/v1/bucket/{BUCKET}", headers=headers, timeout=30)
    if existing.status_code == 200:
        return

    created = requests.post(
        f"{base_url}/storage/v1/bucket",
        headers={**headers, "Content-Type": "application/json"},
        json={"id": BUCKET, "name": BUCKET, "public": True},
        timeout=30,
    )
    if created.status_code not in (200, 201):
        sys.exit(f"could not create bucket: {created.status_code} {created.text}")
    print(f"created public bucket {BUCKET}")


def write_poster(video_path: str, out_path: str) -> bool:
    cap = cv2.VideoCapture(video_path)
    total = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    cap.set(cv2.CAP_PROP_POS_FRAMES, max(0, int(total * POSTER_POSITION)))
    ok, frame = cap.read()
    cap.release()
    if ok:
        cv2.imwrite(out_path, frame, [cv2.IMWRITE_JPEG_QUALITY, 85])
    return ok


def upload(base_url: str, key: str, object_path: str, file_path: str) -> str:
    content_type = mimetypes.guess_type(file_path)[0] or "application/octet-stream"
    with open(file_path, "rb") as handle:
        response = requests.post(
            f"{base_url}/storage/v1/object/{BUCKET}/{object_path}",
            headers={
                "Authorization": f"Bearer {key}",
                "apikey": key,
                "Content-Type": content_type,
                # Overwrite instead of failing, so the script can be re-run.
                "x-upsert": "true",
            },
            data=handle,
            timeout=300,
        )
    if response.status_code not in (200, 201):
        raise RuntimeError(f"upload failed for {object_path}: {response.status_code} {response.text}")
    return f"{base_url}/storage/v1/object/public/{BUCKET}/{object_path}"


def seed(base_url: str, key: str, rows: list[dict]) -> None:
    response = requests.post(
        f"{base_url}/rest/v1/exercise_clips?on_conflict=slug",
        headers={
            "Authorization": f"Bearer {key}",
            "apikey": key,
            "Content-Type": "application/json",
            "Prefer": "resolution=merge-duplicates,return=minimal",
        },
        json=rows,
        timeout=120,
    )
    if response.status_code not in (200, 201, 204):
        sys.exit(f"seed failed: {response.status_code} {response.text}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", required=True)
    parser.add_argument("--dry-run", action="store_true", help="Build the rows and print them without touching Supabase")
    parser.add_argument("--manifest", default=MANIFEST_PATH)
    parser.add_argument("--overrides", default=OVERRIDES_PATH)
    parser.add_argument("--loops", default=LOOPS_PATH)
    parser.add_argument(
        "--source",
        default="client_clip_pack_v1",
        help="Value written to exercise_clips.source",
    )
    args = parser.parse_args()

    if not os.path.exists(args.manifest):
        sys.exit(f"missing manifest: {args.manifest}")

    with open(args.manifest, encoding="utf-8") as handle:
        manifest = json.load(handle)
    with open(args.overrides, encoding="utf-8") as handle:
        overrides = json.load(handle)

    # make_loops.py trims most clips to a single rep so they loop without a
    # visible cut, which changes both their length and how many reps one play
    # is worth. Where it has run, its numbers describe the file being uploaded
    # and the manifest's describe the untrimmed original, so they win.
    loops = {}
    if os.path.exists(args.loops):
        with open(args.loops, encoding="utf-8") as handle:
            loops = {item["slug"]: item for item in json.load(handle)}

    base_url, key = load_env()
    if not args.dry_run:
        ensure_bucket(base_url, key)

    rows = []
    missing = []
    temp_dir = tempfile.mkdtemp(prefix="celia-posters-")

    for item in manifest:
        slug = item["slug"]
        details = overrides.get(slug)
        if not details:
            missing.append(slug)
            continue

        video_path = os.path.join(args.root, item["category"], item["filename"])
        if not os.path.exists(video_path):
            missing.append(slug)
            continue

        loop = loops.get(slug, {})

        if args.dry_run:
            video_url = f"{base_url}/storage/v1/object/public/{BUCKET}/{slug}.mp4"
            poster_url = f"{base_url}/storage/v1/object/public/{BUCKET}/{slug}.jpg"
        else:
            video_url = upload(base_url, key, f"{slug}.mp4", video_path)
            poster_path = os.path.join(temp_dir, f"{slug}.jpg")
            poster_url = upload(base_url, key, f"{slug}.jpg", poster_path) if write_poster(video_path, poster_path) else None
            print(f"uploaded {slug}", flush=True)

        rows.append(
            {
                "slug": slug,
                "name_en": details["name_en"],
                "name_es": details["name_es"],
                "pattern": PATTERNS.get(item["category"], "other"),
                "video_url": video_url,
                "poster_url": poster_url,
                "step_type": item["step_type"],
                "reps_per_loop": loop.get("reps_per_loop", item["reps_per_loop"]),
                "clip_seconds": loop.get("duration_seconds", item["duration_seconds"]),
                "equipment": details.get("equipment", []),
                "default_reps": details.get("default_reps"),
                "default_hold_seconds": details.get("default_hold_seconds"),
                "orientation": item["orientation"],
                "source": args.source,
            }
        )

    if missing:
        print(f"\nskipped (no reviewed entry or file missing): {', '.join(missing)}")

    if args.dry_run:
        print(json.dumps(rows[:3], indent=2))
        print(f"\ndry run: {len(rows)} rows ready, nothing uploaded")
        return

    seed(base_url, key, rows)

    bodyweight = sum(1 for row in rows if not row["equipment"])
    print(f"\nseeded {len(rows)} clips into exercise_clips")
    print(f"  {bodyweight} need no equipment, {len(rows) - bodyweight} need something")
    print(f"  source={args.source}")


if __name__ == "__main__":
    main()
