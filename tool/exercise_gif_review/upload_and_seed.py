"""
Uploads approved exercise GIFs to Supabase Storage and seeds/upserts the
`exercise_media` table from the reviewed catalog.

This is intentionally separate from translate_gif_library.py: that script
only reads local files and never touches production. This script is the
one that actually writes to Supabase Storage + the database, so it always
prints exactly what it's about to do and supports --dry-run.

Prerequisite: the `exercise_media` table must already exist (run
celia-admin/supabase_exercise_media_migration.sql in the Supabase SQL
Editor first — this script cannot create tables, only rows/files).

Usage:
    python upload_and_seed.py --dry-run     # preview only, no writes
    python upload_and_seed.py               # real upload + seed
    python upload_and_seed.py --limit 10    # only process first 10 rows
"""

from __future__ import annotations

import argparse
import csv
import os
import sys
import time

import requests

SCRIPT_DIR = os.path.dirname(__file__)
REPO_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, "..", ".."))
ENV_LOCAL_PATH = os.path.join(REPO_ROOT, "celia-admin", ".env.local")
CATALOG_CSV = os.path.join(SCRIPT_DIR, "exercise_gif_catalog_en.csv")

BUCKET_NAME = "exercise-gifs"
TABLE_NAME = "exercise_media"
UPSERT_BATCH_SIZE = 100
REQUEST_TIMEOUT = 60  # seconds; without this, a stalled connection hangs forever
MAX_RETRIES = 3


def load_env_local(path: str) -> dict[str, str]:
    values: dict[str, str] = {}
    if not os.path.exists(path):
        raise SystemExit(f"Could not find {path}. Is celia-admin/.env.local set up?")
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, _, value = line.partition("=")
            values[key.strip()] = value.strip()
    return values


def ensure_bucket(base_url: str, headers: dict[str, str], dry_run: bool) -> None:
    check = requests.get(
        f"{base_url}/storage/v1/bucket/{BUCKET_NAME}",
        headers=headers,
        timeout=REQUEST_TIMEOUT,
    )
    if check.status_code == 200:
        print(f"Bucket '{BUCKET_NAME}' already exists.", flush=True)
        return

    print(f"Bucket '{BUCKET_NAME}' not found (status {check.status_code}).", flush=True)
    if dry_run:
        print("[dry-run] Would create public bucket now.", flush=True)
        return

    resp = requests.post(
        f"{base_url}/storage/v1/bucket",
        headers=headers,
        json={"id": BUCKET_NAME, "name": BUCKET_NAME, "public": True},
        timeout=REQUEST_TIMEOUT,
    )
    if resp.status_code not in (200, 201):
        raise SystemExit(f"Failed to create bucket: {resp.status_code} {resp.text}")
    print(f"Created public bucket '{BUCKET_NAME}'.", flush=True)


def check_table_exists(base_url: str, headers: dict[str, str]) -> bool:
    resp = requests.get(
        f"{base_url}/rest/v1/{TABLE_NAME}",
        headers=headers,
        params={"limit": 1},
        timeout=REQUEST_TIMEOUT,
    )
    return resp.status_code == 200


def list_existing_objects(base_url: str, headers: dict[str, str]) -> set[str]:
    """Slugs (without .gif) already present in the bucket, so re-runs skip
    what's already uploaded instead of re-sending every file."""
    existing: set[str] = set()
    offset = 0
    page_size = 1000
    while True:
        resp = requests.post(
            f"{base_url}/storage/v1/object/list/{BUCKET_NAME}",
            headers=headers,
            json={"limit": page_size, "offset": offset, "prefix": ""},
            timeout=REQUEST_TIMEOUT,
        )
        if resp.status_code != 200:
            break
        page = resp.json()
        if not page:
            break
        for item in page:
            name = item.get("name", "")
            if name.endswith(".gif"):
                existing.add(name[: -len(".gif")])
        if len(page) < page_size:
            break
        offset += page_size
    return existing


def upload_gif(
    base_url: str,
    headers: dict[str, str],
    slug: str,
    abs_path: str,
    dry_run: bool,
    already_uploaded: set[str],
) -> str:
    object_path = f"{slug}.gif"
    public_url = f"{base_url}/storage/v1/object/public/{BUCKET_NAME}/{object_path}"

    if dry_run or slug in already_uploaded:
        return public_url

    with open(abs_path, "rb") as f:
        data = f.read()

    upload_headers = dict(headers)
    upload_headers["Content-Type"] = "image/gif"
    upload_headers["x-upsert"] = "true"

    last_error: Exception | None = None
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            resp = requests.post(
                f"{base_url}/storage/v1/object/{BUCKET_NAME}/{object_path}",
                headers=upload_headers,
                data=data,
                timeout=REQUEST_TIMEOUT,
            )
            if resp.status_code in (200, 201):
                return public_url
            last_error = RuntimeError(f"Upload failed ({resp.status_code}): {resp.text}")
        except requests.RequestException as exc:
            last_error = exc
        if attempt < MAX_RETRIES:
            time.sleep(2 * attempt)

    raise last_error if last_error else RuntimeError("Upload failed for unknown reason")


def upsert_rows(
    base_url: str, headers: dict[str, str], rows: list[dict], dry_run: bool
) -> None:
    if dry_run:
        print(f"[dry-run] Would upsert {len(rows)} rows into {TABLE_NAME}.")
        return

    upsert_headers = dict(headers)
    upsert_headers["Content-Type"] = "application/json"
    upsert_headers["Prefer"] = "resolution=merge-duplicates,return=minimal"

    for i in range(0, len(rows), UPSERT_BATCH_SIZE):
        batch = rows[i : i + UPSERT_BATCH_SIZE]
        resp = requests.post(
            f"{base_url}/rest/v1/{TABLE_NAME}?on_conflict=slug",
            headers=upsert_headers,
            json=batch,
            timeout=REQUEST_TIMEOUT,
        )
        if resp.status_code not in (200, 201, 204):
            raise RuntimeError(
                f"Upsert failed for batch {i}-{i + len(batch)}: "
                f"{resp.status_code} {resp.text}"
            )
        print(f"  Upserted rows {i + 1}-{i + len(batch)} of {len(rows)}", flush=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--limit", type=int, default=None)
    parser.add_argument(
        "--include-needs-review",
        action="store_true",
        help="Also upload the items flagged 'needs_review' using the best-guess "
        "translation, instead of only 'high' confidence rows.",
    )
    args = parser.parse_args()

    env = load_env_local(ENV_LOCAL_PATH)
    base_url = env.get("NEXT_PUBLIC_SUPABASE_URL", "").rstrip("/")
    service_key = env.get("SUPABASE_SERVICE_ROLE_KEY", "")
    if not base_url or not service_key:
        raise SystemExit("Missing NEXT_PUBLIC_SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY.")

    headers = {"apikey": service_key, "Authorization": f"Bearer {service_key}"}

    print(f"Target project: {base_url}")
    print(f"Mode: {'DRY RUN (no writes)' if args.dry_run else 'LIVE'}")
    print()

    ensure_bucket(base_url, headers, args.dry_run)

    already_uploaded = set() if args.dry_run else list_existing_objects(base_url, headers)
    if already_uploaded:
        print(
            f"{len(already_uploaded)} GIFs already in storage — will skip re-uploading those.",
            flush=True,
        )

    table_ok = check_table_exists(base_url, headers)
    if not table_ok and not args.dry_run:
        raise SystemExit(
            "\nThe 'exercise_media' table does not exist yet.\n"
            "Run celia-admin/supabase_exercise_media_migration.sql in the "
            "Supabase SQL Editor first, then re-run this script."
        )
    if not table_ok:
        print("[dry-run] Note: exercise_media table does not exist yet — "
              "run the migration before the real upload.")

    with open(CATALOG_CSV, encoding="utf-8") as f:
        all_rows = list(csv.DictReader(f))

    allowed_confidence = (
        {"high", "needs_review"} if args.include_needs_review else {"high"}
    )
    approved = [
        r
        for r in all_rows
        if r["confidence"] in allowed_confidence
        and r["duplicate_of_existing_slug"] == "no"
    ]
    if args.limit:
        approved = approved[: args.limit]

    print(f"\nApproved rows to process: {len(approved)} (of {len(all_rows)} total)\n")

    seed_rows: list[dict] = []
    failures: list[str] = []
    start = time.time()

    pending_seed_rows: list[dict] = []

    for idx, row in enumerate(approved, start=1):
        slug = row["slug"]
        abs_path = row["source_abs_path"]
        try:
            public_url = upload_gif(
                base_url, headers, slug, abs_path, args.dry_run, already_uploaded
            )
            seed_row = {
                "slug": slug,
                "display_name": row["display_name_en"],
                "muscle_group": row["muscle_group"] or None,
                "category": row["category"],
                "gif_url": public_url,
                "is_placeholder": True,
                "source": "stock_pack_v1",
            }
            seed_rows.append(seed_row)
            pending_seed_rows.append(seed_row)
        except Exception as exc:  # noqa: BLE001 - report and continue
            failures.append(f"{slug}: {exc}")

        if idx % 25 == 0 or idx == len(approved):
            elapsed = time.time() - start
            print(f"  Uploaded {idx}/{len(approved)} ({elapsed:.1f}s elapsed)", flush=True)

        # Seed incrementally so a later interruption doesn't lose earlier
        # upload progress in the database too.
        if len(pending_seed_rows) >= UPSERT_BATCH_SIZE:
            upsert_rows(base_url, headers, pending_seed_rows, args.dry_run)
            pending_seed_rows = []

    print(flush=True)
    upsert_rows(base_url, headers, pending_seed_rows, args.dry_run)

    print()
    print(f"Done. Succeeded: {len(seed_rows)}. Failed: {len(failures)}.")
    if failures:
        print("Failures:")
        for line in failures[:20]:
            print(f"  - {line}")
        if len(failures) > 20:
            print(f"  ... and {len(failures) - 20} more.")


if __name__ == "__main__":
    main()
