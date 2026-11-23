import { NextResponse } from 'next/server';

export const runtime = 'nodejs';
export const maxDuration = 20;

/**
 * Runtime probe for GEMINI_API_KEY. Returns shape + live Google check only —
 * never the key itself. Safe to leave; no secrets in the response.
 */
export async function GET() {
  const key = (
    process.env.GEMINI_API_KEY?.trim() ||
    process.env.GOOGLE_GENERATIVE_AI_API_KEY?.trim() ||
    ''
  );

  const keyLen = key.length;
  const looksLikeGoogleKey = keyLen >= 30 && key.startsWith('AIza');

  if (!key) {
    return NextResponse.json(
      {
        ok: false,
        keyConfigured: false,
        keyLen: 0,
        looksLikeGoogleKey: false,
        error: 'GEMINI_API_KEY missing in runtime',
      },
      { status: 503 }
    );
  }

  if (keyLen < 20 || key === '[SENSITIVE]' || key.startsWith('[SEN')) {
    return NextResponse.json(
      {
        ok: false,
        keyConfigured: true,
        keyLen,
        looksLikeGoogleKey: false,
        error:
          'GEMINI_API_KEY looks like a placeholder, not a real Google key',
      },
      { status: 503 }
    );
  }

  try {
    const res = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models?key=${encodeURIComponent(key)}`,
      { method: 'GET', cache: 'no-store' }
    );
    const json = (await res.json().catch(() => ({}))) as {
      error?: { message?: string };
    };

    if (!res.ok || json.error) {
      return NextResponse.json(
        {
          ok: false,
          keyConfigured: true,
          keyLen,
          looksLikeGoogleKey,
          geminiHttp: res.status,
          error: json.error?.message || `Gemini HTTP ${res.status}`,
        },
        { status: 502 }
      );
    }

    return NextResponse.json({
      ok: true,
      keyConfigured: true,
      keyLen,
      looksLikeGoogleKey,
      geminiHttp: res.status,
      modelsOk: true,
    });
  } catch (err) {
    return NextResponse.json(
      {
        ok: false,
        keyConfigured: true,
        keyLen,
        looksLikeGoogleKey,
        error: err instanceof Error ? err.message : 'probe_failed',
      },
      { status: 502 }
    );
  }
}
