# -*- coding: utf-8 -*-
"""Trim the client's demo clips so they loop without a visible cut.

The clips were filmed as demonstrations, not as loops: each one starts and
ends wherever the camera was cut, usually mid-rep. Playing that on repeat
snaps the body from its closing position back to its opening position once
per loop, which is the jump you see on some exercises and not others.

The fix is to end each clip on the frame that looks most like the frame it
starts on. Because a rep returns the body to where it began, that frame is
also a whole-rep boundary, so a trimmed clip both loops cleanly and keeps the
count honest.

Holds are left alone. Every frame of a plank looks like every other frame, so
there is no seam to find and nothing to gain by cutting.

    python tool/workout_clips/make_loops.py --root "<clips folder>" --out "<output folder>"
    python tool/workout_clips/make_loops.py --root "<clips folder>" --report-only
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys

import cv2
import numpy as np

HERE = os.path.dirname(__file__)
MANIFEST_PATH = os.path.join(HERE, "clip_manifest.json")
LOOPS_PATH = os.path.join(HERE, "clip_loops.json")

# Frames are compared as small greyscale thumbnails. Big enough to tell one
# body position from another, small enough that lighting noise and encoder
# grain don't drown out the comparison.
THUMB = (64, 64)

# A loop shorter than this fraction of one reviewed rep is a fragment of a
# movement rather than a repeat of it, and the search will happily pick one:
# the pause at the bottom of a squat offers a run of near-identical frames
# that looks like a flawless, and completely motionless, loop.
#
# The reviewed rep timings are not accurate enough to cut to, but they are
# easily good enough to rule such fragments out, which is all they are used
# for here.
MIN_LENGTH_OF_REP = 0.55

# Floor and ceiling on that, for clips whose reviewed timing is wildly off.
MIN_LOOP_SECONDS = 0.7
MAX_LENGTH_OF_SHOT = 0.9

# Tie-break only: among loops that seam equally well, prefer the shorter one,
# which is one rep rather than two. Kept small so it can never buy a worse
# seam in exchange for a shorter clip.
LENGTH_PENALTY = 0.0008

# A frame counts as a return to the loop's opening pose when it comes back
# within this fraction of the furthest the exercise travels. Used to count how
# many reps the trimmed loop contains.
RETURN_FRACTION = 0.3

# Weight on matching the direction of travel as well as the position. Two
# frames can show the same pose on the way down and on the way up; without
# this the loop happily splices a descent onto an ascent and calls half a rep
# a whole one. Frame-to-frame motion is far smaller in magnitude than the
# difference between poses, hence the heavy weight.
MOTION_WEIGHT = 3.0

# Frame-to-frame motion is smoothed over this many frames before comparing, so
# encoder noise doesn't swamp the direction signal.
MOTION_SMOOTHING = 3

# A hard camera cut mid-clip: two of the client's clips change angle partway
# through, and no loop can cross that. Measured against the clip's own typical
# frame-to-frame movement, so a fast exercise isn't mistaken for an edit.
CUT_ABSOLUTE = 0.06
CUT_RELATIVE = 6.0

# The shortest usable shot. Below this there isn't room for a rep.
MIN_SHOT_SECONDS = 1.2

# Clips whose best cut still leaves a seam this visible get it dissolved
# rather than cut, over the following number of seconds.
CROSSFADE_ABOVE_SEAM = 0.05
CROSSFADE_SECONDS = 0.25


def read_thumbnails(path: str) -> tuple[np.ndarray, float]:
    """Every frame of the clip as a normalised greyscale thumbnail stack."""
    capture = cv2.VideoCapture(path)
    fps = capture.get(cv2.CAP_PROP_FPS) or 24.0
    frames = []
    while True:
        ok, frame = capture.read()
        if not ok:
            break
        small = cv2.resize(frame, THUMB, interpolation=cv2.INTER_AREA)
        grey = cv2.cvtColor(small, cv2.COLOR_BGR2GRAY).astype(np.float32) / 255.0
        frames.append(grey)
    capture.release()
    return np.array(frames), fps


def pairwise(stack: np.ndarray) -> np.ndarray:
    """Mean absolute difference between every pair of rows."""
    flat = stack.reshape(len(stack), -1)
    out = np.empty((len(flat), len(flat)), dtype=np.float32)
    for i in range(len(flat)):
        out[i] = np.abs(flat - flat[i]).mean(axis=1)
    return out


def find_shots(frames: np.ndarray, fps: float) -> list[tuple[int, int]]:
    """Split the clip at hard camera cuts into (first, last) frame ranges."""
    steps = np.abs(np.diff(frames, axis=0)).mean(axis=(1, 2))
    threshold = max(CUT_ABSOLUTE, CUT_RELATIVE * float(np.median(steps)))
    cuts = [int(i) + 1 for i in np.where(steps > threshold)[0]]

    bounds = [0, *cuts, len(frames)]
    shots = [(a, b - 1) for a, b in zip(bounds, bounds[1:])]
    long_enough = [s for s in shots if s[1] - s[0] >= MIN_SHOT_SECONDS * fps]
    return long_enough or [(0, len(frames) - 1)]


def best_loop_in(
    frames: np.ndarray, fps: float, first: int, last: int, rep_seconds: float
) -> tuple[int, int, float]:
    """Lowest-cost loop wholly inside one shot, as (start, end, seam cost)."""
    shot = frames[first : last + 1]
    count = len(shot)

    # How unlike each other two frames look, and whether the body is moving
    # the same way in both. Position alone would happily splice the descent of
    # one rep onto the ascent of the next, which passes through the same poses.
    position = pairwise(shot)
    smoothed = np.array(
        [
            shot[i + MOTION_SMOOTHING] - shot[i]
            for i in range(count - MOTION_SMOOTHING)
        ]
    )
    motion = pairwise(smoothed)

    seam = position.copy()
    span = len(motion)
    seam[:span, :span] += MOTION_WEIGHT * motion

    whole = float(seam[0, count - 1])

    min_length = int(
        min(
            max(MIN_LENGTH_OF_REP * rep_seconds * fps, MIN_LOOP_SECONDS * fps),
            MAX_LENGTH_OF_SHOT * count,
        )
    )
    if count <= min_length + 1:
        return first, last, whole

    lengths = np.subtract.outer(np.arange(count), np.arange(count)).T / fps
    score = seam + LENGTH_PENALTY * lengths

    valid = np.triu(np.ones((count, count), dtype=bool), k=min_length)
    masked = np.where(valid, score, np.inf)
    start, end = np.unravel_index(np.argmin(masked), masked.shape)
    return first + int(start), first + int(end), float(seam[start, end])


def count_reps(frames: np.ndarray, start: int, end: int) -> int:
    """How many times the loop returns to the pose it opened on."""
    window = frames[start : end + 1]
    distance = np.abs(window - window[0]).mean(axis=(1, 2))
    if distance.max() <= 0:
        return 1

    near = distance <= RETURN_FRACTION * distance.max()

    # Each run of frames close to the opening pose is one visit, and the run
    # the clip starts in is the departure rather than a return.
    reps, in_run, leading = 0, near[0], near[0]
    for close in near[1:]:
        if close and not in_run:
            if leading:
                leading = False
            reps += 1
        in_run = close
    if leading:
        reps = max(reps, 1)
    return max(1, reps)


def find_loop(
    frames: np.ndarray, fps: float, rep_seconds: float
) -> tuple[int, int, float, float]:
    """Best (start, end) cut, with the seam cost before and after trimming.

    Every possible cut within a shot is scored, rather than only those near a
    rep boundary we think we already know: several clips open midway through a
    rep, and the reviewed rep counts are not reliable enough to narrow the
    search by.
    """
    before = float(np.abs(frames[-1] - frames[0]).mean())

    candidates = [
        best_loop_in(frames, fps, first, last, rep_seconds)
        for first, last in find_shots(frames, fps)
    ]
    start, end, after = min(candidates, key=lambda c: c[2])

    # Some clips were filmed to loop already. Trimming those can only lose
    # footage, so the untouched clip wins unless the cut genuinely beats it.
    if after >= before:
        return 0, len(frames) - 1, before, before
    return start, end, before, after


def encode(
    source: str, target: str, start_s: float, end_s: float, crossfade: float = 0.0
) -> None:
    """Cut [start_s, end_s) out of the clip, optionally hiding the seam.

    A handful of clips have no clean cut at all, because the performer drifts
    across the floor as they work and never returns to where they began. For
    those, the tail is dissolved into the head so the jump becomes a brief
    blend instead of a snap.
    """
    encoding = [
        "-c:v", "libx264", "-preset", "slow", "-crf", "20",
        "-pix_fmt", "yuv420p", "-movflags", "+faststart", target,
    ]

    if crossfade <= 0:
        # Seeking after the input rather than before it. Input seeking lands
        # on the nearest keyframe, which is enough to drift a cut across a
        # camera change and produce a far worse loop than the one measured.
        subprocess.run(
            [
                "ffmpeg", "-y", "-loglevel", "error", "-i", source,
                "-ss", f"{start_s:.3f}", "-to", f"{end_s:.3f}", "-an", *encoding,
            ],
            check=True,
        )
        return

    # The graph cuts from the untouched source, so every boundary here is an
    # exact timestamp in the original rather than an offset into a pre-seeked
    # stream.
    body_start = start_s + crossfade
    tail_start = end_s - crossfade
    graph = (
        f"[0:v]trim=start={body_start:.3f}:end={tail_start:.3f},"
        "setpts=PTS-STARTPTS[body];"
        f"[0:v]trim=start={start_s:.3f}:end={body_start:.3f},"
        "setpts=PTS-STARTPTS[head];"
        f"[0:v]trim=start={tail_start:.3f}:end={end_s:.3f},"
        "setpts=PTS-STARTPTS[tail];"
        f"[tail][head]blend=all_expr='A*(1-T/{crossfade:.3f})"
        f"+B*(T/{crossfade:.3f})'[dissolve];"
        "[body][dissolve]concat=n=2:v=1:a=0[out]"
    )
    subprocess.run(
        [
            "ffmpeg", "-y", "-loglevel", "error", "-i", source,
            "-filter_complex", graph, "-map", "[out]", "-an", *encoding,
        ],
        check=True,
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", required=True, help="Folder holding the client's category folders")
    parser.add_argument("--out", help="Where to write the looped clips")
    parser.add_argument("--report-only", action="store_true", help="Measure the seams without writing any video")
    parser.add_argument("--manifest", default=MANIFEST_PATH, help="Clip measurements JSON")
    parser.add_argument("--loops-out", default=LOOPS_PATH, help="Where to write loop cut metadata")
    args = parser.parse_args()

    if not args.out and not args.report_only:
        sys.exit("pass --out, or --report-only to just measure")

    with open(args.manifest, encoding="utf-8") as handle:
        manifest = json.load(handle)

    results = []
    for index, item in enumerate(manifest, start=1):
        source = os.path.join(args.root, item["category"], item["filename"])
        if not os.path.exists(source):
            print(f"[{index}/{len(manifest)}] missing {item['slug']}")
            continue

        frames, fps = read_thumbnails(source)
        if len(frames) < 8:
            print(f"[{index}/{len(manifest)}] too short to analyse: {item['slug']}")
            continue

        if item["step_type"] == "hold":
            # A held position has no rep cycle to cut to, so the clip is kept
            # whole. That does not mean it has no seam: the carries walk the
            # length of the room, ending nowhere near where they began, and
            # those are dissolved below like any other stubborn clip.
            start_frame, end_frame = 0, len(frames) - 1
            before = after = float(np.abs(frames[-1] - frames[0]).mean())
            reps_per_loop = None
        else:
            rep_seconds = item.get("rep_seconds") or item["duration_seconds"]
            start_frame, end_frame, before, after = find_loop(frames, fps, rep_seconds)
            reps_per_loop = count_reps(frames, start_frame, end_frame)

        start_s = start_frame / fps
        # Half a frame short of the next frame's timestamp. Landing exactly on
        # it is ambiguous, and ffmpeg resolves the tie by including that frame
        # — which on a clip that changes camera angle means the loop ends on
        # the first frame of the wrong shot.
        end_s = (end_frame + 0.5) / fps
        crossfade = CROSSFADE_SECONDS if after > CROSSFADE_ABOVE_SEAM else 0.0
        duration = round(end_s - start_s - crossfade, 2)

        record = {
            "slug": item["slug"],
            "category": item["category"],
            "filename": item["filename"],
            "step_type": item["step_type"],
            "start_seconds": round(start_s, 3),
            "end_seconds": round(end_s, 3),
            "duration_seconds": duration,
            "original_seconds": item["duration_seconds"],
            "reps_per_loop": reps_per_loop,
            "was_reps_per_loop": item.get("reps_per_loop"),
            "seam_before": round(before, 4),
            "seam_after": round(after, 4),
            "crossfade_seconds": crossfade,
        }
        results.append(record)

        if args.out:
            target_dir = os.path.join(args.out, item["category"])
            os.makedirs(target_dir, exist_ok=True)
            encode(
                source,
                os.path.join(target_dir, item["filename"]),
                start_s,
                end_s,
                crossfade,
            )

        if item["step_type"] == "hold":
            change = f"hold, kept whole, seam {before:.3f}" + (
                ", dissolved" if crossfade else ""
            )
        else:
            change = (
                f"seam {before:.3f} -> {after:.3f}, "
                f"{item['duration_seconds']}s -> {duration}s "
                f"({item.get('reps_per_loop')} -> {reps_per_loop} reps/loop)"
                + (", dissolved" if crossfade else "")
            )
        print(f"[{index}/{len(manifest)}] {item['slug']}: {change}", flush=True)

    with open(args.loops_out, "w", encoding="utf-8") as handle:
        json.dump(results, handle, indent=2)

    reps = [r for r in results if r["step_type"] == "reps"]
    improved = [r for r in reps if r["seam_after"] < r["seam_before"] * 0.9]
    stubborn = [r for r in reps if r["seam_after"] > 0.05]

    print(f"\n{len(results)} clips measured, {len(reps)} counted exercises")
    print(f"  {len(improved)} materially better seams")
    if stubborn:
        print(f"  still visible on: {', '.join(r['slug'] for r in stubborn)}")
    print(f"\nwrote {args.loops_out}")


if __name__ == "__main__":
    main()
