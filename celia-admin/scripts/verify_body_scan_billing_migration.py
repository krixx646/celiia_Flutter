"""Verify 20261006_body_scan_billing.sql landed on the app Supabase project.

Uses curl.exe because this environment's Python SSL stack intermittently fails
against supabase.co (SSLV3_ALERT_BAD_RECORD_MAC).
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile

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
) -> tuple[int, str]:
    cmd = [
        "curl.exe",
        "-sS",
        "-w",
        "\n%{http_code}",
        "-X",
        method,
        f"{base}{path}",
        "-H",
        f"apikey: {key}",
        "-H",
        f"Authorization: Bearer {key}",
        "-H",
        "Content-Type: application/json",
        "--max-time",
        "45",
    ]
    tmp_path = None
    if body is not None:
        fd, tmp_path = tempfile.mkstemp(suffix=".json")
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            json.dump(body, handle)
        cmd.extend(["--data-binary", f"@{tmp_path}"])
    try:
        completed = subprocess.run(cmd, capture_output=True, text=True, check=False)
    finally:
        if tmp_path and os.path.exists(tmp_path):
            os.remove(tmp_path)
    if completed.returncode != 0 and not completed.stdout.strip():
        raise RuntimeError(completed.stderr.strip() or "curl failed")
    text = completed.stdout.rstrip("\r\n")
    # Empty-body responses (e.g. 204) come back as just the status code.
    if "\n" not in text:
        try:
            return int(text.strip()), ""
        except ValueError:
            return 0, text
    body_text, code_text = text.rsplit("\n", 1)
    try:
        code = int(code_text.strip())
    except ValueError:
        code = 0
    return code, body_text


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

    status, body = request(
        url,
        key,
        "/rest/v1/user_entitlements?select=user_id,bonus_scans,last_consume_bonus&limit=1",
    )
    checks.append(
        (
            "user_entitlements has bonus columns",
            status in (200, 206),
            f"{status} {body[:200]}",
        )
    )

    status, body = request(url, key, "/rest/v1/purchases?select=id&limit=1")
    checks.append(("purchases selectable", status in (200, 206), f"{status} {body[:160]}"))

    status, body = request(url, key, "/rest/v1/scanner_codes?select=code&limit=1")
    checks.append(("scanner_codes selectable", status in (200, 206), f"{status} {body[:160]}"))

    status, body = request(
        url, key, "/rest/v1/scanner_code_redemptions?select=id&limit=1"
    )
    checks.append(
        (
            "scanner_code_redemptions selectable",
            status in (200, 206),
            f"{status} {body[:160]}",
        )
    )

    verify_uid = "__billing_migration_verify__"
    status, body = request(
        url,
        key,
        "/rest/v1/rpc/grant_body_scan_scans",
        method="POST",
        body={"p_user_id": verify_uid, "p_scans": 2},
    )
    grant_ok = False
    grant_remaining = None
    if status in (200, 201):
        try:
            rows = json.loads(body)
            row = rows[0] if isinstance(rows, list) and rows else rows
            grant_remaining = row.get("remaining") if isinstance(row, dict) else None
            grant_ok = isinstance(grant_remaining, int) and grant_remaining >= 2
        except json.JSONDecodeError:
            grant_ok = False
    checks.append(
        (
            "grant_body_scan_scans works",
            grant_ok,
            f"{status} remaining={grant_remaining} {body[:160]}",
        )
    )

    status, body = request(
        url,
        key,
        "/rest/v1/rpc/consume_body_scan_quota",
        method="POST",
        body={"p_user_id": verify_uid},
    )
    consume_ok = False
    if status in (200, 201):
        try:
            rows = json.loads(body)
            row = rows[0] if isinstance(rows, list) and rows else rows
            consume_ok = bool(row.get("allowed")) if isinstance(row, dict) else False
        except json.JSONDecodeError:
            consume_ok = False
    checks.append(("consume uses bonus path", consume_ok, f"{status} {body[:200]}"))

    status, body = request(
        url,
        key,
        "/rest/v1/rpc/refund_body_scan_quota",
        method="POST",
        body={"p_user_id": verify_uid},
    )
    checks.append(
        ("refund_body_scan_quota callable", status in (200, 204), f"{status} {body[:120]}")
    )

    code = "VERIFY-BILLING-TMP"
    request(
        url,
        key,
        "/rest/v1/scanner_codes",
        method="POST",
        body={
            "code": code,
            "scans_grant": 1,
            "max_redemptions": 1,
            "note": "migration verify — delete me",
        },
    )
    status, body = request(
        url,
        key,
        "/rest/v1/rpc/redeem_scanner_code",
        method="POST",
        body={"p_user_id": f"{verify_uid}_redeem", "p_code": code},
    )
    redeem_ok = False
    if status in (200, 201):
        try:
            rows = json.loads(body)
            row = rows[0] if isinstance(rows, list) and rows else rows
            redeem_ok = bool(row.get("ok")) if isinstance(row, dict) else False
        except json.JSONDecodeError:
            redeem_ok = False
    checks.append(("redeem_scanner_code works", redeem_ok, f"{status} {body[:200]}"))

    # Atomic purchase: first call grants, an identical replay must not.
    purchase_uid = f"{verify_uid}_purchase"
    purchase_args = {
        "p_user_id": purchase_uid,
        "p_platform": "android",
        "p_product_id": "eu.thefit.celia.body_scan.single",
        "p_transaction_id": "VERIFY-TXN-1",
        "p_purchase_token": "verify-token",
        "p_scans": 1,
        "p_raw": {"verify": True},
    }

    def purchase_row() -> tuple[int, dict | None, str]:
        status_, body_ = request(
            url,
            key,
            "/rest/v1/rpc/record_purchase_and_grant",
            method="POST",
            body=purchase_args,
        )
        row_ = None
        if status_ in (200, 201):
            try:
                rows_ = json.loads(body_)
                row_ = rows_[0] if isinstance(rows_, list) and rows_ else rows_
            except json.JSONDecodeError:
                row_ = None
        return status_, row_, body_

    first_status, first, first_body = purchase_row()
    second_status, second, second_body = purchase_row()
    purchase_ok = (
        isinstance(first, dict)
        and isinstance(second, dict)
        and first.get("granted") is True
        and second.get("granted") is False
        and first.get("remaining") == second.get("remaining")
    )
    checks.append(
        (
            "record_purchase_and_grant grants once, replay is a no-op",
            purchase_ok,
            f"first={first_status} {first_body[:100]} second={second_status} {second_body[:100]}",
        )
    )
    request(
        url,
        key,
        "/rest/v1/purchases?transaction_id=eq.VERIFY-TXN-1",
        method="DELETE",
    )
    request(
        url, key, f"/rest/v1/user_entitlements?user_id=eq.{purchase_uid}", method="DELETE"
    )

    request(
        url, key, f"/rest/v1/scanner_code_redemptions?code=eq.{code}", method="DELETE"
    )
    request(url, key, f"/rest/v1/scanner_codes?code=eq.{code}", method="DELETE")
    request(
        url, key, f"/rest/v1/user_entitlements?user_id=eq.{verify_uid}", method="DELETE"
    )
    request(
        url,
        key,
        f"/rest/v1/user_entitlements?user_id=eq.{verify_uid}_redeem",
        method="DELETE",
    )

    failed = 0
    for name, ok, detail in checks:
        mark = "OK" if ok else "FAIL"
        if not ok:
            failed += 1
        print(f"[{mark}] {name}: {detail}")

    if failed:
        print(f"\n{failed} check(s) failed")
        return 1
    print("\nAll billing migration checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
