# -*- coding: utf-8 -*-
"""Seed two routines built from the filmed clip library.

Every routine in the database predates sets, reps and rest, so they all run as
plain timed steps and none of them exercises the guided player properly. These
two do: real set counts, real rep prescriptions, real rest, and both counted
and held exercises, so a single run through either one covers the whole
player.

Fixed ids, so re-running updates the same two routines instead of piling up
copies.

    python tool/workout_clips/seed_demo_routines.py
"""

from __future__ import annotations

import io
import json
import os
import sys
import uuid

import requests

ENV_PATH = os.path.join(os.path.dirname(__file__), "..", "..", "celia-admin", ".env.local")

# Stable namespace so the ids below are the same on every run and on every
# machine, without hardcoding opaque UUID literals.
NAMESPACE = uuid.UUID("6f1d1a8e-2b64-4f0e-9a3a-6d0a1c2b3d4e")

ROUTINES = [
    {
        "key": "guided-full-body-no-equipment",
        "title": "Full Body Starter",
        "description": "A complete no-equipment session. Celia counts every rep with you and rests between sets.",
        "difficulty": "easy",
        "category": "strength",
        "equipment": "None",
        "tags": ["no-equipment", "full-body", "guided"],
        "steps": [
            {"slug": "bodyweight-squat", "title": "Bodyweight Squat", "sets": 3, "reps": 12, "rest": 40},
            {"slug": "floor-push-up", "title": "Push-Up", "sets": 3, "reps": 10, "rest": 40},
            {"slug": "reverse-lunge", "title": "Reverse Lunge", "sets": 3, "reps": 10, "rest": 40},
            {"slug": "glute-bridge", "title": "Glute Bridge", "sets": 3, "reps": 15, "rest": 30},
            {"slug": "plank-variations", "title": "Plank", "sets": 3, "hold": 30, "rest": 30},
            {"slug": "childs-pose", "title": "Child's Pose", "sets": 1, "hold": 45, "rest": 0},
        ],
    },
    {
        "key": "guided-core-and-mobility",
        "title": "Core & Mobility",
        "description": "Controlled core work followed by mobility. Counted reps, timed holds, guided rest.",
        "difficulty": "easy",
        "category": "flexibility",
        "equipment": "None",
        "tags": ["no-equipment", "core", "mobility", "guided"],
        "steps": [
            {"slug": "dead-bug", "title": "Dead Bug", "sets": 3, "reps": 12, "rest": 30},
            {"slug": "bird-dog", "title": "Bird Dog", "sets": 3, "reps": 12, "rest": 30},
            {"slug": "side-plank", "title": "Side Plank", "sets": 3, "hold": 25, "rest": 30},
            {"slug": "cat-cow", "title": "Cat-Cow", "sets": 2, "reps": 10, "rest": 20},
            {"slug": "worlds-greatest-stretch", "title": "World's Greatest Stretch", "sets": 2, "reps": 8, "rest": 20},
            {"slug": "diaphragmatic-breathing", "title": "Breathing", "sets": 1, "hold": 60, "rest": 0},
        ],
    },
]


def load_env() -> tuple[str, str]:
    values = {}
    with io.open(ENV_PATH, encoding="utf-8") as handle:
        for line in handle:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                key, value = line.split("=", 1)
                values[key.strip()] = value.strip()

    url = values.get("NEXT_PUBLIC_SUPABASE_URL")
    key = values.get("SUPABASE_SERVICE_ROLE_KEY")
    if not url or not key:
        sys.exit("Supabase URL and service role key must be set in celia-admin/.env.local")
    return url.rstrip("/"), key


def estimate_minutes(steps: list[dict], clips: dict) -> int:
    total = 0.0
    for step in steps:
        sets = step["sets"]
        if "reps" in step:
            clip = clips.get(step["slug"], {})
            per_rep = (clip.get("clip_seconds") or 3) / max(1, clip.get("reps_per_loop") or 1)
            total += sets * step["reps"] * per_rep
        else:
            total += sets * step["hold"]
        # Lead-in before the exercise, plus rest after each set bar the last.
        total += 10 + step["rest"] * max(0, sets - 1)
    return max(1, round(total / 60))


def main() -> None:
    base_url, key = load_env()
    headers = {"apikey": key, "Authorization": f"Bearer {key}", "Content-Type": "application/json"}

    library = requests.get(
        f"{base_url}/rest/v1/exercise_clips?select=slug,poster_url,clip_seconds,reps_per_loop,step_type",
        headers=headers,
        timeout=60,
    ).json()
    clips = {row["slug"]: row for row in library}

    payload = []
    for routine in ROUTINES:
        missing = [s["slug"] for s in routine["steps"] if s["slug"] not in clips]
        if missing:
            sys.exit(f"{routine['key']} references clips that are not seeded: {', '.join(missing)}")

        steps = []
        for index, step in enumerate(routine["steps"]):
            clip = clips[step["slug"]]
            is_counted = "reps" in step
            per_rep = (clip["clip_seconds"] or 3) / max(1, clip["reps_per_loop"] or 1)
            steps.append(
                {
                    # Deterministic step ids keep re-runs stable, which matters
                    # because routine dedup fingerprints the step sequence.
                    "id": str(uuid.uuid5(NAMESPACE, f"{routine['key']}:{index}")),
                    "title": step["title"],
                    "description": None,
                    "duration_seconds": round(step["reps"] * per_rep) if is_counted else step["hold"],
                    "video_id": None,
                    "thumbnail_url": clip["poster_url"],
                    "order_index": index,
                    "exercise_slug": step["slug"],
                    "sets": step["sets"],
                    "reps": step["reps"] if is_counted else None,
                    "rest_seconds": step["rest"],
                }
            )

        payload.append(
            {
                "id": str(uuid.uuid5(NAMESPACE, routine["key"])),
                "title": routine["title"],
                "description": routine["description"],
                "duration_minutes": estimate_minutes(routine["steps"], clips),
                "difficulty": routine["difficulty"],
                "category": routine["category"],
                "thumbnail_url": clips[routine["steps"][0]["slug"]]["poster_url"],
                "steps": steps,
                "created_by": "admin",
                "is_published": True,
                "is_curated": True,
                "tags": routine["tags"],
                "equipment": routine["equipment"],
            }
        )

    response = requests.post(
        f"{base_url}/rest/v1/routines?on_conflict=id",
        headers={**headers, "Prefer": "resolution=merge-duplicates,return=representation"},
        json=payload,
        timeout=60,
    )
    if response.status_code not in (200, 201):
        sys.exit(f"seed failed: {response.status_code} {response.text}")

    for routine in response.json():
        print(f"{routine['title']}  {routine['duration_minutes']} min  {len(routine['steps'])} exercises")
    print(f"\nseeded {len(payload)} guided routines")
    print(json.dumps(payload[0]["steps"][0], indent=2))


if __name__ == "__main__":
    main()
