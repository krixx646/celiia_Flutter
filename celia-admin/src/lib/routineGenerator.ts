import { ensureSavedToLibrary, findMatchingRoutine } from '@/lib/routineDedupe';
import { getSupabaseAdmin } from '@/lib/supabaseAdmin';

// Shared by POST /api/mobile/generate-routine (the Create Routine sheet) and by
// the Celia coach agent's create_routine tool, so a routine built in chat is
// identical to one built from the form.

const DEEPSEEK_API_KEY = process.env.DEEPSEEK_API_KEY;
const DEEPSEEK_TEXT_ENDPOINT =
  process.env.DEEPSEEK_TEXT_ENDPOINT || 'https://api.deepseek.com/v1/chat/completions';
// Composing a routine is a lookup-and-order job, not a reasoning one: the model
// picks entries out of a catalog it was handed. A reasoning model spends 50-60s
// deliberating over it and half the requests died on the platform's 60s ceiling
// (measured: 60.8s, 55.0s, 60.8s for three requests). `deepseek-chat` is the
// model the coach agent already composes routines with, and it answers in
// seconds. Set DEEPSEEK_ROUTINE_MODEL to override.
const DEEPSEEK_ROUTINE_MODEL = process.env.DEEPSEEK_ROUTINE_MODEL || 'deepseek-chat';

// How long to wait for the model. Comfortably inside the route's 60s budget, so
// a slow answer becomes an error we can explain rather than a bodyless 504.
const DEEPSEEK_TIMEOUT_MS = 45_000;

// Mirrors `Env.suspendRealVideos` on the Flutter side: the client's real
// filming pipeline isn't ready yet, so by default the generator only builds
// routines from the stock GIF exercise library (`exercise_media`), never
// from the (mostly empty/unprocessed) `videos` table. Flip to `false` once
// enough real videos are uploaded and ready, and this will start preferring
// real videos per exercise again, falling back to a GIF only for exercises
// that don't have a filmed video yet. This never deletes the video-matching
// code path — it just skips it while suspended.
const SUSPEND_REAL_VIDEOS = process.env.SUSPEND_REAL_VIDEOS !== 'false';

// Mirrors `Env.enableGifFallback` on the Flutter side. The client's filmed
// clip library replaced the stock GIF pack, and the app no longer renders a
// GIF anywhere, so building routines out of them would produce steps that
// show nothing. Suspended rather than removed, exactly like the videos above.
const ENABLE_GIF_FALLBACK = process.env.ENABLE_GIF_FALLBACK === 'true';

// What the clip library calls the kit an exercise needs, mapped from what the
// Create Routine sheet offers. Everything a home has anyway — a wall, a chair,
// and the bench or box a chair stands in for — is always available; only the
// bought equipment is gated on the user actually owning it.
const ALWAYS_AVAILABLE_EQUIPMENT = ['wall', 'chair', 'bench', 'box'];

const EQUIPMENT_SYNONYMS: Record<string, string[]> = {
  dumbbell: ['dumbbell', 'dumbbells', 'kettlebell', 'weight', 'weights'],
  band: ['band', 'bands', 'resistance band', 'resistance bands'],
};

export type Difficulty = 'easy' | 'medium' | 'hard';

type Category =
  | 'strength'
  | 'cardio'
  | 'flexibility'
  | 'mindfulness'
  | 'dance'
  | 'hiit'
  | 'yoga'
  | 'custom';

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

type ExerciseClipRow = {
  slug: unknown;
  name_en: unknown;
  pattern?: unknown;
  step_type?: unknown;
  equipment?: unknown;
  default_reps?: unknown;
  default_hold_seconds?: unknown;
  clip_seconds?: unknown;
  poster_url?: unknown;
};

type CatalogClip = {
  slug: string;
  name: string;
  pattern: string | null;
  /** 'reps' exercises are counted out loud, 'hold' ones run a countdown. */
  stepType: 'reps' | 'hold';
  equipment: string[];
  defaultReps: number | null;
  defaultHoldSeconds: number | null;
  clipSeconds: number;
  posterUrl: string | null;
};

// What the model actually sees: a flattened list it can reference by exact
// id, tagged with which pool ("video" or "gif") that id belongs to.
type CatalogEntryForPrompt = {
  refType: 'video' | 'gif' | 'clip';
  refId: string;
  name: string;
  category: string | null;
  muscleGroup: string | null;
  durationSeconds?: number;
  /** Clips only: tells the model whether to prescribe reps or a hold. */
  stepType?: 'reps' | 'hold';
  equipment?: string[];
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
  sets?: unknown;
  reps?: unknown;
  restSeconds?: unknown;
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
  /** Rounds of this exercise before moving on. */
  sets: number;
  /** Reps per set, or null when the exercise is held for time instead. */
  reps: number | null;
  /** Recovery after each set, including the last one. */
  rest_seconds: number;
};

type DeepSeekChatResponse = {
  choices?: Array<{
    finish_reason?: unknown;
    message?: {
      content?: unknown;
    };
  }>;
  usage?: {
    prompt_tokens?: unknown;
    completion_tokens?: unknown;
    total_tokens?: unknown;
  };
};

export type GenerateRoutineInput = {
  /** Verified Firebase uid of the owner. Never accept this from a request body. */
  uid: string;
  request: string;
  durationMinutes: number;
  difficulty: Difficulty;
  equipment: string[];
};

export type GenerateRoutineResult =
  | {
      ok: true;
      routine: Record<string, unknown>;
      /** True when this is a routine the user already had, not a new one. */
      alreadyExisted?: boolean;
    }
  | { ok: false; status: number; error: string; details?: unknown };

// The stock GIF library is ~900 exercises. Sending all of them (~33k tokens)
// made the model spend its entire token budget reasoning over near-duplicate
// entries and return empty content, so the catalog is narrowed to the entries
// that plausibly match the request before it ever reaches the prompt.
const MAX_CATALOG_ENTRIES = 150;

// Keyed by the `muscle_group` / `category` values actually stored in
// `exercise_media`. Note ~half of the rows have a NULL muscle_group, so name
// matching (not just these tags) is what carries most of the scoring.
const MUSCLE_GROUP_KEYWORDS: Record<string, string[]> = {
  shoulders: ['shoulder', 'delt', 'overhead', 'rotator'],
  chest: ['chest', 'pec', 'bench'],
  back_traps: ['back', 'lat', 'trap', 'row', 'pull', 'posture', 'spine'],
  core_abs: ['core', 'abs', 'abdominal', 'plank', 'oblique', 'stomach', 'waist'],
  legs_glutes: ['leg', 'glute', 'quad', 'hamstring', 'squat', 'lunge', 'thigh', 'hip', 'knee'],
  calves: ['calf', 'calves', 'ankle'],
};

const CATEGORY_KEYWORDS: Record<string, string[]> = {
  stretching_mobility: [
    'stretch', 'mobility', 'flexibility', 'yoga', 'warm up', 'warmup',
    'cool down', 'cooldown', 'recovery', 'loosen', 'limber',
  ],
  functional_hiit: [
    'hiit', 'cardio', 'conditioning', 'fat burn', 'sweat', 'interval',
    'explosive', 'jump', 'plyometric', 'endurance', 'metabolic',
  ],
  strength: [
    'strength', 'muscle', 'hypertrophy', 'tone', 'dumbbell', 'weight',
    'barbell', 'kettlebell', 'resistance',
  ],
  calisthenics: ['calisthenic', 'bodyweight', 'body weight', 'no equipment'],
};

// 'full' is excluded deliberately: "full body" requests otherwise score every
// exercise whose name happens to contain it ("Abs full", "Ab wheel full").
const REQUEST_STOPWORDS = new Set([
  'and', 'the', 'for', 'with', 'want', 'need', 'workout', 'exercise',
  'exercises', 'routine', 'session', 'minute', 'minutes', 'that', 'some',
  'give', 'make', 'please', 'body', 'training', 'full',
]);

function safeInt(n: unknown, fallback: number) {
  const v = typeof n === 'number' ? n : Number(n);
  return Number.isFinite(v) ? Math.trunc(v) : fallback;
}

export function clampDurationMinutes(value: unknown, fallback = 15) {
  return Math.max(5, Math.min(60, safeInt(value, fallback)));
}

export function normalizeDifficulty(value: unknown): Difficulty {
  const raw = String(value || 'medium');
  return raw === 'easy' || raw === 'medium' || raw === 'hard' ? raw : 'medium';
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

function requestTokens(text: string): string[] {
  return text
    .toLowerCase()
    .split(/[^a-z0-9]+/)
    .filter((token) => token.length >= 3 && !REQUEST_STOPWORDS.has(token));
}

function matchTagsFor(haystack: string, keywordMap: Record<string, string[]>): Set<string> {
  const matched = new Set<string>();
  for (const [tag, keywords] of Object.entries(keywordMap)) {
    if (keywords.some((keyword) => haystack.includes(keyword))) matched.add(tag);
  }
  return matched;
}

function catalogKey(entry: CatalogEntryForPrompt) {
  return `${entry.refType}:${entry.refId}`;
}

// Round-robins the leftovers by category so a narrow request still leaves the
// model a balanced set to build a full routine from, rather than 150 variations
// of one movement.
function topUpAcrossCategories(
  all: CatalogEntryForPrompt[],
  picked: CatalogEntryForPrompt[],
  limit: number
): CatalogEntryForPrompt[] {
  const chosen = new Set(picked.map(catalogKey));
  const buckets = new Map<string, CatalogEntryForPrompt[]>();

  for (const entry of all) {
    if (chosen.has(catalogKey(entry))) continue;
    const bucket = entry.category || 'other';
    const list = buckets.get(bucket) || [];
    list.push(entry);
    buckets.set(bucket, list);
  }

  const out = [...picked];
  const lists = [...buckets.values()];
  let cursor = 0;
  while (out.length < limit && lists.some((list) => list.length > 0)) {
    const next = lists[cursor % lists.length].shift();
    if (next) out.push(next);
    cursor += 1;
  }
  return out;
}

// Which of the clip library's equipment tags this user can actually work
// with, given what they ticked on the Create Routine sheet.
function availableEquipment(selected: string[]): Set<string> {
  const available = new Set(ALWAYS_AVAILABLE_EQUIPMENT);
  const haystack = selected.join(' ').toLowerCase();

  for (const [tag, synonyms] of Object.entries(EQUIPMENT_SYNONYMS)) {
    if (synonyms.some((synonym) => haystack.includes(synonym))) available.add(tag);
  }
  return available;
}

function selectCatalogForPrompt(
  entries: CatalogEntryForPrompt[],
  requestText: string,
  equipment: string[],
  limit: number
): CatalogEntryForPrompt[] {
  if (entries.length <= limit) return entries;

  const haystack = [requestText, ...equipment].join(' ').toLowerCase();
  const tokens = requestTokens(haystack);
  const wantedGroups = matchTagsFor(haystack, MUSCLE_GROUP_KEYWORDS);
  const wantedCategories = matchTagsFor(haystack, CATEGORY_KEYWORDS);

  const relevant = entries
    .map((entry) => {
      let score = 0;
      if (entry.muscleGroup && wantedGroups.has(entry.muscleGroup)) score += 4;
      if (entry.category && wantedCategories.has(entry.category)) score += 2;
      const name = entry.name.toLowerCase();
      for (const token of tokens) {
        if (name.includes(token)) score += 3;
      }
      return { entry, score };
    })
    .filter((scored) => scored.score > 0)
    .sort((a, b) => b.score - a.score)
    .map((scored) => scored.entry);

  if (relevant.length >= limit) return relevant.slice(0, limit);
  return topUpAcrossCategories(entries, relevant, limit);
}

export async function generateRoutine(
  input: GenerateRoutineInput
): Promise<GenerateRoutineResult> {
  const { uid, request: requestText, durationMinutes, difficulty, equipment } = input;

  if (!DEEPSEEK_API_KEY) {
    return { ok: false, status: 500, error: 'DEEPSEEK_API_KEY is not configured' };
  }
  if (!requestText.trim()) {
    return { ok: false, status: 400, error: 'Missing request' };
  }

  const supabase = getSupabaseAdmin();

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
      return { ok: false, status: 500, error: 'Failed to load videos', details: vidErr.message };
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

  // The client's filmed clip library: the primary catalog, and the only pool
  // the guided player can coach a user through, because these are the only
  // exercises with a known rep cycle to count against.
  const { data: clips, error: clipErr } = await supabase
    .from('exercise_clips')
    .select(
      'slug,name_en,pattern,step_type,equipment,default_reps,' +
        'default_hold_seconds,clip_seconds,poster_url'
    )
    .eq('is_active', true)
    .limit(500);

  if (clipErr) {
    return {
      ok: false,
      status: 500,
      error: 'Failed to load exercise library',
      details: clipErr.message,
    };
  }

  const usable = availableEquipment(equipment);
  const clipCatalog: CatalogClip[] = ((clips || []) as unknown as ExerciseClipRow[])
    .map((c) => ({
      slug: String(c.slug || ''),
      name: String(c.name_en || ''),
      pattern: c.pattern ? String(c.pattern) : null,
      stepType: c.step_type === 'hold' ? ('hold' as const) : ('reps' as const),
      equipment: Array.isArray(c.equipment) ? c.equipment.map(String) : [],
      defaultReps: c.default_reps == null ? null : safeInt(c.default_reps, 0) || null,
      defaultHoldSeconds:
        c.default_hold_seconds == null ? null : safeInt(c.default_hold_seconds, 0) || null,
      clipSeconds: Number(c.clip_seconds) || 0,
      posterUrl: c.poster_url ? String(c.poster_url) : null,
    }))
    .filter((c) => c.slug && c.equipment.every((item) => usable.has(item)));

  // Stock GIF exercise library, suspended alongside the app's GIF rendering.
  let gifCatalog: CatalogGif[] = [];
  if (ENABLE_GIF_FALLBACK) {
    const { data: gifs, error: gifErr } = await supabase
      .from('exercise_media')
      .select('slug,display_name,muscle_group,category')
      .limit(1000);

    if (gifErr) {
      return {
        ok: false,
        status: 500,
        error: 'Failed to load exercise library',
        details: gifErr.message,
      };
    }

    gifCatalog = ((gifs || []) as ExerciseMediaRow[]).map((g) => ({
      slug: String(g.slug || ''),
      displayName: String(g.display_name || ''),
      muscleGroup: g.muscle_group ? String(g.muscle_group) : null,
      category: g.category ? String(g.category) : null,
    }));
  }

  if (videoCatalog.length === 0 && clipCatalog.length === 0 && gifCatalog.length === 0) {
    return { ok: false, status: 400, error: 'No exercises available to build a routine' };
  }

  const videoEntries: CatalogEntryForPrompt[] = videoCatalog.map((v) => ({
    refType: 'video' as const,
    refId: v.id,
    name: v.title,
    category: v.category,
    muscleGroup: v.bodyPart,
    durationSeconds: v.durationSeconds,
  }));

  const clipEntries: CatalogEntryForPrompt[] = clipCatalog.map((c) => ({
    refType: 'clip' as const,
    refId: c.slug,
    name: c.name,
    category: c.pattern,
    muscleGroup: c.pattern,
    stepType: c.stepType,
    equipment: c.equipment,
  }));

  const gifEntries: CatalogEntryForPrompt[] = gifCatalog.map((g) => ({
    refType: 'gif' as const,
    refId: g.slug,
    name: g.displayName,
    category: g.category,
    muscleGroup: g.muscleGroup,
  }));

  // Filmed clips and videos are the preferred pools and small enough to send
  // whole; only the much larger GIF library ever gets narrowed.
  const gifBudget = Math.max(
    0,
    MAX_CATALOG_ENTRIES - videoEntries.length - clipEntries.length
  );
  const promptCatalog: CatalogEntryForPrompt[] = [
    ...clipEntries,
    ...videoEntries,
    ...(gifBudget > 0
      ? selectCatalogForPrompt(gifEntries, requestText, equipment, gifBudget)
      : []),
  ];

  const preferClipRule = clipEntries.length > 0
    ? '- Prefer "clip" entries over every other type. They are the only exercises Celia can demonstrate and count out loud.'
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
      "refType": "clip" | "video" | "gif",
      "refId": "EXACT_ID_FROM_CATALOG",
      "orderIndex": 0,
      "sets": 3,
      "reps": 12,
      "durationSeconds": 0,
      "restSeconds": 45
    }
  ],
  "tags": ["tag1","tag2"],
  "caloriesBurned": 150,
  "equipment": "None" or "Dumbbells, Mat"
}

Rules:
- Build a varied routine that actually fits the user's request (target muscle groups / workout style), not just whatever is easiest — the catalog has strength, calisthenics, functional/HIIT, and stretching/mobility exercises to choose from.
- It's fine to reuse the same exercise as multiple steps (e.g. as a superset or second round), but don't make the whole routine a single exercise repeated unless the user explicitly asked for that.
${preferClipRule}
- Every step is prescribed as sets, and each set is either counted in reps or held for time. Catalog entries carry a "stepType" saying which:
  - "reps": set "reps" to a whole number (typically 8-15) and "durationSeconds" to 0. Celia counts these out loud.
  - "hold": set "reps" to 0 and "durationSeconds" to how long to hold each set (typically 20-60s). Celia runs a countdown.
  Entries with no "stepType" are older library entries; treat those as "hold".
- "sets" is 1-5. Use more sets for strength work, one for stretches and cool-downs.
- "restSeconds" is the recovery after each set: 0-30s for mobility and easy work, 30-60s for strength, 60-90s for hard compound lifts. Use 0 only for stretches.
- The whole routine, including rest, should come to roughly the requested duration.
- Keep steps <= 40.
`;

  const userPrompt = {
    request: requestText,
    durationMinutes,
    difficulty,
    equipment,
    catalog: promptCatalog,
  };

  const askedAt = Date.now();
  let deepSeekRes: Response;
  try {
    deepSeekRes = await fetch(DEEPSEEK_TEXT_ENDPOINT, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${DEEPSEEK_API_KEY}`,
        'Content-Type': 'application/json',
      },
      signal: AbortSignal.timeout(DEEPSEEK_TIMEOUT_MS),
      body: JSON.stringify({
        model: DEEPSEEK_ROUTINE_MODEL,
        response_format: { type: 'json_object' },
        temperature: 1.0,
        top_p: 1.0,
        // A 40-step routine is around 1.5k tokens of JSON; this leaves room to
        // spare without inviting the model to fill it.
        max_tokens: 4000,
        messages: [
          { role: 'system', content: system },
          { role: 'user', content: JSON.stringify(userPrompt) },
        ],
      }),
    });
  } catch (e) {
    const timedOut = e instanceof Error && e.name === 'TimeoutError';
    console.error('[generate-routine] model call failed', {
      model: DEEPSEEK_ROUTINE_MODEL,
      catalogSize: promptCatalog.length,
      elapsedMs: Date.now() - askedAt,
      timedOut,
    });
    return {
      ok: false,
      status: timedOut ? 504 : 502,
      error: timedOut
        ? 'Building your routine took too long. Please try again.'
        : 'Could not reach the routine builder. Please try again.',
    };
  }

  if (!deepSeekRes.ok) {
    const text = await deepSeekRes.text().catch(() => '');
    return {
      ok: false,
      status: 500,
      error: 'DeepSeek request failed',
      details: { status: deepSeekRes.status, body: text.slice(0, 500) },
    };
  }

  const deepSeekJson = (await deepSeekRes.json()) as DeepSeekChatResponse;
  // Logged on every generation so a creeping model slowdown is visible in the
  // function logs before it starts timing out again.
  console.log('[generate-routine] model answered', {
    model: DEEPSEEK_ROUTINE_MODEL,
    catalogSize: promptCatalog.length,
    elapsedMs: Date.now() - askedAt,
    usage: deepSeekJson.usage ?? null,
  });
  const content = deepSeekJson.choices?.[0]?.message?.content;
  if (typeof content !== 'string' || !content.trim()) {
    return {
      ok: false,
      status: 500,
      error: 'DeepSeek returned empty response',
      details: {
        finishReason: deepSeekJson.choices?.[0]?.finish_reason ?? null,
        usage: deepSeekJson.usage ?? null,
        catalogSize: promptCatalog.length,
      },
    };
  }

  let routineJson: RoutineJson;
  try {
    routineJson = JSON.parse(extractJson(content)) as RoutineJson;
  } catch {
    return {
      ok: false,
      status: 500,
      error: 'DeepSeek returned invalid JSON',
      details: content.slice(0, 500),
    };
  }

  const videoById = new Map(videoCatalog.map((v) => [v.id, v]));
  const gifBySlug = new Map(gifCatalog.map((g) => [g.slug, g]));
  const clipBySlug = new Map(clipCatalog.map((c) => [c.slug, c]));
  const rawSteps = Array.isArray(routineJson.steps) ? routineJson.steps : [];

  // A prescription the player can actually run. The model is asked for sets,
  // reps and rest, but a routine is too important to leave at the mercy of
  // whether it obliged, so anything missing falls back to the clip library's
  // own reviewed defaults.
  const prescriptionFor = (s: RoutineStepJson, clip: CatalogClip | undefined) => {
    const sets = Math.max(1, Math.min(5, safeInt(s?.sets, 1)));
    const rest = Math.max(0, Math.min(180, safeInt(s?.restSeconds, 30)));

    const counted = clip ? clip.stepType === 'reps' : false;
    const reps = counted
      ? Math.max(1, safeInt(s?.reps, clip?.defaultReps ?? 10))
      : null;

    let duration = safeInt(s?.durationSeconds, 0);
    if (counted) {
      // Time is the product of the reps and the clip, not a separate number
      // the model gets to invent; the player derives it from the loop.
      duration = Math.max(1, Math.round((reps ?? 1) * (clip?.clipSeconds || 3)));
    } else if (duration <= 0) {
      duration = clip?.defaultHoldSeconds ?? 30;
    }

    return { sets, reps, rest_seconds: rest, duration_seconds: duration };
  };

  const steps = rawSteps
    .slice(0, 40)
    .map((s, idx) => {
      if (!isRoutineStepJson(s)) return null;
      const refType = String(s?.refType || '').trim();
      const refId = String(s?.refId || '').trim();

      if (refType === 'clip') {
        const meta = clipBySlug.get(refId);
        if (!meta) return null;

        const step: StepPayload = {
          id: crypto.randomUUID(),
          title: String(s?.title || meta.name || 'Exercise'),
          description: s?.description ? String(s.description) : null,
          video_id: null,
          exercise_slug: refId,
          thumbnail_url: meta.posterUrl,
          order_index: safeInt(s?.orderIndex, idx),
          ...prescriptionFor(s, meta),
        };
        return step;
      }

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
          sets: Math.max(1, Math.min(5, safeInt(s?.sets, 1))),
          reps: null,
          rest_seconds: Math.max(0, Math.min(180, safeInt(s?.restSeconds, 0))),
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
          sets: Math.max(1, Math.min(5, safeInt(s?.sets, 1))),
          reps: null,
          rest_seconds: Math.max(0, Math.min(180, safeInt(s?.restSeconds, 0))),
        };
        return step;
      }

      return null;
    })
    .filter((step): step is StepPayload => step !== null);

  if (steps.length === 0) {
    return {
      ok: false,
      status: 500,
      error: 'No valid steps could be built from the exercise catalog',
    };
  }

  // Normalize ordering
  steps.sort((a, b) => safeInt(a.order_index, 0) - safeInt(b.order_index, 0));
  steps.forEach((s, i) => (s.order_index = i));

  // Asking twice for the same workout used to leave two identical routines in
  // the library. If this sequence already exists, hand back that one instead.
  // This has to come after the sort above, because the order of the exercises
  // is half of what identifies a routine.
  const existing = await findMatchingRoutine(uid, steps);
  if (existing) {
    await ensureSavedToLibrary(uid, existing.id);
    return { ok: true, routine: existing.row, alreadyExisted: true };
  }

  const payload = {
    title: String(routineJson?.title || 'Personalized Routine'),
    description: routineJson?.description ? String(routineJson.description) : null,
    duration_minutes: durationMinutes,
    difficulty,
    category: normalizeCategory(routineJson?.category),
    thumbnail_url: steps[0]?.thumbnail_url ?? null,
    steps, // JSONB (snake_case) to match Flutter model mapping
    created_by: uid,
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
    return { ok: false, status: 500, error: 'Failed to save routine', details: createErr.message };
  }

  // Automatically save it to the user's library so it persists across app restarts.
  try {
    await supabase.from('user_routines').insert({
      user_id: uid,
      routine_id: created.id,
      saved_at: new Date().toISOString(),
    });
  } catch {
    // If RLS/constraints block this insert, it's non-fatal: the routine still exists and is playable immediately.
  }

  // Optional: record request history
  try {
    await supabase.from('routine_requests').insert({
      user_id: uid,
      request_text: requestText,
      generated_routine_id: created.id,
      status: 'completed',
      completed_at: new Date().toISOString(),
    });
  } catch {
    // ignore
  }

  return { ok: true, routine: created };
}
