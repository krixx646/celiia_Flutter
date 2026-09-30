# -*- coding: utf-8 -*-
"""Upload usable clips from the premium equipment GIF library into exercise_clips.

Source folder (flat MP4s):
  .../BIBLIOTECA DE EJERCICIOS/1° BIBLIOTECA - GIFs PREMIUM DE EJERCICIOS

Skips form-check / mistake / montage / variant reels — those are coaching
extras, not demo loops. Infers equipment tags and movement patterns from the
filename so the routine generator can filter them.

    python tool/workout_clips/upload_premium_equipment.py --dry-run
    python tool/workout_clips/upload_premium_equipment.py
"""

from __future__ import annotations

import argparse
import json
import mimetypes
import os
import re
import sys
import tempfile
from pathlib import Path

import cv2
import requests

HERE = Path(__file__).resolve().parent
ENV_PATH = HERE.parent.parent / "celia-admin" / ".env.local"
BUCKET = "exercise-clips"
SOURCE = "premium_equipment_v1"
POSTER_POSITION = 0.15

DEFAULT_ROOT = Path(
    r"C:\Users\ADMIN\Desktop\gif exercises\BIBLIOTECA DE EJERCICIOS"
)

SKIP_SUBSTRINGS = (
    "mistake",
    "form_check",
    "montage",
    "compilation",
    "grip_variants",
    "variants",
    "workout_montage",
)

EQUIPMENT_PREFIXES = (
    ("barbell", "barbell"),
    ("dumbbell", "dumbbell"),
    ("kettlebell", "kettlebell"),
    ("cable", "cable"),
    ("smith", "smith"),
    ("machine", "machine"),
    ("band", "band"),
    ("ez_bar", "barbell"),
    ("ez-bar", "barbell"),
)

PATTERN_KEYWORDS = (
    ("squat", "squat"),
    ("lunge", "lunge"),
    ("deadlift", "hinge"),
    ("rdl", "hinge"),
    ("hip_thrust", "hinge"),
    ("hinge", "hinge"),
    ("row", "pull"),
    ("pulldown", "pull"),
    ("pull_up", "pull"),
    ("pullup", "pull"),
    ("chin", "pull"),
    ("press", "push"),
    ("push_up", "push"),
    ("pushup", "push"),
    ("fly", "push"),
    ("bench", "push"),
    ("curl", "pull"),
    ("extension", "push"),
    ("raise", "push"),
    ("plank", "core"),
    ("crunch", "core"),
    ("leg_raise", "core"),
    ("v_up", "core"),
    ("carry", "carry"),
)


def load_env() -> tuple[str, str]:
    if not ENV_PATH.exists():
        sys.exit(f"missing {ENV_PATH}")
    values: dict[str, str] = {}
    for line in ENV_PATH.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            key, value = line.split("=", 1)
            values[key.strip()] = value.strip().strip('"').strip("'")
    url = values.get("NEXT_PUBLIC_SUPABASE_URL")
    key = values.get("SUPABASE_SERVICE_ROLE_KEY")
    if not url or not key:
        sys.exit("NEXT_PUBLIC_SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY required")
    return url.rstrip("/"), key


def find_premium_root(base: Path) -> Path:
    if not base.exists():
        sys.exit(f"missing library root: {base}")
    for child in base.iterdir():
        if child.is_dir() and "BIBLIOTECA" in child.name.upper() and "GIF" in child.name.upper():
            return child
    sys.exit(f"could not find premium GIF folder under {base}")


def slugify(stem: str) -> str:
    slug = stem.lower().replace(" ", "_")
    slug = re.sub(r"[^a-z0-9_]+", "_", slug)
    slug = re.sub(r"_+", "_", slug).strip("_")
    return slug[:80]


def title_case(stem: str) -> str:
    words = stem.replace("_", " ").replace("-", " ").split()
    return " ".join(w.capitalize() for w in words)


def infer_equipment(stem: str) -> list[str]:
    lower = stem.lower()
    if lower.startswith("bodyweight") or "bodyweight" in lower:
        if "wall" in lower:
            return ["wall"]
        if "bench" in lower:
            return ["bench"]
        return []
    # Unweighted classics that appear in the premium pack without a bodyweight_ prefix.
    if any(
        token in lower
        for token in (
            "push_up",
            "push-up",
            "pushup",
            "pull_up",
            "pull-up",
            "pullup",
            "chin_up",
            "chin-up",
            "burpee",
            "crunch",
            "plank",
            "jumping_jack",
        )
    ) and not any(lower.startswith(p) for p, _ in EQUIPMENT_PREFIXES):
        if "bench" in lower:
            return ["bench"]
        return []
    for prefix, tag in EQUIPMENT_PREFIXES:
        if lower.startswith(prefix) or f"_{prefix}_" in f"_{lower}_":
            tags = [tag]
            if "bench" in lower and tag != "bench":
                tags.append("bench")
            return tags
    if "bulgarian" in lower:
        return ["bench"]  # rear-foot elevated on a bench
    return ["dumbbell"]  # conservative default for unnamed weighted moves


def infer_pattern(stem: str) -> str:
    lower = stem.lower()
    for keyword, pattern in PATTERN_KEYWORDS:
        if keyword in lower:
            return pattern
    return "other"


def infer_step(stem: str) -> tuple[str, int | None, int | None]:
    lower = stem.lower()
    if any(k in lower for k in ("plank", "hold", "stretch", "pose", "wall_sit")):
        return "hold", None, 30
    return "reps", 10, None


def is_usable(path: Path) -> bool:
    name = path.name.lower()
    if path.suffix.lower() not in {".mp4", ".mov", ".webm"}:
        return False
    return not any(skip in name for skip in SKIP_SUBSTRINGS)


def write_poster(video_path: Path, out_path: Path) -> bool:
    cap = cv2.VideoCapture(str(video_path))
    total = int(cap.get(cv2.CAP_PROP_FRAME_COUNT) or 0)
    if total > 0:
        cap.set(cv2.CAP_PROP_POS_FRAMES, max(0, int(total * POSTER_POSITION)))
    ok, frame = cap.read()
    cap.release()
    if ok:
        cv2.imwrite(str(out_path), frame, [cv2.IMWRITE_JPEG_QUALITY, 85])
    return ok


def probe_seconds(video_path: Path) -> float:
    cap = cv2.VideoCapture(str(video_path))
    fps = float(cap.get(cv2.CAP_PROP_FPS) or 0) or 30.0
    frames = float(cap.get(cv2.CAP_PROP_FRAME_COUNT) or 0)
    cap.release()
    if frames <= 0:
        return 8.0
    return round(frames / fps, 2)


def upload(base_url: str, key: str, object_path: str, file_path: Path) -> str:
    content_type = mimetypes.guess_type(str(file_path))[0] or "application/octet-stream"
    with open(file_path, "rb") as handle:
        response = requests.post(
            f"{base_url}/storage/v1/object/{BUCKET}/{object_path}",
            headers={
                "Authorization": f"Bearer {key}",
                "apikey": key,
                "Content-Type": content_type,
                "x-upsert": "true",
            },
            data=handle,
            timeout=300,
        )
    if response.status_code not in (200, 201):
        raise RuntimeError(f"upload failed for {object_path}: {response.status_code} {response.text}")
    return f"{base_url}/storage/v1/object/public/{BUCKET}/{object_path}"


def seed(base_url: str, key: str, rows: list[dict]) -> None:
    # Chunk to stay under payload limits.
    for i in range(0, len(rows), 40):
        chunk = rows[i : i + 40]
        response = requests.post(
            f"{base_url}/rest/v1/exercise_clips?on_conflict=slug",
            headers={
                "Authorization": f"Bearer {key}",
                "apikey": key,
                "Content-Type": "application/json",
                "Prefer": "resolution=merge-duplicates,return=minimal",
            },
            json=chunk,
            timeout=120,
        )
        if response.status_code not in (200, 201, 204):
            sys.exit(f"seed failed: {response.status_code} {response.text}")


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


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--limit", type=int, default=0, help="Upload at most N clips (0 = all)")
    args = parser.parse_args()

    premium = find_premium_root(args.root)
    files = sorted(p for p in premium.iterdir() if p.is_file() and is_usable(p))
    if args.limit > 0:
        files = files[: args.limit]

    print(f"premium folder: {premium}")
    print(f"usable clips: {len(files)}")

    base_url, key = load_env()
    if not args.dry_run:
        ensure_bucket(base_url, key)

    rows: list[dict] = []
    temp_dir = Path(tempfile.mkdtemp(prefix="celia-premium-"))
    catalog: list[dict] = []

    for path in files:
        stem = path.stem
        slug = slugify(stem)
        equipment = infer_equipment(stem)
        pattern = infer_pattern(stem)
        step_type, default_reps, default_hold = infer_step(stem)
        name_en = title_case(stem)
        seconds = probe_seconds(path)

        catalog.append(
            {
                "slug": slug,
                "file": path.name,
                "equipment": equipment,
                "pattern": pattern,
                "step_type": step_type,
            }
        )

        if args.dry_run:
            video_url = f"{base_url}/storage/v1/object/public/{BUCKET}/{slug}.mp4"
            poster_url = f"{base_url}/storage/v1/object/public/{BUCKET}/{slug}.jpg"
        else:
            video_url = upload(base_url, key, f"{slug}.mp4", path)
            poster_path = temp_dir / f"{slug}.jpg"
            poster_url = (
                upload(base_url, key, f"{slug}.jpg", poster_path)
                if write_poster(path, poster_path)
                else None
            )
            print(f"uploaded {slug} equipment={equipment}", flush=True)

        rows.append(
            {
                "slug": slug,
                "name_en": name_en,
                "name_es": name_en,  # Spanish titles can be curated later
                "pattern": pattern,
                "video_url": video_url,
                "poster_url": poster_url,
                "step_type": step_type,
                "reps_per_loop": 1 if step_type == "reps" else None,
                "clip_seconds": seconds,
                "equipment": equipment,
                "default_reps": default_reps,
                "default_hold_seconds": default_hold,
                "orientation": "landscape",
                "source": SOURCE,
                "is_active": True,
            }
        )

    catalog_path = HERE / "premium_equipment_catalog.json"
    catalog_path.write_text(json.dumps(catalog, indent=2), encoding="utf-8")
    print(f"wrote {catalog_path}")

    if args.dry_run:
        print(json.dumps(rows[:3], indent=2))
        by_eq: dict[str, int] = {}
        for row in rows:
            key = ",".join(row["equipment"]) or "bodyweight"
            by_eq[key] = by_eq.get(key, 0) + 1
        print("equipment breakdown:", json.dumps(by_eq, indent=2))
        print(f"dry run: {len(rows)} rows ready")
        return

    seed(base_url, key, rows)
    print(f"seeded {len(rows)} premium equipment clips (source={SOURCE})")


if __name__ == "__main__":
    main()
