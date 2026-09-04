# -*- coding: utf-8 -*-
"""Measure the loop seam in the encoded clips that will actually ship.

make_loops.py predicts the seam from the source footage; this reads it back
off the finished files, so a mistake in the trim or the encode cannot slip
through unnoticed.

    python tool/workout_clips/verify_loops.py --original "<src>" --looped "<out>"
"""

from __future__ import annotations

import argparse
import json
import os

import cv2
import numpy as np


def ends(path: str) -> tuple[np.ndarray, np.ndarray] | None:
    capture = cv2.VideoCapture(path)
    frames = []
    while True:
        ok, frame = capture.read()
        if not ok:
            break
        small = cv2.resize(frame, (64, 64), interpolation=cv2.INTER_AREA)
        frames.append(cv2.cvtColor(small, cv2.COLOR_BGR2GRAY).astype(np.float32) / 255)
    capture.release()
    if len(frames) < 2:
        return None
    return frames[0], frames[-1]


def seam(path: str) -> float | None:
    pair = ends(path)
    if pair is None:
        return None
    first, last = pair
    return float(np.abs(last - first).mean())


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--original", required=True)
    parser.add_argument("--looped", required=True)
    args = parser.parse_args()

    here = os.path.dirname(__file__)
    with open(os.path.join(here, "clip_loops.json"), encoding="utf-8") as handle:
        loops = json.load(handle)

    worse, missing, measured = [], [], []
    for item in loops:
        relative = os.path.join(item["category"], item["filename"])
        before = seam(os.path.join(args.original, relative))
        after = seam(os.path.join(args.looped, relative))
        if before is None or after is None:
            missing.append(item["slug"])
            continue
        measured.append((item["slug"], before, after))
        if after > before + 0.002:
            worse.append((item["slug"], before, after))

    measured.sort(key=lambda row: -row[2])
    print("worst remaining seams in the shipped files:")
    for slug, before, after in measured[:8]:
        print(f"  {slug}: {before:.3f} -> {after:.3f}")

    improved = sum(1 for _, b, a in measured if a < b * 0.9)
    print(f"\n{len(measured)} clips verified, {improved} materially better")
    if worse:
        print("REGRESSED: " + ", ".join(f"{s} ({b:.3f}->{a:.3f})" for s, b, a in worse))
    if missing:
        print("unreadable: " + ", ".join(missing))
    if not worse and not missing:
        print("no clip loops worse than it did before.")


if __name__ == "__main__":
    main()
