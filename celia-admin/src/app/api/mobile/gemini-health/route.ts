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

    // Also prove Sulafat TTS works (short phrase, discard audio).
    const ttsModel =
      process.env.GEMINI_TTS_MODEL?.trim() || 'gemini-3.8-flash-tts';
    const ttsVoice = process.env.GEMINI_TTS_VOICE?.trim() || 'Sulafat';
    const ttsRes = await fetch(
      'https://generativelanguage.googleapis.com/v1beta/interactions',
      {
        method: 'POST',
        headers: {
          'x-goog-api-key': key,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: ttsModel,
          store: false,
          input: [
            {
              type: 'user_input',
              content: [{ type: 'text', text: 'Hi.' }],
            },
          ],
          response_format: { type: 'audio' },
          generation_config: {
            speech_config: [{ voice: ttsVoice }],
          },
        }),
      }
    );
    const ttsJson = (await ttsRes.json().catch(() => ({}))) as {
      error?: { message?: string };
      steps?: Array<{
        type?: string;
        content?: Array<{ type?: string; data?: string }>;
      }>;
    };

    let hasAudio = false;
    for (const step of ttsJson.steps ?? []) {
      if (step.type !== 'model_output') continue;
      for (const part of step.content ?? []) {
        if (part.type === 'audio' && typeof part.data === 'string' && part.data) {
          hasAudio = true;
        }
      }
    }

    if (!ttsRes.ok || ttsJson.error || !hasAudio) {
      return NextResponse.json(
        {
          ok: false,
          keyConfigured: true,
          keyLen,
          looksLikeGoogleKey,
          geminiHttp: res.status,
          modelsOk: true,
          ttsHttp: ttsRes.status,
          ttsOk: false,
          ttsModel,
          ttsVoice,
          error:
            ttsJson.error?.message ||
            (!hasAudio
              ? 'TTS returned no audio'
              : `TTS HTTP ${ttsRes.status}`),
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
      ttsHttp: ttsRes.status,
      ttsOk: true,
      ttsModel,
      ttsVoice,
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
