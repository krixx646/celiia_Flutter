import { NextRequest, NextResponse } from 'next/server';
import { createRemoteJWKSet, jwtVerify } from 'jose';
import { groundMealAnalysis } from '@/lib/nutrition/groundMealAnalysis';

export const runtime = 'nodejs';
export const maxDuration = 60;

const FIREBASE_PROJECT_ID = process.env.FIREBASE_PROJECT_ID;
const DEEPSEEK_API_KEY = process.env.DEEPSEEK_API_KEY;
const DEEPSEEK_VISION_ENDPOINT = process.env.DEEPSEEK_VISION_ENDPOINT;
const DEEPSEEK_VISION_MODEL = process.env.DEEPSEEK_VISION_MODEL;
const OPENAI_API_KEY = process.env.OPENAI_API_KEY;
const OPENAI_VISION_MODEL = process.env.OPENAI_VISION_MODEL || 'gpt-5.6-luna';
/** Prefer DeepSeek only when explicitly opted in; default is OpenAI-first for speed. */
const DEEPSEEK_VISION_PREFERRED = process.env.DEEPSEEK_VISION_PREFERRED === 'true';
const DEEPSEEK_VISION_TIMEOUT_MS = Number(process.env.DEEPSEEK_VISION_TIMEOUT_MS || 6000);

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

Identify every visible edible item (including brand/packaged groceries when the label is readable). Return ONLY valid JSON:
{
  "title": "Short meal name",
  "summary": "One sentence summary",
  "confidence": 0.0,
  "items": [
    {
      "name": "Food or brand+product name",
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
- Identify visible food only. Split clearly separate foods into separate items.
- Prefer common dish/product names. For packaged goods, use the brand + product name from the label when readable.
- If unsure of a brand/product, use a generic name and set confidence <= 0.45.
- Estimate servingGrams from visible portion (plate/hand scale). Be conservative.
- Do not invent food outside the frame. Omit non-food objects.
- If unclear or no food, return empty items, confidence under 0.35, and a helpful warning.
- Calories/macros must be numeric. Set confidence honestly (do not inflate).
- Macros may be approximate; a nutrition reference may refine them server-side.`;
}

function finalizeAnalysis(analysis: MealAnalysis): MealAnalysis {
  const grounded = groundMealAnalysis(analysis);
  return {
    ...grounded,
    provider: analysis.provider,
  };
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

      // Missing confidence defaults low so vague guesses do not look trustworthy.
      return {
        name,
        servingGrams: safeNumber(item.servingGrams, 0, 0),
        calories: safeNumber(item.calories, 0, 0),
        proteinGrams: safeNumber(item.proteinGrams, 0, 0),
        carbsGrams: safeNumber(item.carbsGrams, 0, 0),
        fatGrams: safeNumber(item.fatGrams, 0, 0),
        confidence: safeNumber(item.confidence, 0.35, 0, 1),
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

  const avgItemConfidence =
    items.length > 0
      ? items.reduce((sum, item) => sum + item.confidence, 0) / items.length
      : 0.2;

  return {
    title: String(obj.title || (items.length ? 'Estimated Meal' : 'No meal detected')),
    provider,
    summary: String(obj.summary || 'Estimated from the camera image.'),
    confidence: safeNumber(obj.confidence, items.length ? avgItemConfidence : 0.2, 0, 1),
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

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), DEEPSEEK_VISION_TIMEOUT_MS);

  try {
    const res = await fetch(DEEPSEEK_VISION_ENDPOINT, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${DEEPSEEK_API_KEY}`,
        'Content-Type': 'application/json',
      },
      signal: controller.signal,
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
  } catch (error) {
    if (error instanceof Error && error.name === 'AbortError') {
      throw new Error(`DeepSeek vision timed out after ${DEEPSEEK_VISION_TIMEOUT_MS}ms`);
    }
    throw error;
  } finally {
    clearTimeout(timeout);
  }
}

function openAiVisionModels() {
  // Luna first (cost). Keep a single older mini as last-resort fallback only.
  return Array.from(new Set([OPENAI_VISION_MODEL, 'gpt-5-mini'].filter(Boolean)));
}

async function analyzeWithOpenAiModel(
  dataUrl: string,
  model: string,
  detail: 'auto' | 'low' | 'high' = 'auto'
): Promise<MealAnalysis> {
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
            { type: 'image_url', image_url: { url: dataUrl, detail } },
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
      // First pass uses auto detail for speed; retry same model at high if empty/low confidence.
      let analysis = await analyzeWithOpenAiModel(dataUrl, model, 'auto');
      if (analysis.items.length === 0 || analysis.confidence < 0.4) {
        try {
          const retry = await analyzeWithOpenAiModel(dataUrl, model, 'high');
          if (retry.items.length > 0 && retry.confidence >= analysis.confidence) {
            analysis = retry;
          }
        } catch (retryError) {
          const message = retryError instanceof Error ? retryError.message : String(retryError);
          console.warn(`[analyze-meal] high-detail retry skipped (${model}):`, message);
        }
      }
      return analysis;
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      errors.push(message);
      console.error(`[analyze-meal] OpenAI vision attempt failed (${model}):`, message);
    }
  }

  throw new Error(errors.join(' | ') || 'OpenAI vision failed');
}

async function tryDeepSeek(dataUrl: string): Promise<MealAnalysis | null> {
  if (!hasDeepSeekVisionConfig()) return null;
  try {
    return await analyzeWithDeepSeek(dataUrl);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.warn('[analyze-meal] DeepSeek vision skipped:', message);
    return null;
  }
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

    // OpenAI-first by default. DeepSeek only when preferred, with a hard timeout.
    if (DEEPSEEK_VISION_PREFERRED) {
      const deepSeek = await tryDeepSeek(dataUrl);
      if (deepSeek) {
        return NextResponse.json({ analysis: finalizeAnalysis(deepSeek), userId: user.uid });
      }
    }

    try {
      const analysis = await analyzeWithOpenAi(dataUrl);
      return NextResponse.json({ analysis: finalizeAnalysis(analysis), userId: user.uid });
    } catch (openAiError) {
      // Last resort: DeepSeek if configured and OpenAI failed.
      const deepSeekFallback = await tryDeepSeek(dataUrl);
      if (deepSeekFallback) {
        return NextResponse.json({
          analysis: finalizeAnalysis(deepSeekFallback),
          userId: user.uid,
        });
      }

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
