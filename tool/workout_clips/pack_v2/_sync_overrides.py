import json

loops = {
    x["slug"]: x
    for x in json.load(open("tool/workout_clips/clip_loops_v2.json", encoding="utf-8"))
}
ov = json.load(open("tool/workout_clips/clip_overrides_v2.json", encoding="utf-8"))
for slug, entry in ov.items():
    if slug.startswith("_"):
        continue
    loop = loops.get(slug)
    if not loop:
        continue
    if loop["step_type"] == "hold":
        entry["reps_per_loop"] = None
    else:
        entry["reps_per_loop"] = loop["reps_per_loop"]

with open("tool/workout_clips/clip_overrides_v2.json", "w", encoding="utf-8") as handle:
    json.dump(ov, handle, indent=2, ensure_ascii=False)
    handle.write("\n")

print("synced reps from loops:")
for slug, loop in loops.items():
    print(
        f"  {slug}: {loop['step_type']} "
        f"reps={loop['reps_per_loop']} dur={loop['duration_seconds']}s"
    )
