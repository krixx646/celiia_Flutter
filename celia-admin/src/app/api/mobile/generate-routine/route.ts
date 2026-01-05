import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
import { createRemoteJWKSet, jwtVerify } from 'jose';

export const runtime = 'nodejs';
export const maxDuration = 60;

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

const FIREBASE_PROJECT_ID = process.env.FIREBASE_PROJECT_ID;
const OPENAI_API_KEY = process.env.OPENAI_API_KEY;

const FIREBASE_JWKS = createRemoteJWKSet(
  new URL('https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com')
);

type Difficulty = 'easy' | 'medium' | 'hard';
type Category =
  | 'strength'
  | 'cardio'
  | 'flexibility'
  | 'mindfulness'
  | 'dance'
  | 'hiit'
  | 'yoga'
  | 'custom';

type GenerateBody = {
  request: string;
  durationMinutes?: number;
  difficulty?: Difficulty;
  equipment?: string[];
};

async function verifyFirebaseUser(req: NextRequest): Promise<{ uid: string } | null> {
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

function safeInt(n: unknown, fallback: number) {
  const v = typeof n === 'number' ? n : Number(n);
  return Number.isFinite(v) ? Math.trunc(v) : fallback;
}

export async function POST(req: NextRequest) {
  try {
    if (!OPENAI_API_KEY) {
      return NextResponse.json({ error: 'OPENAI_API_KEY is not configured' }, { status: 500 });
    }
    if (!process.env.NEXT_PUBLIC_SUPABASE_URL || !process.env.SUPABASE_SERVICE_ROLE_KEY) {
      return NextResponse.json({ error: 'Supabase service is not configured' }, { status: 500 });
    }

    // Require Firebase auth in production. In dev, you can omit FIREBASE_PROJECT_ID to bypass.
    const user = await verifyFirebaseUser(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const body = (await req.json()) as Partial<GenerateBody>;
    const requestText = String(body.request || '').trim();
    if (!requestText) {
      return NextResponse.json({ error: 'Missing request' }, { status: 400 });
    }

    const durationMinutes = Math.max(5, Math.min(60, safeInt(body.durationMinutes, 15)));
    const difficulty = (body.difficulty || 'medium') as Difficulty;
    const equipment = Array.isArray(body.equipment) ? body.equipment.map(String) : [];

    // Fetch eligible videos (ready only).
    const { data: videos, error: vidErr } = await supabase
      .from('videos')
      .select('id,title,category,body_part,difficulty,duration_seconds,thumbnail_url,status')
      .eq('status', 'ready')
      .order('uploaded_at', { ascending: false })
      .limit(200);

    if (vidErr) {
      return NextResponse.json({ error: 'Failed to load videos', details: vidErr.message }, { status: 500 });
    }

    const catalog = (videos || []).map((v: any) => ({
      id: String(v.id),
      title: String(v.title || ''),
      category: v.category ? String(v.category) : null,
      bodyPart: v.body_part ? String(v.body_part) : null,
      difficulty: v.difficulty ? String(v.difficulty) : null,
      durationSeconds: safeInt(v.duration_seconds, 0),
      thumbnailUrl: v.thumbnail_url ? String(v.thumbnail_url) : null,
    }));

    if (catalog.length === 0) {
      return NextResponse.json({ error: 'No ready videos available to build a routine' }, { status: 400 });
    }

    const system = `
You are Celia, an AI fitness coach.

You MUST build a routine that uses ONLY the provided video catalog. Every step MUST include a "videoId" that matches one of the provided catalog "id" values exactly.

Respond ONLY with valid JSON:
{
  "title": "Routine Title",
  "description": "Brief description",
  "durationMinutes": ${durationMinutes},
  "difficulty": "easy|medium|hard",
  "category": "strength|cardio|flexibility|mindfulness|dance|hiit|yoga|custom",
  "steps": [
    {
      "title": "Step title",
      "description": "Short coaching cue",
      "durationSeconds": 30,
      "videoId": "UUID_FROM_CATALOG",
      "orderIndex": 0
    }
  ],
  "tags": ["tag1","tag2"],
  "caloriesBurned": 150,
  "equipment": "None" or "Dumbbells, Mat"
}

Rules:
- Create a routine that is playable using short clips: if a clip is short, you can repeat it as multiple steps.
- durationSeconds must be an integer > 0.
- Keep steps <= 40.
- Prefer matching body part/category/difficulty to the request.
`;

    const userPrompt = {
      request: requestText,
      durationMinutes,
      difficulty,
      equipment,
      catalog,
    };

    const openaiRes = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${OPENAI_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        response_format: { type: 'json_object' },
        temperature: 0.7,
        max_tokens: 2500,
        messages: [
          { role: 'system', content: system },
          { role: 'user', content: JSON.stringify(userPrompt) },
        ],
      }),
    });

    if (!openaiRes.ok) {
      const text = await openaiRes.text().catch(() => '');
      return NextResponse.json(
        { error: 'OpenAI request failed', status: openaiRes.status, details: text.slice(0, 500) },
        { status: 500 }
      );
    }

    const openaiJson: any = await openaiRes.json();
    const content = openaiJson?.choices?.[0]?.message?.content;
    if (typeof content !== 'string' || !content.trim()) {
      return NextResponse.json({ error: 'OpenAI returned empty response' }, { status: 500 });
    }

    let routineJson: any;
    try {
      routineJson = JSON.parse(content);
    } catch {
      return NextResponse.json({ error: 'OpenAI returned invalid JSON', raw: content.slice(0, 500) }, { status: 500 });
    }

    const byId = new Map(catalog.map((v) => [v.id, v]));
    const rawSteps: any[] = Array.isArray(routineJson?.steps) ? routineJson.steps : [];

    const steps = rawSteps
      .slice(0, 40)
      .map((s, idx) => {
        const videoId = String(s?.videoId || '').trim();
        const meta = byId.get(videoId);
        if (!meta) return null;

        const clipLen = safeInt(meta.durationSeconds, 0);
        let durationSeconds = safeInt(s?.durationSeconds, clipLen > 0 ? clipLen : 30);
        if (durationSeconds <= 0) durationSeconds = clipLen > 0 ? clipLen : 30;
        if (clipLen > 0) durationSeconds = Math.min(durationSeconds, clipLen);

        return {
          id: crypto.randomUUID(),
          title: String(s?.title || meta.title || 'Exercise'),
          description: s?.description ? String(s.description) : null,
          duration_seconds: durationSeconds,
          video_id: videoId,
          thumbnail_url: meta.thumbnailUrl,
          order_index: safeInt(s?.orderIndex, idx),
        };
      })
      .filter(Boolean);

    if (steps.length === 0) {
      return NextResponse.json({ error: 'No valid steps could be built from the video catalog' }, { status: 500 });
    }

    // Normalize ordering
    steps.sort((a: any, b: any) => safeInt(a.order_index, 0) - safeInt(b.order_index, 0));
    steps.forEach((s: any, i: number) => (s.order_index = i));

    const payload = {
      title: String(routineJson?.title || 'Personalized Routine'),
      description: routineJson?.description ? String(routineJson.description) : null,
      duration_minutes: durationMinutes,
      difficulty,
      category: (routineJson?.category || 'custom') as Category,
      thumbnail_url: steps[0]?.thumbnail_url ?? null,
      steps, // JSONB (snake_case) to match Flutter model mapping
      created_by: user.uid,
      is_published: true,
      is_curated: false,
      tags: Array.isArray(routineJson?.tags) ? routineJson.tags.map(String) : [],
      calories_burned: routineJson?.caloriesBurned != null ? safeInt(routineJson.caloriesBurned, 0) : null,
      equipment: typeof routineJson?.equipment === 'string' ? routineJson.equipment : null,
    };

    const { data: created, error: createErr } = await supabase
      .from('routines')
      .insert(payload)
      .select()
      .single();

    if (createErr) {
      return NextResponse.json({ error: 'Failed to save routine', details: createErr.message }, { status: 500 });
    }

    // Optional: record request history
    try {
      await supabase.from('routine_requests').insert({
        user_id: user.uid,
        request_text: requestText,
        generated_routine_id: created.id,
        status: 'completed',
        completed_at: new Date().toISOString(),
      });
    } catch {
      // ignore
    }

    return NextResponse.json({ routine: created });
  } catch (e: any) {
    return NextResponse.json({ error: 'Unexpected error', details: e?.message || String(e) }, { status: 500 });
  }
}


