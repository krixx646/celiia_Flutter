import { NextRequest, NextResponse } from 'next/server';
import { verifyFirebaseUser } from '@/lib/firebaseAuth';

export const runtime = 'nodejs';
export const maxDuration = 30;

const GEMINI_INTERACTIONS_URL =
  'https://generativelanguage.googleapis.com/v1beta/interactions';

const DEFAULT_STT_MODEL = 'gemini-3.5-transcribe';
const MAX_AUDIO_BYTES = 10 * 1024 * 1024; // 10 MB

const CELIA_CUSTOM_VOCABULARY = [
  'Celia',
  'The Fit',
  'kcal',
  'macros',
  'HIIT',
  'RPE',
  'glutes',
  'quads',
  'hamstrings',
  'kettlebell',
  'dumbbell',
];

const SUPPORTED_MIME_TYPES = new Set([
  'audio/wav',
  'audio/mp3',
  'audio/aiff',
  'audio/aac',
  'audio/ogg',
  'audio/flac',
  'audio/mpeg',
  'audio/m4a',
  'audio/l16',
  'audio/opus',
  'audio/alaw',
  'audio/mulaw',
  'audio/webm',
]);

type SttJsonBody = {
  audioBase64?: unknown;
  mimeType?: unknown;
  fileName?: unknown;
};

type InteractionContentPart = {
  type?: string;
  text?: string;
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

function normalizeAudioMimeType(rawMime: string, filename = ''): string {
  const cleaned = rawMime.split(';')[0].trim().toLowerCase();
  if (cleaned === 'audio/mp4' || cleaned === 'audio/x-m4a' || cleaned === 'video/mp4') {
    return 'audio/m4a';
  }
  if (cleaned === 'audio/x-wav' || cleaned === 'audio/wave') {
    return 'audio/wav';
  }
  if (cleaned === 'audio/mp3' || cleaned === 'audio/mpeg3') {
    return 'audio/mp3';
  }
  if (SUPPORTED_MIME_TYPES.has(cleaned)) {
    return cleaned;
  }

  const lowerName = filename.toLowerCase();
  if (lowerName.endsWith('.m4a') || lowerName.endsWith('.mp4')) return 'audio/m4a';
  if (lowerName.endsWith('.aac')) return 'audio/aac';
  if (lowerName.endsWith('.wav')) return 'audio/wav';
  if (lowerName.endsWith('.mp3')) return 'audio/mp3';
  if (lowerName.endsWith('.ogg')) return 'audio/ogg';
  if (lowerName.endsWith('.opus')) return 'audio/opus';
  if (lowerName.endsWith('.webm')) return 'audio/webm';
  if (lowerName.endsWith('.flac')) return 'audio/flac';

  return 'audio/m4a';
}

async function extractAudioPayload(
  req: NextRequest
): Promise<{ audioBase64: string; mimeType: string } | { error: string; status: number }> {
  const contentType = (req.headers.get('content-type') || '').toLowerCase();

  if (contentType.includes('multipart/form-data')) {
    let form: FormData;
    try {
      form = await req.formData();
    } catch {
      return { error: 'Invalid multipart form data', status: 400 };
    }

    const file = form.get('audio') ?? form.get('file');
    if (!(file instanceof Blob)) {
      return { error: 'audio file is required', status: 400 };
    }
    if (file.size === 0) {
      return { error: 'audio file is empty', status: 400 };
    }
    if (file.size > MAX_AUDIO_BYTES) {
      return { error: 'audio file exceeds 10 MB limit', status: 413 };
    }

    const name = 'name' in file && typeof file.name === 'string' ? file.name : '';
    const mimeType = normalizeAudioMimeType(file.type || '', name);
    const bytes = Buffer.from(await file.arrayBuffer());
    return {
      audioBase64: bytes.toString('base64'),
      mimeType,
    };
  }

  let body: SttJsonBody;
  try {
    body = (await req.json()) as SttJsonBody;
  } catch {
    return { error: 'Invalid request body', status: 400 };
  }

  const audioBase64 =
    typeof body.audioBase64 === 'string' ? body.audioBase64.trim() : '';
  if (!audioBase64) {
    return { error: 'audioBase64 is required', status: 400 };
  }

  const estimatedBytes = Math.floor((audioBase64.length * 3) / 4);
  if (estimatedBytes > MAX_AUDIO_BYTES) {
    return { error: 'audio exceeds 10 MB limit', status: 413 };
  }

  const rawMime = typeof body.mimeType === 'string' ? body.mimeType : '';
  const fileName = typeof body.fileName === 'string' ? body.fileName : '';
  return {
    audioBase64,
    mimeType: normalizeAudioMimeType(rawMime, fileName),
  };
}

async function transcribeWithGemini(params: {
  apiKey: string;
  model: string;
  audioBase64: string;
  mimeType: string;
}): Promise<string> {
  const { apiKey, model, audioBase64, mimeType } = params;

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
          content: [
            {
              type: 'audio',
              data: audioBase64,
              mime_type: mimeType,
            },
          ],
        },
      ],
      generation_config: {
        transcription_config: {
          // Empty array enables automatic detection + mid-sentence code-switching
          // across all 85+ supported languages (e.g. French + English fitness terms).
          language_codes: [],
          custom_vocabulary: CELIA_CUSTOM_VOCABULARY,
          mode: 'smart',
        },
      },
    }),
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(
      `Gemini STT failed (${res.status}): ${errText.slice(0, 500)}`
    );
  }

  const payload = (await res.json()) as InteractionResponse;
  const parts: string[] = [];

  for (const step of payload.steps ?? []) {
    if (step.type !== 'model_output') continue;
    for (const content of step.content ?? []) {
      if (content.type === 'text' && typeof content.text === 'string') {
        const chunk = content.text.trim();
        if (chunk) parts.push(chunk);
      }
    }
  }

  return parts.join(' ').trim();
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

  const extracted = await extractAudioPayload(req);
  if ('error' in extracted) {
    return NextResponse.json(
      { error: extracted.error },
      { status: extracted.status }
    );
  }

  const model = process.env.GEMINI_STT_MODEL?.trim() || DEFAULT_STT_MODEL;

  try {
    const text = await transcribeWithGemini({
      apiKey,
      model,
      audioBase64: extracted.audioBase64,
      mimeType: extracted.mimeType,
    });

    return NextResponse.json({ text });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.error('[mobile/stt]', message);
    return NextResponse.json(
      { error: 'Could not transcribe audio' },
      { status: 502 }
    );
  }
}
