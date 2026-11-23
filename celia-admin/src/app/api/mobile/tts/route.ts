import { createHash } from 'crypto';
import { NextRequest, NextResponse } from 'next/server';
import { verifyFirebaseUser } from '@/lib/firebaseAuth';

export const runtime = 'nodejs';
export const maxDuration = 30;

const GEMINI_INTERACTIONS_URL =
  'https://generativelanguage.googleapis.com/v1beta/interactions';

const DEFAULT_TTS_MODEL = 'gemini-3.8-flash-tts';
const DEFAULT_TTS_VOICE = 'Sulafat';
const DEFAULT_TTS_STYLE = 'warm, encouraging, and natural';

const CACHE_TTL_MS = 1000 * 60 * 60; // 1 hour
const CACHE_MAX_ENTRIES = 120;
const MAX_INPUT_CHARS = 4000;

type CachedAudio = {
  bytes: Buffer;
  mimeType: string;
  expiresAt: number;
};

const speechCache = new Map<string, CachedAudio>();

type TtsBody = {
  text?: unknown;
  locale?: unknown;
};

type InteractionContentPart = {
  type?: string;
  data?: string;
  mime_type?: string;
};

type InteractionStep = {
  type?: string;
  content?: InteractionContentPart[];
};

type InteractionResponse = {
  steps?: InteractionStep[];
};

function getGeminiApiKey(): string {
  return (
    process.env.GEMINI_API_KEY?.trim() ||
    process.env.GOOGLE_GENERATIVE_AI_API_KEY?.trim() ||
    ''
  );
}

function makeCacheKey(
  model: string,
  voice: string,
  style: string,
  locale: string,
  text: string
): string {
  return createHash('sha256')
    .update([model, voice, style, locale, text].join('\0'))
    .digest('hex');
}

function readCache(key: string): CachedAudio | null {
  const hit = speechCache.get(key);
  if (!hit) return null;
  if (Date.now() > hit.expiresAt) {
    speechCache.delete(key);
    return null;
  }
  return hit;
}

function writeCache(key: string, bytes: Buffer, mimeType: string) {
  if (speechCache.size >= CACHE_MAX_ENTRIES) {
    const oldest = speechCache.keys().next().value;
    if (oldest) speechCache.delete(oldest);
  }
  speechCache.set(key, {
    bytes,
    mimeType,
    expiresAt: Date.now() + CACHE_TTL_MS,
  });
}

function clampSpeechText(raw: string): string {
  const trimmed = raw.trim();
  if (trimmed.length <= MAX_INPUT_CHARS) return trimmed;
  const slice = trimmed.slice(0, MAX_INPUT_CHARS);
  const lastSentenceEnd = Math.max(
    slice.lastIndexOf('. '),
    slice.lastIndexOf('! '),
    slice.lastIndexOf('? ')
  );
  return (lastSentenceEnd > MAX_INPUT_CHARS * 0.5
    ? slice.slice(0, lastSentenceEnd + 1)
    : slice
  ).trim();
}

async function synthesizeWithGemini(params: {
  apiKey: string;
  model: string;
  voice: string;
  style: string;
  text: string;
}): Promise<{ bytes: Buffer; mimeType: string }> {
  const { apiKey, model, voice, style, text } = params;

  const contentItem: Record<string, unknown> = {
    type: 'text',
    text,
  };
  if (style) {
    contentItem.annotations = [
      {
        type: 'speech_metadata',
        style,
      },
    ];
  }

  const res = await fetch(GEMINI_INTERACTIONS_URL, {
    method: 'POST',
    headers: {
      'x-goog-api-key': apiKey,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model,
      store: false,
      input: [
        {
          type: 'user_input',
          content: [contentItem],
        },
      ],
      response_format: { type: 'audio' },
      generation_config: {
        speech_config: [{ voice }],
      },
    }),
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(
      `Gemini TTS failed (${res.status}): ${errText.slice(0, 500)}`
    );
  }

  const payload = (await res.json()) as InteractionResponse;
  let audioBase64 = '';
  let mimeType = 'audio/wav';

  for (const step of payload.steps ?? []) {
    if (step.type !== 'model_output') continue;
    for (const item of step.content ?? []) {
      if (item.type === 'audio' && typeof item.data === 'string' && item.data) {
        audioBase64 = item.data;
        if (typeof item.mime_type === 'string' && item.mime_type) {
          mimeType = item.mime_type;
        }
      }
    }
  }

  if (!audioBase64) {
    throw new Error('Gemini TTS returned no audio content');
  }

  return {
    bytes: Buffer.from(audioBase64, 'base64'),
    mimeType,
  };
}

export async function POST(req: NextRequest) {
  const user = await verifyFirebaseUser(req);
  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const apiKey = getGeminiApiKey();
  if (!apiKey) {
    return NextResponse.json(
      { error: 'GEMINI_API_KEY is not configured' },
      { status: 503 }
    );
  }

  let body: TtsBody;
  try {
    body = (await req.json()) as TtsBody;
  } catch {
    return NextResponse.json({ error: 'Invalid JSON body' }, { status: 400 });
  }

  const rawText = typeof body.text === 'string' ? body.text : '';
  const text = clampSpeechText(rawText);
  if (!text) {
    return NextResponse.json({ error: 'text is required' }, { status: 400 });
  }

  const locale =
    typeof body.locale === 'string' && body.locale.trim()
      ? body.locale.trim().toLowerCase().slice(0, 12)
      : 'en';

  const model = process.env.GEMINI_TTS_MODEL?.trim() || DEFAULT_TTS_MODEL;
  const voice = process.env.GEMINI_TTS_VOICE?.trim() || DEFAULT_TTS_VOICE;
  const style =
    process.env.GEMINI_TTS_STYLE !== undefined
      ? process.env.GEMINI_TTS_STYLE.trim()
      : DEFAULT_TTS_STYLE;

  const key = makeCacheKey(model, voice, style, locale, text);
  const cached = readCache(key);
  if (cached) {
    return new NextResponse(new Uint8Array(cached.bytes), {
      status: 200,
      headers: {
        'Content-Type': cached.mimeType,
        'Cache-Control': 'private, max-age=3600',
        'X-Celia-TTS-Cache': 'hit',
        'X-Celia-TTS-Voice': voice,
      },
    });
  }

  try {
    const { bytes, mimeType } = await synthesizeWithGemini({
      apiKey,
      model,
      voice,
      style,
      text,
    });
    writeCache(key, bytes, mimeType);

    return new NextResponse(new Uint8Array(bytes), {
      status: 200,
      headers: {
        'Content-Type': mimeType,
        'Cache-Control': 'private, max-age=3600',
        'X-Celia-TTS-Cache': 'miss',
        'X-Celia-TTS-Voice': voice,
      },
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.error('[mobile/tts]', message);
    return NextResponse.json(
      { error: 'Could not synthesize speech' },
      { status: 502 }
    );
  }
}
