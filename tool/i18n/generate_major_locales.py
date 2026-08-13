"""Generate app_XX.arb files for major world languages from app_en.arb.

Uses the OpenAI key already configured for Celia. Placeholders like {count}
are preserved exactly. Metadata keys (@foo) are copied from English.

Usage:
  python tool/i18n/generate_major_locales.py
"""

from __future__ import annotations

import json
import os
import re
import sys
import time
import urllib.error
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
L10N = os.path.join(ROOT, "lib", "l10n")
ENV_LOCAL = os.path.join(ROOT, "celia-admin", ".env.local")

# Major world languages by speakers + major app markets. English and Spanish
# already ship and are skipped here.
TARGETS = {
    "fr": "French",
    "de": "German",
    "pt": "Portuguese (Brazilian)",
    "it": "Italian",
    "nl": "Dutch",
    "pl": "Polish",
    "ru": "Russian",
    "tr": "Turkish",
    "ar": "Arabic (Modern Standard)",
    "hi": "Hindi",
    "zh": "Simplified Chinese",
    "ja": "Japanese",
    "ko": "Korean",
    "id": "Indonesian",
    "vi": "Vietnamese",
    "th": "Thai",
}

PLACEHOLDER = re.compile(r"\{[a-zA-Z_][a-zA-Z0-9_]*\}")
MODEL = os.environ.get("OPENAI_TRANSLATE_MODEL", "gpt-5.6-luna")
BATCH = 60


def load_env_key() -> str:
    key = os.environ.get("OPENAI_API_KEY", "").strip()
    if key:
        return key
    if not os.path.isfile(ENV_LOCAL):
        raise SystemExit(f"No OPENAI_API_KEY and missing {ENV_LOCAL}")
    with open(ENV_LOCAL, encoding="utf-8") as handle:
        for line in handle:
            line = line.strip()
            if line.startswith("OPENAI_API_KEY="):
                return line.split("=", 1)[1].strip().strip('"').strip("'")
    raise SystemExit("OPENAI_API_KEY not found")


def load_en() -> dict:
    with open(os.path.join(L10N, "app_en.arb"), encoding="utf-8") as handle:
        return json.load(handle)


def string_keys(arb: dict) -> list[str]:
    return [k for k in arb if not k.startswith("@") and k != "@@locale"]


def chunked(items: list[str], size: int):
    for i in range(0, len(items), size):
        yield items[i : i + size]


def openai_translate(api_key: str, language: str, batch: dict[str, str]) -> dict[str, str]:
    system = (
        "You translate mobile fitness-app UI strings. "
        f"Target language: {language}. "
        "Return ONLY a JSON object mapping the same keys to translated strings. "
        "Keep ICU / Flutter placeholders like {count}, {name}, {calories} exactly "
        "unchanged, including braces and names. "
        "Keep brand names Celia, Google, Apple, HIIT, Pro, CARB, FAT, kcal untranslated "
        "when they are product or unit labels. "
        "Do not add keys. Do not omit keys. Natural, concise UI tone."
    )
    body = {
        "model": MODEL,
        "response_format": {"type": "json_object"},
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": json.dumps(batch, ensure_ascii=False)},
        ],
    }
    # gpt-5 family uses max_completion_tokens
    if str(MODEL).startswith("gpt-5"):
        body["max_completion_tokens"] = 8000
    else:
        body["max_tokens"] = 8000

    req = urllib.request.Request(
        "https://api.openai.com/v1/chat/completions",
        data=json.dumps(body).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=180) as resp:
            payload = json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"OpenAI HTTP {exc.code}: {detail[:500]}") from exc

    content = payload["choices"][0]["message"]["content"]
    translated = json.loads(content)
    if not isinstance(translated, dict):
        raise RuntimeError("Model did not return a JSON object")
    return {str(k): str(v) for k, v in translated.items()}


def placeholders_ok(src: str, dst: str) -> bool:
    return PLACEHOLDER.findall(src) == PLACEHOLDER.findall(dst)


def build_locale(en: dict, code: str, translated: dict[str, str]) -> dict:
    out: dict = {"@@locale": code}
    for key in string_keys(en):
        value = translated.get(key)
        if value is None or not placeholders_ok(en[key], value):
            value = en[key]
        out[key] = value
        meta = f"@{key}"
        if meta in en:
            out[meta] = en[meta]
    return out


def write_arb(code: str, data: dict) -> None:
    path = os.path.join(L10N, f"app_{code}.arb")
    with open(path, "w", encoding="utf-8", newline="\n") as handle:
        json.dump(data, handle, ensure_ascii=False, indent=2)
        handle.write("\n")
    print(f"wrote {path}")


def translate_locale(api_key: str, en: dict, code: str, language: str) -> dict[str, str]:
    keys = string_keys(en)
    merged: dict[str, str] = {}
    for batch_keys in chunked(keys, BATCH):
        batch = {k: en[k] for k in batch_keys}
        for attempt in range(3):
            try:
                part = openai_translate(api_key, language, batch)
                # Retry if too many keys missing
                missing = [k for k in batch_keys if k not in part]
                if missing and attempt < 2:
                    time.sleep(1.5)
                    continue
                merged.update(part)
                break
            except Exception as exc:  # noqa: BLE001
                print(f"  {code} batch failed ({attempt + 1}/3): {exc}")
                if attempt == 2:
                    raise
                time.sleep(2)
        print(f"  {code}: {len(merged)}/{len(keys)}")
        time.sleep(0.4)
    return merged


def main() -> int:
    api_key = load_env_key()
    en = load_en()
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    force = "--force" in sys.argv
    only = set(args) if args else None

    for code, language in TARGETS.items():
        if only and code not in only:
            continue
        out_path = os.path.join(L10N, f"app_{code}.arb")
        if os.path.isfile(out_path) and not force:
            # Allow resume: skip complete files unless forced
            existing = json.load(open(out_path, encoding="utf-8"))
            if len(string_keys(existing)) >= len(string_keys(en)):
                print(f"skip {code} (already present)")
                continue
        print(f"translating {code} ({language})…")
        translated = translate_locale(api_key, en, code, language)
        write_arb(code, build_locale(en, code, translated))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
