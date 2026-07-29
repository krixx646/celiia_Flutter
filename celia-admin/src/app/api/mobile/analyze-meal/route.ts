import { NextRequest, NextResponse } from 'next/server';
import { createRemoteJWKSet, jwtVerify } from 'jose';

export const runtime = 'nodejs';
export const maxDuration = 60;

const FIREBASE_PROJECT_ID = process.env.FIREBASE_PROJECT_ID;
const DEEPSEEK_API_KEY = process.env.DEEPSEEK_API_KEY;
const DEEPSEEK_VISION_ENDPOINT = process.env.DEEPSEEK_VISION_ENDPOINT;
const DEEPSEEK_VISION_MODEL = process.env.DEEPSEEK_VISION_MODEL;
const OPENAI_API_KEY = process.env.OPENAI_API_KEY;
const OPENAI_VISION_MODEL = process.env.OPENAI_VISION_MODEL || 'gpt-5.4-mini';

const FIREBASE_JWKS = createRemoteJWKSet(
  new URL('https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com')
);

type User = { uid: string };

type AnalyzeMealBody = {
  imageBase64?: string;
  imageDataUrl?: string;
  mimeType?: string;
  timezoneOffsetMinutes?: number;
};

type FoodItem = {
  name: string;
  servingGrams: number;
  calories: number;
  proteinGrams: number;
  carbsGrams: number;
  fatGrams: number;
  confidence: number;
  notes?: string;
  box?: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
};

type MealAnalysis = {
  title: string;
  provider: 'deepseek' | 'openai';
  summary: string;
  confidence: number;
  totalCalories: number;
  totalProteinGrams: number;
  totalCarbsGrams: number;
  totalFatGrams: number;
  items: FoodItem[];
  warnings: string[];
};

function hasDeepSeekVisionConfig() {
  return Boolean(DEEPSEEK_API_KEY && DEEPSEEK_VISION_ENDPOINT && DEEPSEEK_VISION_MODEL);
}

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

function safeNumber(value: unknown, fallback: number, min = 0, max = Number.MAX_SAFE_INTEGER) {
  const n = typeof value === 'number' ? value : Number(value);
  if (!Number.isFinite(n)) return fallback;
  return Math.max(min, Math.min(max, n));
}

function normalizeDataUrl(body: Partial<AnalyzeMealBody>) {
  const mimeType = String(body.mimeType || 'image/jpeg');
  const rawDataUrl = String(body.imageDataUrl || '').trim();
  if (rawDataUrl.startsWith('data:image/')) return rawDataUrl;

  const base64 = String(body.imageBase64 || '').replace(/^data:image\/\w+;base64,/, '').trim();
  if (!base64) return '';
  return `data:${mimeType};base64,${base64}`;
}

function extractJson(text: string) {
  const trimmed = text.trim();
  if (trimmed.startsWith('{') && trimmed.endsWith('}')) return trimmed;
  const match = trimmed.match(/\{[\s\S]*\}/);
  return match?.[0] || '';
}

function buildPrompt() {
  return `You are Celia's nutrition vision analyst.

Analyze every visible food item, fruit, drink, plate, or meal component in the image and estimate calories/macros. Return ONLY valid JSON:
{
  "title": "Short meal name",
  "summary": "One sentence summary",
  "confidence": 0.0,
  "items": [
    {
      "name": "Food name",
      "servingGrams": 100,
      "calories": 150,
      "proteinGrams": 10,
      "carbsGrams": 20,
      "fatGrams": 5,
      "confidence": 0.0,
      "notes": "portion/preparation assumption",
      "box": { "x": 0.1, "y": 0.2, "width": 0.3, "height": 0.2 }
    }
  ],
  "warnings": ["Estimated from image; confirm portions for accuracy."]
}

Rules:
- Estimate visible food only. If there are multiple foods or plates, return multiple items.
- Use normalized box coordinates from 0 to 1 for the upright image when you can locate an item; omit box if uncertain.
- Do not invent food outside the frame. Split clearly separate foods into separate items.
- If the image is unclear or contains no food, return an empty items array, total confidence under 0.35, and a helpful warning.
- Calories and macros must be numeric estimates, not strings.
- Be conservative and honest about uncertainty.`;
}

function normalizeAnalysis(raw: unknown, provider: MealAnalysis['provider']): MealAnalysis {
  const obj = raw && typeof raw === 'object' ? (raw as Record<string, unknown>) : {};
  const rawItems = Array.isArray(obj.items) ? obj.items : [];

  const items = rawItems
    .map((entry): FoodItem | null => {
      if (!entry || typeof entry !== 'object') return null;
      const item = entry as Record<string, unknown>;
      const name = String(item.name || '').trim();
      if (!name) return null;

      const rawBox = item.box && typeof item.box === 'object' ? (item.box as Record<string, unknown>) : null;
      const box = rawBox
        ? {
            x: safeNumber(rawBox.x, 0, 0, 1),
            y: safeNumber(rawBox.y, 0, 0, 1),
            width: safeNumber(rawBox.width, 0, 0, 1),
            height: safeNumber(rawBox.height, 0, 0, 1),
          }
        : undefined;

      return {
        name,
        servingGrams: safeNumber(item.servingGrams, 0, 0),
        calories: safeNumber(item.calories, 0, 0),
        proteinGrams: safeNumber(item.proteinGrams, 0, 0),
        carbsGrams: safeNumber(item.carbsGrams, 0, 0),
        fatGrams: safeNumber(item.fatGrams, 0, 0),
        confidence: safeNumber(item.confidence, 0.5, 0, 1),
        notes: item.notes ? String(item.notes) : undefined,
        box: box && box.width > 0 && box.height > 0 ? box : undefined,
      };
    })
    .filter((item): item is FoodItem => item !== null);

  const totals = items.reduce(
    (acc, item) => ({
      calories: acc.calories + item.calories,
      protein: acc.protein + item.proteinGrams,
      carbs: acc.carbs + item.carbsGrams,
      fat: acc.fat + item.fatGrams,
    }),
    { calories: 0, protein: 0, carbs: 0, fat: 0 }
  );

  const warnings = Array.isArray(obj.warnings)
    ? obj.warnings.map(String).filter(Boolean)
    : ['Estimated from image; confirm portions for accuracy.'];

  return {
    title: String(obj.title || (items.length ? 'Estimated Meal' : 'No meal detected')),
    provider,
    summary: String(obj.summary || 'Estimated from the camera image.'),
    confidence: safeNumber(obj.confidence, items.length ? 0.6 : 0.2, 0, 1),
    totalCalories: Math.round(totals.calories),
    totalProteinGrams: Math.round(totals.protein * 10) / 10,
    totalCarbsGrams: Math.round(totals.carbs * 10) / 10,
    totalFatGrams: Math.round(totals.fat * 10) / 10,
    items,
    warnings,
  };
}

async function analyzeWithDeepSeek(dataUrl: string): Promise<MealAnalysis> {
  if (!DEEPSEEK_API_KEY || !DEEPSEEK_VISION_ENDPOINT || !DEEPSEEK_VISION_MODEL) {
    throw new Error('DeepSeek vision is not configured');
  }

  const res = await fetch(DEEPSEEK_VISION_ENDPOINT, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${DEEPSEEK_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: DEEPSEEK_VISION_MODEL,
      image_url: dataUrl,
      prompt: buildPrompt(),
      mode: 'analyze',
      output_format: 'json',
    }),
  });

  const text = await res.text();
  if (!res.ok) {
    throw new Error(`DeepSeek vision failed (${res.status}): ${text.slice(0, 500)}`);
  }

  const jsonText = extractJson(text);
  if (!jsonText) {
    throw new Error('DeepSeek vision returned no JSON');
  }

  return normalizeAnalysis(JSON.parse(jsonText), 'deepseek');
}

function openAiVisionModels() {
  return Array.from(new Set([OPENAI_VISION_MODEL, 'gpt-5-mini'].filter(Boolean)));
}

async function analyzeWithOpenAiModel(dataUrl: string, model: string): Promise<MealAnalysis> {
  if (!OPENAI_API_KEY) {
    throw new Error('OPENAI_API_KEY is not configured');
  }

  const isGpt5 = model.startsWith('gpt-5');
  const res = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${OPENAI_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model,
      response_format: { type: 'json_object' },
      ...(isGpt5
        ? { max_completion_tokens: 4096 }
        : { temperature: 0.2, max_tokens: 1600 }),
      messages: [
        {
          role: 'user',
          content: [
            { type: 'text', text: buildPrompt() },
            { type: 'image_url', image_url: { url: dataUrl, detail: 'high' } },
          ],
        },
      ],
    }),
  });

  const text = await res.text();
  if (!res.ok) {
    throw new Error(`OpenAI vision failed (${res.status}): ${text.slice(0, 500)}`);
  }

  const json = JSON.parse(text);
  const content = json?.choices?.[0]?.message?.content;
  if (typeof content !== 'string' || !content.trim()) {
    const finishReason = json?.choices?.[0]?.finish_reason;
    throw new Error(`OpenAI vision returned empty content (${model}, finish_reason=${finishReason || 'unknown'})`);
  }

  const jsonText = extractJson(content);
  if (!jsonText) {
    throw new Error(`OpenAI vision returned no JSON (${model})`);
  }

  return normalizeAnalysis(JSON.parse(jsonText), 'openai');
}

async function analyzeWithOpenAi(dataUrl: string): Promise<MealAnalysis> {
  const errors: string[] = [];

  for (const model of openAiVisionModels()) {
    try {
      return await analyzeWithOpenAiModel(dataUrl, model);
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      errors.push(message);
      console.error(`[analyze-meal] OpenAI vision attempt failed (${model}):`, message);
    }
  }

  throw new Error(errors.join(' | ') || 'OpenAI vision failed');
}

export async function POST(req: NextRequest) {
  try {
    const user = await verifyFirebaseUser(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const body = (await req.json()) as Partial<AnalyzeMealBody>;
    const dataUrl = normalizeDataUrl(body);
    if (!dataUrl) {
      return NextResponse.json({ error: 'Missing image' }, { status: 400 });
    }

    if (hasDeepSeekVisionConfig()) {
      try {
        const analysis = await analyzeWithDeepSeek(dataUrl);
        return NextResponse.json({ analysis, userId: user.uid });
      } catch {
        // Fall through to OpenAI Vision when a configured DeepSeek vision endpoint is unavailable.
      }
    }

    try {
      const analysis = await analyzeWithOpenAi(dataUrl);
      return NextResponse.json({ analysis, userId: user.uid });
    } catch (openAiError) {
      const message = openAiError instanceof Error ? openAiError.message : String(openAiError);
      console.error('[analyze-meal] OpenAI vision failed:', message);
      const missingKey = message.includes('OPENAI_API_KEY');
      const invalidKey = message.includes('invalid_api_key') || message.includes('Incorrect API key');
      const quotaExceeded = message.includes('insufficient_quota') || message.includes('exceeded your current quota');
      return NextResponse.json(
        {
          error: missingKey
            ? 'OpenAI vision API key is not configured'
            : invalidKey
              ? 'OpenAI vision API key is invalid'
              : quotaExceeded
                ? 'OpenAI vision quota is exhausted'
                : 'Meal analysis failed',
          details: missingKey || invalidKey || quotaExceeded ? undefined : message,
        },
        { status: missingKey || invalidKey ? 500 : quotaExceeded ? 402 : 502 }
      );
    }
  } catch (e) {
    return NextResponse.json(
      { error: 'Unexpected error', details: e instanceof Error ? e.message : String(e) },
      { status: 500 }
    );
  }
}
