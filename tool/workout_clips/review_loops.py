# -*- coding: utf-8 -*-
"""Render the proposed loops as filmstrips so they can be judged by eye.

Each row is one clip: six frames spanning the trimmed loop, with the first and
last labelled. Those two frames are what the player cuts between, so if they
show the same pose the loop is seamless, and the frames between them show
whether the loop is a whole rep or half of one.

    python tool/workout_clips/review_loops.py --root "<clips folder>" [slug ...]
"""

from __future__ import annotations

import argparse
import json
import os

import cv2
import numpy as np

HERE = os.path.dirname(__file__)
LOOPS_PATH = os.path.join(HERE, "clip_loops.json")
OUT_PATH = os.path.join(HERE, "loop_review.jpg")

TILE = 150
COLUMNS = 6


def strip_for(root: str, loop: dict) -> np.ndarray | None:
    path = os.path.join(root, loop["category"], loop["filename"])
    if not os.path.exists(path):
        return None

    capture = cv2.VideoCapture(path)
    fps = capture.get(cv2.CAP_PROP_FPS) or 24.0
    first = int(loop["start_seconds"] * fps)
    last = max(first + 1, int(loop["end_seconds"] * fps) - 1)
    wanted = set(np.linspace(first, last, COLUMNS).astype(int).tolist())

    grabbed: dict[int, np.ndarray] = {}
    index = 0
    while True:
        ok, frame = capture.read()
        if not ok:
            break
        if index in wanted:
            grabbed[index] = cv2.resize(frame, (TILE, TILE))
        index += 1
    capture.release()

    tiles = []
    for position, frame_index in enumerate(sorted(wanted)):
        tile = grabbed.get(frame_index, np.zeros((TILE, TILE, 3), np.uint8)).copy()
        if position == 0:
            cv2.putText(tile, "START", (4, 18), 0, 0.5, (0, 255, 255), 2)
        elif position == len(wanted) - 1:
            cv2.putText(tile, "END", (4, 18), 0, 0.5, (0, 255, 255), 2)
        tiles.append(tile)

    strip = np.hstack(tiles)
    caption = (
        f"{loop['slug']}  {loop['duration_seconds']}s of {loop['original_seconds']}s"
        f"  seam {loop['seam_before']}->{loop['seam_after']}"
        f"  {loop.get('reps_per_loop')} rep/loop"
    )
    cv2.putText(strip, caption, (4, TILE - 6), 0, 0.42, (0, 255, 0), 1)
    return strip


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", required=True)
    parser.add_argument("--out", default=OUT_PATH)
    parser.add_argument("slugs", nargs="*", help="Defaults to every trimmed clip")
    args = parser.parse_args()

    with open(LOOPS_PATH, encoding="utf-8") as handle:
        loops = {item["slug"]: item for item in json.load(handle)}

    wanted = args.slugs or list(loops)
    strips = [s for slug in wanted if (s := strip_for(args.root, loops[slug])) is not None]
    if not strips:
        raise SystemExit("nothing to render")

    cv2.imwrite(args.out, np.vstack(strips), [cv2.IMWRITE_JPEG_QUALITY, 90])
    print(f"wrote {args.out} ({len(strips)} clips)")


if __name__ == "__main__":
    main()
