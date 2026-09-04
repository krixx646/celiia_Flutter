# -*- coding: utf-8 -*-
"""Measure what the guided player needs to know about each demo clip.

For every clip the player needs three things: whether it is a rep exercise or
a static hold, how many reps one loop of the clip is worth, and therefore how
long a single rep takes. It loops the clip until the prescribed reps are done
and counts them out loud, so a wrong rep count means Celia counts wrong.

Getting that from raw pixel differences does not work: the background
dominates the frame, so a second rep barely registers. Instead the subject is
isolated against the clip's own median background - the camera never moves in
these clips - and their bounding box is tracked. A squat moves the box down
and back up; a push-up does the same; a plank does not move it at all. Reps
are the oscillations of that box, which is what a person watching would count.

The counts are still written out for review rather than trusted blindly.
Anything the review disagrees with goes in clip_overrides.json and wins.

    python tool/workout_clips/analyze_clips.py --root "<clips folder>" --plots
"""

from __future__ import annotations

import argparse
import csv
import json
import os
from dataclasses import dataclass, asdict

import cv2
import numpy as np

# Working resolution for the silhouette pass. Big enough to locate a body,
# small enough to run the whole library in under a minute.
ANALYSIS_WIDTH = 160

# How far a pixel must sit from the background before it counts as subject.
FOREGROUND_THRESHOLD = 18

# An oscillation must cover this fraction of the clip's own movement range to
# count as a rep rather than a sway or a breath.
REP_PROMINENCE = 0.40

# Below this much subject travel - as a fraction of the subject's own height -
# nothing is really moving and the clip is a static hold.
HOLD_TRAVEL = 0.10

OVERRIDES_PATH = os.path.join(os.path.dirname(__file__), "clip_overrides.json")

CELL_WIDTH, CELL_HEIGHT, COLUMNS = 340, 150, 3


@dataclass
class ClipMeasurement:
    category: str
    slug: str
    filename: str
    duration_seconds: float
    fps: float
    width: int
    height: int
    orientation: str
    step_type: str
    reps_per_loop: int | None
    rep_seconds: float | None
    travel: float
    source: str


def subject_motion(path: str) -> tuple[np.ndarray, float, int, int, float]:
    """Track the subject's vertical position through the clip.

    Returns the tracked signal, fps, the clip's real dimensions, and how far
    the subject travelled relative to their own height.
    """
    cap = cv2.VideoCapture(path)
    fps = cap.get(cv2.CAP_PROP_FPS) or 30.0
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

    frames: list[np.ndarray] = []
    while True:
        ok, frame = cap.read()
        if not ok:
            break
        scale = ANALYSIS_WIDTH / max(1, frame.shape[1])
        small = cv2.resize(frame, (ANALYSIS_WIDTH, max(1, int(frame.shape[0] * scale))))
        frames.append(cv2.cvtColor(small, cv2.COLOR_BGR2GRAY).astype(np.float32))
    cap.release()

    if len(frames) < 6:
        return np.array([]), fps, width, height, 0.0

    stack = np.stack(frames)
    # The subject moves and the room does not, so the per-pixel median over
    # the clip is the empty room.
    background = np.median(stack, axis=0)

    positions = []
    heights = []
    for frame in stack:
        mask = np.abs(frame - background) > FOREGROUND_THRESHOLD
        rows = np.where(mask.any(axis=1))[0]
        if rows.size == 0:
            positions.append(positions[-1] if positions else 0.0)
            heights.append(heights[-1] if heights else 1.0)
            continue
        weights = mask.sum(axis=1).astype(np.float32)
        # Centre of mass rather than box edges: a flailing arm shifts an edge,
        # but barely moves the mass of a body.
        positions.append(float((np.arange(mask.shape[0]) * weights).sum() / max(weights.sum(), 1e-6)))
        heights.append(float(rows[-1] - rows[0] + 1))

    signal = np.asarray(positions, np.float32)
    window = max(3, int(fps // 6))
    if signal.size > window:
        signal = np.convolve(signal, np.ones(window) / window, mode="same")
        signal[:window] = signal[window]
        signal[-window:] = signal[-window - 1]

    subject_height = float(np.median(heights)) or 1.0
    travel = float(signal.max() - signal.min()) / subject_height

    return signal, fps, width, height, travel


def count_reps(signal: np.ndarray, travel: float) -> int:
    """Count full oscillations of the tracked signal."""
    if signal.size < 6 or travel < HOLD_TRAVEL:
        return 0

    low, high = float(signal.min()), float(signal.max())
    span = max(high - low, 1e-6)
    rise = low + span * (0.5 + REP_PROMINENCE / 2)
    fall = low + span * (0.5 - REP_PROMINENCE / 2)

    # Hysteresis: the signal must cross high and come back under low to bank a
    # rep, which ignores jitter around either threshold.
    reps = 0
    above = signal[0] > rise
    for value in signal[1:]:
        if not above and value > rise:
            above = True
            reps += 1
        elif above and value < fall:
            above = False

    # A clip that starts mid-rep finishes an excursion it never started, so a
    # single sweep across the range still shows the movement once.
    return max(reps, 1)


def measure(path: str, category: str, overrides: dict) -> tuple[ClipMeasurement, np.ndarray]:
    filename = os.path.basename(path)
    # Clips arrive as "04_reverse-lunge.mp4"; the ordering prefix belongs to
    # the client's folder, not to us. Underscore-only names without a numeric
    # prefix (pack v2 before curation) keep the full stem.
    stem = filename.rsplit(".", 1)[0]
    slug = stem.split("_", 1)[-1] if stem[:1].isdigit() else stem.replace("_", "-")

    signal, fps, width, height, travel = subject_motion(path)
    duration = signal.size / fps if fps else 0.0
    reps = count_reps(signal, travel)

    if width > height * 1.05:
        orientation = "landscape"
    elif height > width * 1.05:
        orientation = "portrait"
    else:
        orientation = "square"

    source = "measured"
    if slug in overrides and "reps_per_loop" in overrides[slug]:
        # Explicit null means a hold; a number is a reviewed count. Names and
        # equipment can live in overrides without freezing the rep estimate.
        reps = int(overrides[slug].get("reps_per_loop") or 0)
        source = "reviewed"

    return (
        ClipMeasurement(
            category=category,
            slug=slug,
            filename=filename,
            duration_seconds=round(duration, 2),
            fps=round(fps, 2),
            width=width,
            height=height,
            orientation=orientation,
            step_type="reps" if reps > 0 else "hold",
            reps_per_loop=reps or None,
            rep_seconds=round(duration / reps, 2) if reps else None,
            travel=round(travel, 3),
            source=source,
        ),
        signal,
    )


def draw_cell(signal: np.ndarray, item: ClipMeasurement) -> np.ndarray:
    cell = np.full((CELL_HEIGHT, CELL_WIDTH, 3), 24, np.uint8)

    if signal.size > 1:
        low, high = float(signal.min()), float(signal.max())
        span = max(high - low, 1e-6)
        top, bottom = 46, CELL_HEIGHT - 10

        for fraction in (0.5 - REP_PROMINENCE / 2, 0.5 + REP_PROMINENCE / 2):
            y = int(bottom - (bottom - top) * fraction)
            cv2.line(cell, (8, y), (CELL_WIDTH - 8, y), (66, 66, 66), 1)

        points = [
            (
                8 + int((CELL_WIDTH - 16) * i / max(1, signal.size - 1)),
                int(bottom - (bottom - top) * (v - low) / span),
            )
            for i, v in enumerate(signal)
        ]
        colour = (120, 220, 140) if item.step_type == "reps" else (120, 170, 250)
        cv2.polylines(cell, [np.array(points, np.int32)], False, colour, 2, cv2.LINE_AA)

    detail = f"{item.duration_seconds}s  travel {item.travel}  -> {item.step_type} x{item.reps_per_loop or 0}"
    cv2.putText(cell, item.slug, (8, 18), cv2.FONT_HERSHEY_SIMPLEX, 0.46, (255, 255, 255), 1, cv2.LINE_AA)
    cv2.putText(cell, detail, (8, 37), cv2.FONT_HERSHEY_SIMPLEX, 0.40, (170, 190, 255), 1, cv2.LINE_AA)
    return cell


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", required=True)
    parser.add_argument("--out", default=os.path.join(os.path.dirname(__file__), "clip_manifest"))
    parser.add_argument(
        "--overrides",
        default=OVERRIDES_PATH,
        help="Reviewed facts JSON (defaults to clip_overrides.json)",
    )
    parser.add_argument("--plots", action="store_true")
    args = parser.parse_args()

    overrides = {}
    if os.path.exists(args.overrides):
        with open(args.overrides, encoding="utf-8") as handle:
            overrides = json.load(handle)

    paths: list[tuple[str, str]] = []
    for dirpath, _, filenames in os.walk(args.root):
        for filename in sorted(filenames):
            if filename.lower().endswith(".mp4"):
                paths.append((os.path.join(dirpath, filename), os.path.basename(dirpath)))
    paths.sort(key=lambda pair: (pair[1], os.path.basename(pair[0])))

    results = []
    for path, category in paths:
        item, signal = measure(path, category, overrides)
        results.append((item, signal))
        print(f"measured {item.slug}", flush=True)

    measurements = [item for item, _ in results]

    with open(f"{args.out}.csv", "w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(asdict(measurements[0]).keys()))
        writer.writeheader()
        for item in measurements:
            writer.writerow(asdict(item))

    with open(f"{args.out}.json", "w", encoding="utf-8") as handle:
        json.dump([asdict(m) for m in measurements], handle, indent=2)

    if args.plots:
        plot_dir = os.path.join(os.path.dirname(args.out), "motion_plots")
        os.makedirs(plot_dir, exist_ok=True)
        cells = [draw_cell(signal, item) for item, signal in results]
        per_sheet = COLUMNS * 6
        for start in range(0, len(cells), per_sheet):
            batch = list(cells[start : start + per_sheet])
            while len(batch) % COLUMNS:
                batch.append(np.full((CELL_HEIGHT, CELL_WIDTH, 3), 24, np.uint8))
            rows = [np.hstack(batch[i : i + COLUMNS]) for i in range(0, len(batch), COLUMNS)]
            cv2.imwrite(os.path.join(plot_dir, f"motion_{start // per_sheet + 1:02d}.jpg"), np.vstack(rows))
        print(f"\nplots -> {plot_dir}")

    holds = [m for m in measurements if m.step_type == "hold"]
    multi = [m for m in measurements if (m.reps_per_loop or 0) > 1]
    print(f"\n{len(measurements)} clips -> {args.out}.csv")
    print(f"  rep-based {len(measurements) - len(holds)}   holds {len(holds)}   reviewed {sum(1 for m in measurements if m.source == 'reviewed')}")
    print(f"\nholds: {', '.join(m.slug for m in holds) or 'none'}")
    print(f"\nmore than one rep per loop: {', '.join(f'{m.slug} x{m.reps_per_loop}' for m in multi) or 'none'}")


if __name__ == "__main__":
    main()
