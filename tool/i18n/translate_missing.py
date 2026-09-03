"""Fill in only the keys a locale is missing, leaving existing ones untouched.

generate_major_locales.py regenerates a whole locale from scratch, which
re-translates hundreds of strings that were already fine and churns the diff.
When a feature adds keys, this is the tool to reach for instead.

Usage:
  python tool/i18n/translate_missing.py            # every locale
  python tool/i18n/translate_missing.py es fr      # only these
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

LANGUAGES = {
    "es": "Spanish",
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
BATCH = 40


def load_env_key() -> str:
    key = os.environ.get("OPENAI_API_KEY", "").strip()
    if key:
        return key
    if not os.path.isfile(ENV_LOCAL):
        raise SystemExit(f"No OPENAI_API_KEY and missing {ENV_LOCAL}")
    with open(ENV_LOCAL, encoding="utf-8") as handle:
        for line in handle:
            if line.strip().startswith("OPENAI_API_KEY="):
                return line.split("=", 1)[1].strip().strip('"').strip("'")
    raise SystemExit("OPENAI_API_KEY not found")


def read_arb(code: str) -> dict:
    with open(os.path.join(L10N, f"app_{code}.arb"), encoding="utf-8") as handle:
        return json.load(handle)


def translate(api_key: str, language: str, batch: dict[str, str]) -> dict[str, str]:
    system = (
        "You translate mobile fitness-app UI strings. "
        f"Target language: {language}. "
        "Return ONLY a JSON object mapping the same keys to translated strings. "
        "Keep Flutter placeholders like {count} and {value} exactly unchanged, "
        "including braces and names. "
        "Preserve ICU plural syntax exactly, including the plural keyword, the "
        "=0/=1/other selectors and their braces; translate only the words inside. "
        "Keep brand names Celia, Bodygram, DXA, Google and Apple untranslated. "
        "This is health-related copy: keep hedging words such as 'estimate' and "
        "'about' intact, and never upgrade an estimate into a measurement. "
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
    if str(MODEL).startswith("gpt-5"):
        body["max_completion_tokens"] = 8000
    else:
        body["max_tokens"] = 8000

    req = urllib.request.Request(
        "https://api.openai.com/v1/chat/completions",
        data=json.dumps(body).encode("utf-8"),
        headers={"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=180) as resp:
            payload = json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"OpenAI HTTP {exc.code}: {detail[:400]}") from exc

    out = json.loads(payload["choices"][0]["message"]["content"])
    if not isinstance(out, dict):
        raise RuntimeError("Model did not return a JSON object")
    return {str(k): str(v) for k, v in out.items()}


def acceptable(source: str, candidate: str) -> bool:
    """Reject a translation that mangled placeholders or ICU plural syntax.

    A broken placeholder is a crash at runtime, so falling back to English is
    strictly better than shipping it.
    """
    if PLACEHOLDER.findall(source) != PLACEHOLDER.findall(candidate):
        return False
    if ", plural," in source:
        if ", plural," not in candidate:
            return False
        if candidate.count("{") != source.count("{"):
            return False
    return True


def append_keys(code: str, additions: dict[str, str], english: dict) -> None:
    """Line-based append so existing translations keep their formatting."""
    path = os.path.join(L10N, f"app_{code}.arb")
    with open(path, encoding="utf-8") as handle:
        lines = handle.read().rstrip("\n").split("\n")

    assert lines[-1].strip() == "}", f"unexpected end of app_{code}.arb"
    body = lines[:-1]
    if not body[-1].rstrip().endswith(","):
        body[-1] = body[-1].rstrip() + ","

    keys = list(additions)
    block: list[str] = []
    for index, key in enumerate(keys):
        meta_key = f"@{key}"
        meta = english.get(meta_key)
        last = index == len(keys) - 1
        value = json.dumps(additions[key], ensure_ascii=False)
        block.append(f"  {json.dumps(key)}: {value}" + ("" if last and not meta else ","))
        if meta:
            rendered = json.dumps(meta, ensure_ascii=False, indent=2).split("\n")
            rendered = [rendered[0]] + ["  " + line for line in rendered[1:]]
            block.append(
                f"  {json.dumps(meta_key)}: " + "\n".join(rendered) + ("" if last else ",")
            )

    with open(path, "w", encoding="utf-8", newline="\n") as handle:
        handle.write("\n".join(body + block + ["}"]) + "\n")

    with open(path, encoding="utf-8") as handle:
        json.load(handle)


def main() -> int:
    api_key = load_env_key()
    english = read_arb("en")
    en_keys = [k for k in english if not k.startswith("@")]

    only = {a for a in sys.argv[1:] if not a.startswith("--")}
    fallbacks_total = 0

    for code, language in LANGUAGES.items():
        if only and code not in only:
            continue
        if not os.path.isfile(os.path.join(L10N, f"app_{code}.arb")):
            print(f"skip {code}: no arb file")
            continue

        existing = read_arb(code)
        missing = [k for k in en_keys if k not in existing]
        if not missing:
            print(f"{code}: up to date")
            continue

        print(f"{code} ({language}): {len(missing)} missing")
        merged: dict[str, str] = {}
        for start in range(0, len(missing), BATCH):
            chunk = missing[start : start + BATCH]
            payload = {k: english[k] for k in chunk}
            for attempt in range(3):
                try:
                    merged.update(translate(api_key, language, payload))
                    break
                except Exception as exc:  # noqa: BLE001
                    print(f"  batch failed ({attempt + 1}/3): {exc}")
                    if attempt == 2:
                        raise
                    time.sleep(2)
            time.sleep(0.4)

        additions: dict[str, str] = {}
        fallbacks: list[str] = []
        for key in missing:
            candidate = merged.get(key)
            if candidate is None or not acceptable(english[key], candidate):
                additions[key] = english[key]
                fallbacks.append(key)
            else:
                additions[key] = candidate

        append_keys(code, additions, english)
        fallbacks_total += len(fallbacks)
        note = f", {len(fallbacks)} fell back to English" if fallbacks else ""
        print(f"  wrote {len(additions)} keys{note}")
        if fallbacks:
            print(f"    {', '.join(fallbacks)}")

    if fallbacks_total:
        print(f"\n{fallbacks_total} string(s) fell back to English; review the list above.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
