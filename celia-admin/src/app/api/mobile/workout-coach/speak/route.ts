import { NextRequest, NextResponse } from 'next/server';
import { createRemoteJWKSet, jwtVerify } from 'jose';
import { createHash } from 'crypto';

export const runtime = 'nodejs';
export const maxDuration = 30;

// OpenAI TTS for future avatar / persona speech — not used by the guided
// workout counter (that uses on-device TTS in the mobile app).
const FIREBASE_PROJECT_ID = process.env.FIREBASE_PROJECT_ID;
const OPENAI_API_KEY = process.env.OPENAI_API_KEY;
const OPENAI_TTS_MODEL = process.env.OPENAI_TTS_MODEL || 'tts-1';
const OPENAI_TTS_VOICE = process.env.OPENAI_TTS_VOICE || 'nova';

const FIREBASE_JWKS = createRemoteJWKSet(
  new URL(
    'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com',
  ),
);

// Short coaching cues are requested over and over in a single workout. Keeping
// the recent responses in memory means the second set of a squat does not pay
// for the same "Rest" clip twice, which is both cheaper and snappier.
const speechCache = new Map<string, { bytes: Buffer; expiresAt: number }>();
const CACHE_TTL_MS = 1000 * 60 * 60; // 1 hour
const CACHE_MAX_ENTRIES = 200;
const MAX_INPUT_CHARS = 280;

type User = { uid: string };

type SpeakBody = {
  text?: unknown;
  locale?: unknown;
};

async function verifyFirebaseUser(req: NextRequest): Promise<User | null> {
  if (!FIREBASE_PROJECT_ID) return null;

  const auth = req.headers.get('authorization') || '';
  const [scheme, token] = auth.split(' ');
  if (scheme !== 'Bearer' || !token) return null;

  try {
    const { payload } = await jwtVerify(token, FIREBASE_JWKS, {
      issuer: `https://securetoken.google.com/${FIREBASE_PROJECT_ID}`,
      audience: FIREBASE_PROJECT_ID,
    });
    const uid = typeof payload.sub === 'string' ? payload.sub : '';
    if (!uid) return null;
    return { uid };
  } catch {
    return null;
  }
}

function cacheKey(text: string, locale: string, voice: string, model: string) {
  return createHash('sha256')
    .update([model, voice, locale, text].join('\0'))
    .digest('hex');
}

function readCache(key: string): Buffer | null {
  const hit = speechCache.get(key);
  if (!hit) return null;
  if (Date.now() > hit.expiresAt) {
    speechCache.delete(key);
    return null;
  }
  return hit.bytes;
}

function writeCache(key: string, bytes: Buffer) {
  if (speechCache.size >= CACHE_MAX_ENTRIES) {
    const oldest = speechCache.keys().next().value;
    if (oldest) speechCache.delete(oldest);
  }
  speechCache.set(key, { bytes, expiresAt: Date.now() + CACHE_TTL_MS });
}

async function synthesize(text: string): Promise<Buffer> {
  if (!OPENAI_API_KEY) {
    throw new Error('OPENAI_API_KEY is not configured');
  }

  const res = await fetch('https://api.openai.com/v1/audio/speech', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${OPENAI_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: OPENAI_TTS_MODEL,
      voice: OPENAI_TTS_VOICE,
      input: text,
      response_format: 'mp3',
      // Workout counts need to land on the beat; slightly brisk is clearer.
      speed: 1.05,
    }),
  });

  if (!res.ok) {
    const body = await res.text();
    throw new Error(`OpenAI TTS failed (${res.status}): ${body.slice(0, 400)}`);
  }

  return Buffer.from(await res.arrayBuffer());
}

export async function POST(req: NextRequest) {
  const user = await verifyFirebaseUser(req);
  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  let body: SpeakBody;
  try {
    body = (await req.json()) as SpeakBody;
  } catch {
    return NextResponse.json({ error: 'Invalid JSON body' }, { status: 400 });
  }

  const text = typeof body.text === 'string' ? body.text.trim() : '';
  if (!text) {
    return NextResponse.json({ error: 'text is required' }, { status: 400 });
  }
  if (text.length > MAX_INPUT_CHARS) {
    return NextResponse.json(
      { error: `text must be at most ${MAX_INPUT_CHARS} characters` },
      { status: 400 },
    );
  }

  const locale =
    typeof body.locale === 'string' && body.locale.trim()
      ? body.locale.trim().toLowerCase().slice(0, 8)
      : 'en';

  const key = cacheKey(text, locale, OPENAI_TTS_VOICE, OPENAI_TTS_MODEL);
  const cached = readCache(key);
  if (cached) {
    return new NextResponse(new Uint8Array(cached), {
      status: 200,
      headers: {
        'Content-Type': 'audio/mpeg',
        'Cache-Control': 'private, max-age=3600',
        'X-Celia-TTS-Cache': 'hit',
      },
    });
  }

  try {
    const bytes = await synthesize(text);
    writeCache(key, bytes);
    return new NextResponse(new Uint8Array(bytes), {
      status: 200,
      headers: {
        'Content-Type': 'audio/mpeg',
        'Cache-Control': 'private, max-age=3600',
        'X-Celia-TTS-Cache': 'miss',
      },
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.error('[workout-coach/speak]', message);
    const missingKey = message.includes('OPENAI_API_KEY');
    return NextResponse.json(
      {
        error: missingKey
          ? 'OpenAI TTS is not configured'
          : 'Could not generate coaching audio',
      },
      { status: missingKey ? 503 : 502 },
    );
  }
}
