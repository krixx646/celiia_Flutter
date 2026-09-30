"""Verify 20260903_body_scans.sql landed on the app Supabase project."""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
ENV_LOCAL = os.path.join(ROOT, ".env.local")


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
    req = urllib.request.Request(base + path, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return resp.status, resp.read().decode()
    except urllib.error.HTTPError as exc:
        return exc.code, exc.read().decode()


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

    status, body = request(url, key, "/rest/v1/body_scans?select=id&limit=1")
    checks.append(("body_scans selectable", status in (200, 206), f"{status} {body[:160]}"))

    status, body = request(url, key, "/rest/v1/user_entitlements?select=user_id&limit=1")
    checks.append(
        ("user_entitlements selectable", status in (200, 206), f"{status} {body[:160]}")
    )

    status, body = request(
        url,
        key,
        "/rest/v1/rpc/consume_body_scan_quota",
        method="POST",
        body={"p_user_id": "__migration_verify__"},
    )
    ok = status == 200
    checks.append(("consume_body_scan_quota RPC", ok, f"{status} {body[:220]}"))
    if ok:
        print("quota sample:", body)

    status, body = request(
        url,
        key,
        "/rest/v1/rpc/refund_body_scan_quota",
        method="POST",
        body={"p_user_id": "__migration_verify__"},
    )
    # void SQL functions come back as 204 No Content from PostgREST.
    checks.append(
        ("refund_body_scan_quota RPC", status in (200, 204), f"{status} {body[:160]}")
    )

    status, body = request(url, key, "/storage/v1/bucket/body-meshes")
    checks.append(("body-meshes bucket", status == 200, f"{status} {body[:220]}"))

    # Confirm expected columns exist by selecting them.
    status, body = request(
        url,
        key,
        "/rest/v1/body_scans?select=id,user_id,vendor,body_fat_pct,lean_mass_g,"
        "body_fat_mass_g,measurements,posture,mesh_path,scanned_at&limit=1",
    )
    checks.append(("body_scans columns", status in (200, 206), f"{status} {body[:160]}"))

    status, body = request(
        url,
        key,
        "/rest/v1/user_entitlements?user_id=eq.__migration_verify__",
        method="DELETE",
        prefer="return=minimal",
    )
    checks.append(("cleanup verify entitlement", status in (200, 204), f"{status} {body[:80]}"))

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
