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
const DEEPSEEK_API_KEY = process.env.DEEPSEEK_API_KEY;
const DEEPSEEK_TEXT_ENDPOINT =
  process.env.DEEPSEEK_TEXT_ENDPOINT || 'https://api.deepseek.com/v1/chat/completions';
const DEEPSEEK_TEXT_MODEL = process.env.DEEPSEEK_TEXT_MODEL || 'deepseek-v4-pro';

// Mirrors `Env.suspendRealVideos` on the Flutter side: the client's real
// filming pipeline isn't ready yet, so by default the generator only builds
// routines from the stock GIF exercise library (`exercise_media`), never
// from the (mostly empty/unprocessed) `videos` table. Flip to `false` once
// enough real videos are uploaded and ready, and this route will start
// preferring real videos per exercise again, falling back to a GIF only for
// exercises that don't have a filmed video yet. This never deletes the
// video-matching code path — it just skips it while suspended.
const SUSPEND_REAL_VIDEOS = process.env.SUSPEND_REAL_VIDEOS !== 'false';

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

type VideoCatalogRow = {
  id: unknown;
  title: unknown;
  category?: unknown;
  body_part?: unknown;
  difficulty?: unknown;
  duration_seconds?: unknown;
  thumbnail_url?: unknown;
};

type CatalogVideo = {
  id: string;
  title: string;
  category: string | null;
  bodyPart: string | null;
  difficulty: string | null;
  durationSeconds: number;
  thumbnailUrl: string | null;
};

type ExerciseMediaRow = {
  slug: unknown;
  display_name: unknown;
  muscle_group?: unknown;
  category?: unknown;
};

type CatalogGif = {
  slug: string;
  displayName: string;
  muscleGroup: string | null;
  category: string | null;
};

// What the model actually sees: a flattened list it can reference by exact
// id, tagged with which pool ("video" or "gif") that id belongs to.
type CatalogEntryForPrompt = {
  refType: 'video' | 'gif';
  refId: string;
  name: string;
  category: string | null;
  muscleGroup: string | null;
  durationSeconds?: number;
};

type RoutineJson = {
  title?: unknown;
  description?: unknown;
  category?: unknown;
  steps?: unknown;
  tags?: unknown;
  caloriesBurned?: unknown;
  equipment?: unknown;
};

type RoutineStepJson = {
  title?: unknown;
  description?: unknown;
  durationSeconds?: unknown;
  refType?: unknown;
  refId?: unknown;
  orderIndex?: unknown;
};

type StepPayload = {
  id: string;
  title: string;
  description: string | null;
  duration_seconds: number;
  video_id: string | null;
  exercise_slug: string | null;
  thumbnail_url: string | null;
  order_index: number;
};

type DeepSeekChatResponse = {
  choices?: Array<{
    message?: {
      content?: unknown;
    };
  }>;
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

function extractJson(text: string) {
  const trimmed = text.trim();
  if (trimmed.startsWith('{') && trimmed.endsWith('}')) return trimmed;
  const match = trimmed.match(/\{[\s\S]*\}/);
  return match?.[0] || '';
}

function isRoutineStepJson(value: unknown): value is RoutineStepJson {
  return Boolean(value && typeof value === 'object');
}

function normalizeCategory(value: unknown): Category {
  const raw = String(value || 'custom');
  const categories: Category[] = [
    'strength',
    'cardio',
    'flexibility',
    'mindfulness',
    'dance',
    'hiit',
    'yoga',
    'custom',
  ];
  return categories.includes(raw as Category) ? (raw as Category) : 'custom';
}

export async function POST(req: NextRequest) {
  try {
    if (!DEEPSEEK_API_KEY) {
      return NextResponse.json({ error: 'DEEPSEEK_API_KEY is not configured' }, { status: 500 });
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

    // Real filmed videos, only when the client's video pipeline isn't suspended.
    let videoCatalog: CatalogVideo[] = [];
    if (!SUSPEND_REAL_VIDEOS) {
      const { data: videos, error: vidErr } = await supabase
        .from('videos')
        .select('id,title,category,body_part,difficulty,duration_seconds,thumbnail_url,status')
        .eq('status', 'ready')
        .order('uploaded_at', { ascending: false })
        .limit(200);

      if (vidErr) {
        return NextResponse.json({ error: 'Failed to load videos', details: vidErr.message }, { status: 500 });
      }

      videoCatalog = ((videos || []) as VideoCatalogRow[]).map((v) => ({
        id: String(v.id),
        title: String(v.title || ''),
        category: v.category ? String(v.category) : null,
        bodyPart: v.body_part ? String(v.body_part) : null,
        difficulty: v.difficulty ? String(v.difficulty) : null,
        durationSeconds: safeInt(v.duration_seconds, 0),
        thumbnailUrl: v.thumbnail_url ? String(v.thumbnail_url) : null,
      }));
    }

    // Stock GIF exercise library — the primary catalog while real videos are
    // suspended, and always a fallback for exercises without a filmed video.
    const { data: gifs, error: gifErr } = await supabase
      .from('exercise_media')
      .select('slug,display_name,muscle_group,category')
      .limit(1000);

    if (gifErr) {
      return NextResponse.json({ error: 'Failed to load exercise library', details: gifErr.message }, { status: 500 });
    }

    const gifCatalog: CatalogGif[] = ((gifs || []) as ExerciseMediaRow[]).map((g) => ({
      slug: String(g.slug || ''),
      displayName: String(g.display_name || ''),
      muscleGroup: g.muscle_group ? String(g.muscle_group) : null,
      category: g.category ? String(g.category) : null,
    }));

    if (videoCatalog.length === 0 && gifCatalog.length === 0) {
      return NextResponse.json({ error: 'No exercises available to build a routine' }, { status: 400 });
    }

    const promptCatalog: CatalogEntryForPrompt[] = [
      ...videoCatalog.map((v) => ({
        refType: 'video' as const,
        refId: v.id,
        name: v.title,
        category: v.category,
        muscleGroup: v.bodyPart,
        durationSeconds: v.durationSeconds,
      })),
      ...gifCatalog.map((g) => ({
        refType: 'gif' as const,
        refId: g.slug,
        name: g.displayName,
        category: g.category,
        muscleGroup: g.muscleGroup,
      })),
    ];

    const preferVideoRule = videoCatalog.length > 0
      ? '- When both a "video" and a "gif" entry fit the same exercise, prefer "video".'
      : '';

    const system = `
You are Celia, an AI fitness coach.

You MUST build a routine using ONLY the exercises provided in the catalog below. Every step MUST include a "refType" ("video" or "gif") and a "refId" that matches one of the provided catalog entries EXACTLY (same refType + refId pair). Never invent a refId that isn't in the catalog.

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
      "refType": "video" or "gif",
      "refId": "EXACT_ID_FROM_CATALOG",
      "orderIndex": 0
    }
  ],
  "tags": ["tag1","tag2"],
  "caloriesBurned": 150,
  "equipment": "None" or "Dumbbells, Mat"
}

Rules:
- Build a varied routine that actually fits the user's request (target muscle groups / workout style), not just whatever is easiest — the catalog has strength, calisthenics, functional/HIIT, and stretching/mobility exercises to choose from.
- It's fine to reuse the same exercise as multiple steps (e.g. as a superset or second round), but don't make the whole routine a single exercise repeated unless the user explicitly asked for that.
- durationSeconds must be an integer > 0 (typically 20-60s per step).
${preferVideoRule}
- Keep steps <= 40.
`;

    const userPrompt = {
      request: requestText,
      durationMinutes,
      difficulty,
      equipment,
      catalog: promptCatalog,
    };

    const deepSeekRes = await fetch(DEEPSEEK_TEXT_ENDPOINT, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${DEEPSEEK_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: DEEPSEEK_TEXT_MODEL,
        response_format: { type: 'json_object' },
        temperature: 1.0,
        top_p: 1.0,
        max_tokens: 2500,
        messages: [
          { role: 'system', content: system },
          { role: 'user', content: JSON.stringify(userPrompt) },
        ],
      }),
    });

    if (!deepSeekRes.ok) {
      const text = await deepSeekRes.text().catch(() => '');
      return NextResponse.json(
        { error: 'DeepSeek request failed', status: deepSeekRes.status, details: text.slice(0, 500) },
        { status: 500 }
      );
    }

    const deepSeekJson = (await deepSeekRes.json()) as DeepSeekChatResponse;
    const content = deepSeekJson.choices?.[0]?.message?.content;
    if (typeof content !== 'string' || !content.trim()) {
      return NextResponse.json({ error: 'DeepSeek returned empty response' }, { status: 500 });
    }

    let routineJson: RoutineJson;
    try {
      routineJson = JSON.parse(extractJson(content)) as RoutineJson;
    } catch {
      return NextResponse.json({ error: 'DeepSeek returned invalid JSON', raw: content.slice(0, 500) }, { status: 500 });
    }

    const videoById = new Map(videoCatalog.map((v) => [v.id, v]));
    const gifBySlug = new Map(gifCatalog.map((g) => [g.slug, g]));
    const rawSteps = Array.isArray(routineJson.steps) ? routineJson.steps : [];

    const steps = rawSteps
      .slice(0, 40)
      .map((s, idx) => {
        if (!isRoutineStepJson(s)) return null;
        const refType = String(s?.refType || '').trim();
        const refId = String(s?.refId || '').trim();

        if (refType === 'video') {
          const meta = videoById.get(refId);
          if (!meta) return null;

          const clipLen = safeInt(meta.durationSeconds, 0);
          let durationSeconds = safeInt(s?.durationSeconds, clipLen > 0 ? clipLen : 30);
          if (durationSeconds <= 0) durationSeconds = clipLen > 0 ? clipLen : 30;
          if (clipLen > 0) durationSeconds = Math.min(durationSeconds, clipLen);

          const step: StepPayload = {
            id: crypto.randomUUID(),
            title: String(s?.title || meta.title || 'Exercise'),
            description: s?.description ? String(s.description) : null,
            duration_seconds: durationSeconds,
            video_id: refId,
            exercise_slug: null,
            thumbnail_url: meta.thumbnailUrl,
            order_index: safeInt(s?.orderIndex, idx),
          };
          return step;
        }

        if (refType === 'gif') {
          const meta = gifBySlug.get(refId);
          if (!meta) return null;

          let durationSeconds = safeInt(s?.durationSeconds, 30);
          if (durationSeconds <= 0) durationSeconds = 30;

          const step: StepPayload = {
            id: crypto.randomUUID(),
            title: String(s?.title || meta.displayName || 'Exercise'),
            description: s?.description ? String(s.description) : null,
            duration_seconds: durationSeconds,
            video_id: null,
            exercise_slug: refId,
            // Left null on purpose: the app resolves the GIF thumbnail from
            // `exercise_slug` at display time (single source of truth),
            // rather than duplicating the GIF URL here.
            thumbnail_url: null,
            order_index: safeInt(s?.orderIndex, idx),
          };
          return step;
        }

        return null;
      })
      .filter((step): step is StepPayload => step !== null);

    if (steps.length === 0) {
      return NextResponse.json({ error: 'No valid steps could be built from the exercise catalog' }, { status: 500 });
    }

    // Normalize ordering
    steps.sort((a, b) => safeInt(a.order_index, 0) - safeInt(b.order_index, 0));
    steps.forEach((s, i) => (s.order_index = i));

    const payload = {
      title: String(routineJson?.title || 'Personalized Routine'),
      description: routineJson?.description ? String(routineJson.description) : null,
      duration_minutes: durationMinutes,
      difficulty,
      category: normalizeCategory(routineJson?.category),
      thumbnail_url: steps[0]?.thumbnail_url ?? null,
      steps, // JSONB (snake_case) to match Flutter model mapping
      created_by: user.uid,
      // Personalized routines are private to the user by default (not part of the global library).
      is_published: false,
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

    // Automatically save it to the user's library so it persists across app restarts.
    try {
      await supabase.from('user_routines').insert({
        user_id: user.uid,
        routine_id: created.id,
        saved_at: new Date().toISOString(),
      });
    } catch {
      // If RLS/constraints block this insert, it's non-fatal: the routine still exists and is playable immediately.
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
  } catch (e) {
    return NextResponse.json(
      { error: 'Unexpected error', details: e instanceof Error ? e.message : String(e) },
      { status: 500 }
    );
  }
}
