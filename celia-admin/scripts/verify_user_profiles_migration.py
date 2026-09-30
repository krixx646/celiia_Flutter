"""Verify 20260914_user_profiles.sql landed on the app Supabase project.

The table has to be created by hand in the SQL editor (the service key can run
queries but not DDL), so this confirms the result and reports which columns the
API is actually able to see.
"""

from __future__ import annotations

import http.client
import json
import os
import ssl
import time
import urllib.error
import urllib.request

# This machine intermittently drops the TLS session to Supabase with
# SSLV3_ALERT_BAD_RECORD_MAC, sometimes several times in a row. Retrying the
# request gets through; it is not a signal about the migration.
# Measured: individual requests needed up to 7 attempts to get through.
RETRIES = 15
RETRY_DELAY_SECONDS = 1.0

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
ENV_LOCAL = os.path.join(ROOT, ".env.local")

# Every column the mobile profile endpoint reads or writes.
COLUMNS = (
    "user_id,terms_accepted_at,terms_version,sex,age,weight_kg,height_cm,bmr_kcal,"
    "primary_goal,diet_pattern,dietary_conditions,food_allergies,"
    "disordered_eating_history,nutrition_mode,daily_water_ml,daily_calories,"
    "daily_protein_grams,daily_carbs_grams,daily_fat_grams,training_location,"
    "uses_equipment,available_equipment,"
    "injuries,medical_conditions,fitness_goal,desired_outcomes,training_intensity,"
    "experience_level,planning_mode,minutes_per_day,preferred_training_time,"
    "current_mood,coaching_focus,notification_prefs,wearable_provider,"
    "onboarding_version,onboarding_completed_at,created_at,updated_at"
)

TEST_USER = "__migration_verify__"


def load_env() -> dict[str, str]:
    env: dict[str, str] = {}
    with open(ENV_LOCAL, encoding="utf-8") as handle:
        for raw in handle:
            line = raw.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            env[key.strip()] = value.strip().strip('"').strip("'")
    return env


def request(
    base: str,
    key: str,
    path: str,
    method: str = "GET",
    body: dict | None = None,
    prefer: str | None = None,
) -> tuple[int, str]:
    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
    }
    if prefer:
        headers["Prefer"] = prefer
    data = None if body is None else json.dumps(body).encode()

    last_error: Exception | None = None
    for attempt in range(RETRIES):
        req = urllib.request.Request(
            base + path, data=data, headers=headers, method=method
        )
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                return resp.status, resp.read().decode()
        except urllib.error.HTTPError as exc:
            # A status is an answer, not a failure: return it for the caller to judge.
            return exc.code, exc.read().decode()
        except (
            ssl.SSLError,
            urllib.error.URLError,
            http.client.HTTPException,  # includes RemoteDisconnected
            ConnectionError,
            TimeoutError,
        ) as exc:
            last_error = exc
            print(
                f"  transport error (attempt {attempt + 1}/{RETRIES}): {exc}",
                flush=True,
            )
            time.sleep(RETRY_DELAY_SECONDS)

    return 0, f"transport failed after {RETRIES} attempts: {last_error}"


def main() -> int:
    env = load_env()
    url = env.get("NEXT_PUBLIC_SUPABASE_URL") or env.get("SUPABASE_URL") or ""
    key = env.get("SUPABASE_SERVICE_ROLE_KEY") or env.get("SUPABASE_SERVICE_KEY") or ""

    print(f"project: {url}")
    if "zgwxdpxhddcswdmectsm" not in url:
        print("FAIL: refusing to check a project other than zgwxdpxhddcswdmectsm")
        return 1
    if not key:
        print("FAIL: missing service role key")
        return 1

    checks: list[tuple[str, bool, str]] = []

    status, body = request(url, key, "/rest/v1/user_profiles?select=user_id&limit=1")
    table_exists = status in (200, 206)
    checks.append(("user_profiles selectable", table_exists, f"{status} {body[:200]}"))

    if not table_exists:
        print()
        print(f"[FAIL] user_profiles selectable: {status} {body[:200]}")
        print()
        print("Run supabase/migrations/20260914_user_profiles.sql in the SQL editor,")
        print("then re-run this script.")
        return 1

    status, body = request(url, key, f"/rest/v1/user_profiles?select={COLUMNS}&limit=1")
    checks.append(("all columns present", status in (200, 206), f"{status} {body[:300]}"))

    # A write proves the upsert the endpoint performs actually works, including
    # the array and jsonb defaults.
    status, body = request(
        url,
        key,
        "/rest/v1/user_profiles?on_conflict=user_id",
        method="POST",
        body={
            "user_id": TEST_USER,
            "primary_goal": "lose_weight",
            "injuries": ["knee"],
            "notification_prefs": {"meals": True},
            "onboarding_version": 1,
        },
        prefer="resolution=merge-duplicates,return=representation",
    )
    checks.append(("upsert round trip", status in (200, 201), f"{status} {body[:300]}"))

    status, body = request(
        url,
        key,
        f"/rest/v1/user_profiles?user_id=eq.{TEST_USER}",
        method="DELETE",
        prefer="return=minimal",
    )
    checks.append(("cleanup verify row", status in (200, 204), f"{status} {body[:80]}"))

    print()
    all_ok = True
    for name, passed, detail in checks:
        mark = "PASS" if passed else "FAIL"
        if not passed:
            all_ok = False
        print(f"[{mark}] {name}: {detail}")

    print()
    print("ALL OK" if all_ok else "SOME CHECKS FAILED")
    return 0 if all_ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
