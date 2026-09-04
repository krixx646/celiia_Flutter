# -*- coding: utf-8 -*-
"""Print why a given clip's loop was chosen, for tuning the search."""

from __future__ import annotations

import argparse
import json
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(__file__))
import make_loops as ml  # noqa: E402

HERE = os.path.dirname(__file__)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", required=True)
    parser.add_argument("slugs", nargs="+")
    args = parser.parse_args()

    with open(os.path.join(HERE, "clip_loops.json"), encoding="utf-8") as handle:
        loops = {item["slug"]: item for item in json.load(handle)}

    for slug in args.slugs:
        loop = loops[slug]
        path = os.path.join(args.root, loop["category"], loop["filename"])
        frames, fps = ml.read_thumbnails(path)

        first = int(loop["start_seconds"] * fps)
        last = min(len(frames) - 1, int(loop["end_seconds"] * fps) - 1)

        position = ml.pairwise(frames)
        window_travel = float(position[first, first : last + 1].max())
        clip_travel = float(position.max())
        start_travel = float(position[first].max())

        print(
            f"{slug}: loop {loop['duration_seconds']}s of {loop['original_seconds']}s\n"
            f"   travel inside loop      {window_travel:.4f}\n"
            f"   travel from same start  {start_travel:.4f}"
            f"  ({window_travel / max(start_travel, 1e-6):.0%} covered)\n"
            f"   widest pose gap in clip {clip_travel:.4f}"
            f"  ({window_travel / max(clip_travel, 1e-6):.0%} covered)"
        )


if __name__ == "__main__":
    main()
