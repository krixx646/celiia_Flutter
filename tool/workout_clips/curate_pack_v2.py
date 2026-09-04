# -*- coding: utf-8 -*-
"""Curate the App Celine studio pack into a pack_v2 library folder.

The client's second drop arrived as 59 long, landscape takes with auto-renamed
files. Many of those names are wrong (pigeon labelled as cobra, fire hydrant
labelled as donkey kick, etc.), and many takes are near-duplicates of each
other or of pack v1.

This script:
  1. Keeps only distinct movements that add something new to the library
  2. Renames them to what is actually on camera
  3. Hard-links them into the same category/filename layout pack v1 used, so
     analyze / make_loops / upload_clips can run unchanged against --root

    python tool/workout_clips/curate_pack_v2.py
"""

from __future__ import annotations

import json
import os
import shutil

HERE = os.path.dirname(os.path.abspath(__file__))
SOURCE = r"C:\Users\ADMIN\Desktop\gif exercises\App Celine"
LIBRARY = os.path.join(HERE, "pack_v2", "library")
OVERRIDES_OUT = os.path.join(HERE, "clip_overrides_v2.json")
CURATION_OUT = os.path.join(HERE, "pack_v2", "curation.json")

# Each entry: source filename -> curated facts.
# Slugs are hyphenated and must not collide with pack v1 (see clip_manifest.json).
# Categories match upload_clips.PATTERNS so the routine generator can find them.
KEEP: list[dict] = [
    # --- Squats (new variants only; plain bodyweight squat already in v1) ---
    {
        "src": "bodyweight_squat_hands_clasped.mp4",
        "slug": "bodyweight-squat-hands-clasped",
        "category": "01_Squat",
        "name_en": "Bodyweight Squat (Hands Clasped)",
        "name_es": "Sentadilla sin peso (manos juntas)",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 12,
    },
    {
        "src": "swiss_ball_squat.mp4",
        "slug": "swiss-ball-squat",
        "category": "01_Squat",
        "name_en": "Swiss Ball Squat",
        "name_es": "Sentadilla con fitball",
        "equipment": ["swiss_ball"],
        "step_type": "reps",
        "default_reps": 10,
    },
    # --- Hinge / glutes ---
    {
        "src": "donkey_kick_quadruped.mp4",
        "slug": "donkey-kick",
        "category": "02_Hinge",
        "name_en": "Donkey Kick",
        "name_es": "Patada de glúteo",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 12,
    },
    {
        "src": "donkey_kick_kneeling_leg_raise.mp4",
        "slug": "donkey-kick-kneeling",
        "category": "02_Hinge",
        "name_en": "Donkey Kick (Kneeling)",
        "name_es": "Patada de glúteo de rodillas",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 12,
    },
    {
        # Auto-name said donkey kick; frames show a kneeling forearm fire hydrant.
        "src": "donkey_kick_quadruped_glute_kickback.mp4",
        "slug": "fire-hydrant-forearm",
        "category": "02_Hinge",
        "name_en": "Fire Hydrant (Forearm)",
        "name_es": "Hidrante (antebrazos)",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 12,
    },
    {
        "src": "swiss_ball_leg_curl.mp4",
        "slug": "swiss-ball-glute-bridge",
        "category": "02_Hinge",
        "name_en": "Swiss Ball Glute Bridge",
        "name_es": "Puente de glúteos con fitball",
        "equipment": ["swiss_ball"],
        "step_type": "reps",
        "default_reps": 12,
    },
    {
        "src": "side_lying_leg_raise.mp4",
        "slug": "side-lying-leg-raise",
        "category": "02_Hinge",
        "name_en": "Side-Lying Leg Raise",
        "name_es": "Elevación de pierna de lado",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 12,
    },
    {
        "src": "side_lying_leg_raise_hip_abduction.mp4",
        "slug": "side-lying-hip-abduction",
        "category": "02_Hinge",
        "name_en": "Side-Lying Hip Abduction",
        "name_es": "Abducción de cadera de lado",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 12,
    },
    # --- Push ---
    # Plain push-up skipped: pack v1 already has floor-push-up.
    # --- Core ---
    {
        "src": "jumping_jacks.mp4",
        "slug": "jumping-jacks",
        "category": "07_Core_Rotation",
        "name_en": "Jumping Jacks",
        "name_es": "Saltos de tijera",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 20,
    },
    {
        "src": "crunch.mp4",
        "slug": "crunch",
        "category": "07_Core_Rotation",
        "name_en": "Crunch",
        "name_es": "Crunch",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 15,
    },
    {
        "src": "crunch_sit_up.mp4",
        "slug": "sit-up",
        "category": "07_Core_Rotation",
        "name_en": "Sit-Up",
        "name_es": "Abdominal completo",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 12,
    },
    {
        "src": "reverse_crunch_knee_to_chest.mp4",
        "slug": "reverse-crunch",
        "category": "07_Core_Rotation",
        "name_en": "Reverse Crunch",
        "name_es": "Crunch inverso",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 12,
    },
    {
        "src": "lying_leg_raise_legs_up.mp4",
        "slug": "lying-leg-raise",
        "category": "07_Core_Rotation",
        "name_en": "Lying Leg Raise",
        "name_es": "Elevación de piernas tumbado",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 12,
    },
    {
        "src": "lying_leg_raise_scissors.mp4",
        "slug": "scissor-kicks",
        "category": "07_Core_Rotation",
        "name_en": "Scissor Kicks",
        "name_es": "Tijeras de piernas",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 16,
    },
    {
        # Auto-name said bicycle; frames show crossed scissor kicks.
        "src": "lying_leg_raise_bicycle_crunch.mp4",
        "slug": "crossed-scissor-kicks",
        "category": "07_Core_Rotation",
        "name_en": "Crossed Scissor Kicks",
        "name_es": "Tijeras cruzadas",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 16,
    },
    {
        "src": "jackknife_v_up_with_ball.mp4",
        "slug": "v-up-with-ball",
        "category": "07_Core_Rotation",
        "name_en": "V-Up with Ball",
        "name_es": "V-up con balón",
        "equipment": ["medicine_ball"],
        "step_type": "reps",
        "default_reps": 10,
    },
    {
        "src": "swiss_ball_leg_raise.mp4",
        "slug": "swiss-ball-dead-bug",
        "category": "07_Core_Rotation",
        "name_en": "Swiss Ball Dead Bug",
        "name_es": "Dead bug con fitball",
        "equipment": ["swiss_ball"],
        "step_type": "reps",
        "default_reps": 10,
    },
    {
        "src": "swiss_ball_reverse_crunch_ball_pass.mp4",
        "slug": "swiss-ball-ball-pass",
        "category": "07_Core_Rotation",
        "name_en": "Swiss Ball Pass",
        "name_es": "Pase de fitball",
        "equipment": ["swiss_ball"],
        "step_type": "reps",
        "default_reps": 10,
    },
    {
        "src": "swiss_ball_pike.mp4",
        "slug": "swiss-ball-plank",
        "category": "07_Core_Rotation",
        "name_en": "Swiss Ball Plank",
        "name_es": "Plancha con fitball",
        "equipment": ["swiss_ball"],
        "step_type": "hold",
        "default_hold_seconds": 30,
    },
    {
        "src": "swiss_ball_plank_pike.mp4",
        "slug": "swiss-ball-forearm-plank",
        "category": "07_Core_Rotation",
        "name_en": "Swiss Ball Forearm Plank",
        "name_es": "Plancha de antebrazos con fitball",
        "equipment": ["swiss_ball"],
        "step_type": "hold",
        "default_hold_seconds": 30,
    },
    {
        "src": "side_plank_arm_up.mp4",
        "slug": "side-plank-arm-raise",
        "category": "07_Core_Rotation",
        "name_en": "Side Plank Arm Raise",
        "name_es": "Plancha lateral con brazo arriba",
        "equipment": [],
        "step_type": "hold",
        "default_hold_seconds": 25,
    },
    {
        "src": "side_plank_with_leg_raise.mp4",
        "slug": "side-plank-leg-raise",
        "category": "07_Core_Rotation",
        "name_en": "Side Plank Leg Raise",
        "name_es": "Plancha lateral con pierna arriba",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 10,
    },
    {
        # Auto-name said rotation/reach; frames show modified side plank thread-the-needle.
        "src": "plank_rotation_side_plank_reach.mp4",
        "slug": "side-plank-reach-under",
        "category": "07_Core_Rotation",
        "name_en": "Side Plank Reach Under",
        "name_es": "Plancha lateral con paso por debajo",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 10,
    },
    {
        # Auto-name said mountain climber; frames show pike/down-dog glute kickback.
        "src": "plank_leg_raise_mountain_climber.mp4",
        "slug": "down-dog-glute-kickback",
        "category": "02_Hinge",
        "name_en": "Down-Dog Glute Kickback",
        "name_es": "Patada de glúteo en perro mirando abajo",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 12,
    },
    {
        # Auto-name said swimmer; frames show forearm plank with lateral leg lift.
        "src": "prone_back_extension_superman_swimmer.mp4",
        "slug": "forearm-plank-leg-abduction",
        "category": "07_Core_Rotation",
        "name_en": "Forearm Plank Leg Abduction",
        "name_es": "Plancha de antebrazos con abducción",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 12,
    },
    {
        "src": "prone_superman.mp4",
        "slug": "prone-superman",
        "category": "07_Core_Rotation",
        "name_en": "Prone Superman",
        "name_es": "Superman tumbado",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 10,
    },
    {
        "src": "prone_superman_arms_overhead.mp4",
        "slug": "prone-superman-arms-overhead",
        "category": "07_Core_Rotation",
        "name_en": "Prone Superman (Arms Overhead)",
        "name_es": "Superman con brazos arriba",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 10,
    },
    {
        "src": "prone_superman_arms_back.mp4",
        "slug": "prone-superman-arms-back",
        "category": "07_Core_Rotation",
        "name_en": "Prone Superman (Arms Back)",
        "name_es": "Superman con brazos atrás",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 10,
    },
    {
        "src": "prone_superman_arms_out.mp4",
        "slug": "prone-t-raise",
        "category": "07_Core_Rotation",
        "name_en": "Prone T-Raise",
        "name_es": "Elevación en T tumbado",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 10,
    },
    {
        # Auto-name said glute bridge; frames show alternating-arm Superman.
        "src": "lying_leg_raise_glute_bridge.mp4",
        "slug": "prone-superman-alternating-arms",
        "category": "07_Core_Rotation",
        "name_en": "Prone Superman (Alternating Arms)",
        "name_es": "Superman con brazos alternos",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 10,
    },
    {
        # Auto-name said hold/superman; frames show prone T with arms out.
        "src": "prone_back_extension_superman_hold.mp4",
        "slug": "prone-t-hold",
        "category": "07_Core_Rotation",
        "name_en": "Prone T Hold",
        "name_es": "Isométrico en T tumbado",
        "equipment": [],
        "step_type": "hold",
        "default_hold_seconds": 25,
    },
    {
        # Auto-name said clamshell; frames show prone chest/back extension.
        "src": "side_lying_reach_clamshell.mp4",
        "slug": "prone-back-extension",
        "category": "07_Core_Rotation",
        "name_en": "Prone Back Extension",
        "name_es": "Extensión de espalda tumbado",
        "equipment": [],
        "step_type": "reps",
        "default_reps": 12,
    },
    {
        # Sheet 1: sphinx / cobra press on forearms.
        "src": "prone_back_extension_superman.mp4",
        "slug": "sphinx-press",
        "category": "08_Recovery",
        "name_en": "Sphinx Press",
        "name_es": "Press esfinge",
        "equipment": [],
        "step_type": "hold",
        "default_hold_seconds": 30,
    },
    # --- Recovery ---
    {
        # Auto-name said cobra; frames are sleeping pigeon.
        "src": "cobra_prone_back_extension.mp4",
        "slug": "pigeon-pose",
        "category": "08_Recovery",
        "name_en": "Pigeon Pose",
        "name_es": "Postura de la paloma",
        "equipment": [],
        "step_type": "hold",
        "default_hold_seconds": 30,
    },
    {
        "src": "standing_forward_fold_hinge.mp4",
        "slug": "standing-forward-fold",
        "category": "08_Recovery",
        "name_en": "Standing Forward Fold",
        "name_es": "Flexión de pie hacia delante",
        "equipment": [],
        "step_type": "hold",
        "default_hold_seconds": 30,
    },
    {
        "src": "standing_hip_hinge_toe_touch.mp4",
        "slug": "standing-toe-touch",
        "category": "08_Recovery",
        "name_en": "Standing Toe Touch",
        "name_es": "Tocar puntas de pie",
        "equipment": [],
        "step_type": "hold",
        "default_hold_seconds": 30,
    },
]


def link_or_copy(src: str, dst: str) -> None:
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    if os.path.exists(dst):
        os.remove(dst)
    try:
        os.link(src, dst)
    except OSError:
        shutil.copy2(src, dst)


def main() -> int:
    if not os.path.isdir(SOURCE):
        raise SystemExit(f"missing source folder: {SOURCE}")

    # Wipe previous curation so dropped clips cannot linger.
    if os.path.isdir(LIBRARY):
        shutil.rmtree(LIBRARY)
    os.makedirs(LIBRARY, exist_ok=True)

    overrides: dict = {
        "_readme": [
            "Pack v2 (App Celine studio takes). Names were corrected from the",
            "contact sheets / ID frames — the auto-rename map was often wrong.",
            "Clips that pack v1 already covers (bodyweight squat, push-up,",
            "bird-dog, cat-cow, basic planks, mountain climber, glute bridge,",
            "plain side plank) were deliberately left out.",
        ]
    }
    curation = []
    missing = []

    by_category: dict[str, int] = {}
    for entry in KEEP:
        src_path = os.path.join(SOURCE, entry["src"])
        if not os.path.isfile(src_path):
            missing.append(entry["src"])
            continue

        index = by_category.get(entry["category"], 0) + 1
        by_category[entry["category"]] = index
        filename = f"{index:02d}_{entry['slug']}.mp4"
        dst = os.path.join(LIBRARY, entry["category"], filename)
        link_or_copy(src_path, dst)

        override = {
            "name_en": entry["name_en"],
            "name_es": entry["name_es"],
            "equipment": entry["equipment"],
        }
        if entry["step_type"] == "hold":
            override["reps_per_loop"] = None
            override["default_hold_seconds"] = entry["default_hold_seconds"]
        else:
            # Leave reps_per_loop unset so analyze_clips can estimate; make_loops
            # then writes the count that matches the trimmed file.
            override["default_reps"] = entry["default_reps"]

        # Static stretches are holds even when analysis sees motion getting
        # into the pose. Dynamic mobility (cat-cow, world's greatest, etc.)
        # stays as reps and is not listed here.
        if entry["slug"] in {
            "sphinx-press",
            "standing-toe-touch",
            "pigeon-pose",
            "standing-forward-fold",
        }:
            override["reps_per_loop"] = None
            override.pop("default_reps", None)
            override["default_hold_seconds"] = entry.get(
                "default_hold_seconds", 30
            )
        overrides[entry["slug"]] = override

        curation.append(
            {
                **entry,
                "filename": filename,
                "library_path": os.path.relpath(dst, HERE).replace("\\", "/"),
            }
        )
        print(f"keep {entry['src']} -> {entry['category']}/{filename}")

    with open(OVERRIDES_OUT, "w", encoding="utf-8") as handle:
        json.dump(overrides, handle, indent=2, ensure_ascii=False)
        handle.write("\n")

    with open(CURATION_OUT, "w", encoding="utf-8") as handle:
        json.dump(
            {
                "source": SOURCE,
                "kept": len(curation),
                "dropped_from_59": 59 - len(curation),
                "entries": curation,
            },
            handle,
            indent=2,
            ensure_ascii=False,
        )
        handle.write("\n")

    print(f"\nkept {len(curation)} clips -> {LIBRARY}")
    print(f"overrides -> {OVERRIDES_OUT}")
    if missing:
        print(f"MISSING sources: {', '.join(missing)}")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
