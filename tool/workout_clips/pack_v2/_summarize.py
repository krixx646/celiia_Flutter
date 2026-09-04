import json

m = json.load(open("tool/workout_clips/clip_manifest_v2.json", encoding="utf-8"))
print(f"{len(m)} clips")
for i in m:
    print(
        f"{i['slug']:40} {i['step_type']:5} "
        f"reps={i['reps_per_loop'] or '-':>3} "
        f"dur={i['duration_seconds']:6} "
        f"rep_s={i.get('rep_seconds') or '-':>6} "
        f"{i['source']}"
    )
