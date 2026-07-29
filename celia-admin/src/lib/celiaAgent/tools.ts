import { tool } from 'ai';
import { z } from 'zod';
import { getSupabaseAdmin } from '@/lib/supabaseAdmin';

/**
 * Per-request context handed to every tool by the route via `toolsContext`.
 *
 * `uid` comes from the verified Firebase token, never from the model or the
 * request body — otherwise a user could ask Celia to read someone else's data.
 */
const userContext = z.object({
  uid: z.string().min(1),
  /**
   * Minutes east of UTC on the user's device (Flutter's
   * `DateTime.now().timeZoneOffset.inMinutes`). Day buckets are computed with
   * this so "today's calories" matches what the app shows, instead of drifting
   * to the server's UTC midnight.
   */
  tzOffsetMinutes: z.number(),
});

const MS_PER_DAY = 86_400_000;

/** The local calendar date (YYYY-MM-DD) that an instant falls on for the user. */
function localDayKey(iso: string, tzOffsetMinutes: number): string {
  const shifted = new Date(iso).getTime() + tzOffsetMinutes * 60_000;
  return new Date(shifted).toISOString().slice(0, 10);
}

/** UTC instant of the user's local midnight, `daysAgo` days back. */
function startOfLocalDay(tzOffsetMinutes: number, daysAgo = 0): Date {
  const offsetMs = tzOffsetMinutes * 60_000;
  const shiftedNow = Date.now() + offsetMs;
  const shiftedDayStart = Math.floor(shiftedNow / MS_PER_DAY) * MS_PER_DAY;
  return new Date(shiftedDayStart - daysAgo * MS_PER_DAY - offsetMs);
}

function round(value: number) {
  return Math.round(value * 10) / 10;
}

type MealRow = {
  title?: unknown;
  calories?: unknown;
  protein_grams?: unknown;
  carbs_grams?: unknown;
  fat_grams?: unknown;
  logged_at?: unknown;
};

function num(value: unknown): number {
  const parsed = typeof value === 'number' ? value : Number(value);
  return Number.isFinite(parsed) ? parsed : 0;
}

type MacroTotals = {
  calories: number;
  proteinGrams: number;
  carbsGrams: number;
  fatGrams: number;
};

function sumMacros(rows: MealRow[]): MacroTotals {
  return rows.reduce<MacroTotals>(
    (acc, row) => ({
      calories: acc.calories + num(row.calories),
      proteinGrams: acc.proteinGrams + num(row.protein_grams),
      carbsGrams: acc.carbsGrams + num(row.carbs_grams),
      fatGrams: acc.fatGrams + num(row.fat_grams),
    }),
    { calories: 0, proteinGrams: 0, carbsGrams: 0, fatGrams: 0 }
  );
}

/** Words a model tends to include that no exercise name ever contains. */
const SEARCH_STOPWORDS = new Set([
  'the', 'and', 'for', 'with', 'without', 'any', 'some', 'best', 'good', 'easy',
  'exercise', 'exercises', 'workout', 'workouts', 'routine', 'routines',
  'move', 'moves', 'movement', 'movements', 'equipment', 'home', 'gym',
]);

/** How many rows to rank before trimming to the caller's limit. */
const CANDIDATE_LIMIT = 200;

function searchTokens(query: string | undefined): string[] {
  return Array.from(
    new Set(
      (query || '')
        .toLowerCase()
        .split(/[^a-z0-9]+/)
        .filter((token) => token.length > 2 && !SEARCH_STOPWORDS.has(token))
    )
  );
}

export const celiaTools = {
  get_my_progress: tool({
    description:
      "The user's current activity: day streak, total workouts completed, how many routines they have saved, and whether they have already worked out or logged a meal today. Use this before giving encouragement or judging whether they are on track.",
    inputSchema: z.object({}),
    contextSchema: userContext,
    execute: async (_input, { context }) => {
      const supabase = getSupabaseAdmin();

      const [{ data: saved }, { data: meals }] = await Promise.all([
        supabase
          .from('user_routines')
          .select('times_completed,last_played_at')
          .eq('user_id', context.uid),
        supabase
          .from('user_meals')
          .select('logged_at')
          .eq('user_id', context.uid)
          .order('logged_at', { ascending: false })
          .limit(400),
      ]);

      const savedRows = saved || [];
      const mealRows = meals || [];

      // Mirrors collectActiveDays() in lib/utils/progress.dart: a day counts as
      // active if the user completed a workout OR logged a meal that day.
      const activeDays = new Set<string>();
      for (const row of savedRows) {
        const played = row.last_played_at;
        if (played) activeDays.add(localDayKey(String(played), context.tzOffsetMinutes));
      }
      for (const row of mealRows) {
        const logged = row.logged_at;
        if (logged) activeDays.add(localDayKey(String(logged), context.tzOffsetMinutes));
      }

      const todayKey = localDayKey(new Date().toISOString(), context.tzOffsetMinutes);
      let streak = 0;
      for (let dayOffset = 0; ; dayOffset += 1) {
        const key = localDayKey(
          startOfLocalDay(context.tzOffsetMinutes, dayOffset).toISOString(),
          context.tzOffsetMinutes
        );
        if (activeDays.has(key)) streak += 1;
        else break;
      }

      const workoutsCompleted = savedRows.reduce(
        (total, row) => total + num(row.times_completed),
        0
      );

      return {
        dayStreak: streak,
        workoutsCompleted,
        savedRoutines: savedRows.length,
        completedWorkoutToday: savedRows.some(
          (row) =>
            row.last_played_at &&
            localDayKey(String(row.last_played_at), context.tzOffsetMinutes) === todayKey
        ),
        loggedMealToday: mealRows.some(
          (row) =>
            row.logged_at &&
            localDayKey(String(row.logged_at), context.tzOffsetMinutes) === todayKey
        ),
      };
    },
  }),

  get_today_nutrition: tool({
    description:
      "What the user has eaten today: total calories and macros plus each meal. Use this before giving any advice about what they should eat next, or when they ask how much they have left.",
    inputSchema: z.object({}),
    contextSchema: userContext,
    execute: async (_input, { context }) => {
      const supabase = getSupabaseAdmin();
      const { data, error } = await supabase
        .from('user_meals')
        .select('title,calories,protein_grams,carbs_grams,fat_grams,logged_at')
        .eq('user_id', context.uid)
        .gte('logged_at', startOfLocalDay(context.tzOffsetMinutes).toISOString())
        .order('logged_at', { ascending: true });

      if (error) return { error: 'Could not read meals', details: error.message };

      const rows = (data || []) as MealRow[];
      const totals = sumMacros(rows);

      return {
        mealsLogged: rows.length,
        totals: {
          calories: round(totals.calories),
          proteinGrams: round(totals.proteinGrams),
          carbsGrams: round(totals.carbsGrams),
          fatGrams: round(totals.fatGrams),
        },
        meals: rows.map((row) => ({
          title: String(row.title || 'Meal'),
          calories: round(num(row.calories)),
          proteinGrams: round(num(row.protein_grams)),
          loggedAt: row.logged_at ? String(row.logged_at) : null,
        })),
      };
    },
  }),

  list_my_meals: tool({
    description:
      'The last few days of logged meals, grouped by day, for spotting eating patterns over time.',
    inputSchema: z.object({
      days: z.number().int().min(1).max(30).default(7),
    }),
    contextSchema: userContext,
    execute: async ({ days }, { context }) => {
      const supabase = getSupabaseAdmin();
      const { data, error } = await supabase
        .from('user_meals')
        .select('title,calories,protein_grams,carbs_grams,fat_grams,logged_at')
        .eq('user_id', context.uid)
        .gte('logged_at', startOfLocalDay(context.tzOffsetMinutes, days - 1).toISOString())
        .order('logged_at', { ascending: true });

      if (error) return { error: 'Could not read meals', details: error.message };

      const byDay = new Map<string, MealRow[]>();
      for (const row of (data || []) as MealRow[]) {
        if (!row.logged_at) continue;
        const key = localDayKey(String(row.logged_at), context.tzOffsetMinutes);
        const list = byDay.get(key) || [];
        list.push(row);
        byDay.set(key, list);
      }

      return {
        days: [...byDay.entries()].map(([date, rows]) => {
          const totals = sumMacros(rows);
          return {
            date,
            mealsLogged: rows.length,
            calories: round(totals.calories),
            proteinGrams: round(totals.proteinGrams),
            titles: rows.map((row) => String(row.title || 'Meal')),
          };
        }),
      };
    },
  }),

  list_my_routines: tool({
    description:
      "The routines saved in the user's library, including how many times they've completed each one. Use this before suggesting a workout, so you can recommend something they already have.",
    inputSchema: z.object({}),
    contextSchema: userContext,
    execute: async (_input, { context }) => {
      const supabase = getSupabaseAdmin();
      const { data, error } = await supabase
        .from('user_routines')
        .select(
          'routine_id,times_completed,last_played_at,is_favorite,' +
            'routines(id,title,description,duration_minutes,difficulty,category,steps)'
        )
        .eq('user_id', context.uid)
        .order('saved_at', { ascending: false })
        .limit(50);

      if (error) return { error: 'Could not read routines', details: error.message };

      // The embedded `routines(...)` select widens the row type, so name the
      // shape we actually asked for.
      type SavedRoutineRow = {
        routine_id: unknown;
        times_completed: unknown;
        last_played_at: unknown;
        is_favorite: unknown;
        routines?: Record<string, unknown> | null;
      };

      return {
        routines: ((data || []) as unknown as SavedRoutineRow[]).map((row) => {
          const routine = row.routines || {};
          const steps = Array.isArray(routine.steps) ? routine.steps : [];
          return {
            routineId: String(routine.id ?? row.routine_id),
            title: String(routine.title ?? 'Routine'),
            durationMinutes: num(routine.duration_minutes),
            difficulty: routine.difficulty ? String(routine.difficulty) : null,
            category: routine.category ? String(routine.category) : null,
            stepCount: steps.length,
            timesCompleted: num(row.times_completed),
            isFavorite: Boolean(row.is_favorite),
            lastPlayedAt: row.last_played_at ? String(row.last_played_at) : null,
          };
        }),
      };
    },
  }),

  get_routine_details: tool({
    description:
      'The full exercise-by-exercise breakdown of one routine. Use this when the user asks what a routine contains or wants to change it.',
    inputSchema: z.object({
      routineId: z.string().min(1),
    }),
    contextSchema: userContext,
    execute: async ({ routineId }, { context }) => {
      const supabase = getSupabaseAdmin();
      const { data, error } = await supabase
        .from('routines')
        .select('id,title,description,duration_minutes,difficulty,category,steps,created_by,is_published')
        .eq('id', routineId)
        .maybeSingle();

      if (error) return { error: 'Could not read routine', details: error.message };
      if (!data) return { error: 'Routine not found' };

      // Private routines belong to whoever generated them.
      if (!data.is_published && data.created_by && data.created_by !== context.uid) {
        return { error: 'Routine not found' };
      }

      const steps = Array.isArray(data.steps) ? data.steps : [];
      return {
        routineId: String(data.id),
        title: String(data.title || 'Routine'),
        description: data.description ? String(data.description) : null,
        durationMinutes: num(data.duration_minutes),
        difficulty: data.difficulty ? String(data.difficulty) : null,
        steps: steps.map((step) => {
          const s = step as Record<string, unknown>;
          return {
            order: num(s.order_index),
            title: String(s.title || 'Exercise'),
            description: s.description ? String(s.description) : null,
            durationSeconds: num(s.duration_seconds),
          };
        }),
      };
    },
  }),

  search_exercises: tool({
    description:
      "Search the app's exercise library. Use this to ground any exercise you recommend in something the app can actually show the user, and to check what is available for a muscle group before promising it.",
    inputSchema: z.object({
      query: z
        .string()
        .optional()
        .describe(
          'Free text matched word by word against exercise names, so a phrase like "shoulder press" works'
        ),
      muscleGroup: z
        .enum(['shoulders', 'chest', 'back_traps', 'core_abs', 'legs_glutes', 'calves'])
        .optional()
        .describe(
          'Narrows by muscle group, but about half the library has none recorded, so prefer `query` when you can'
        ),
      category: z
        .enum(['strength', 'calisthenics', 'functional_hiit', 'stretching_mobility'])
        .optional(),
      limit: z.number().int().min(1).max(40).default(15),
    }),
    contextSchema: userContext,
    execute: async ({ query, muscleGroup, category, limit }) => {
      const tokens = searchTokens(query);

      const run = async (withMuscleGroup: boolean) => {
        let builder = getSupabaseAdmin()
          .from('exercise_media')
          .select('slug,display_name,muscle_group,category');

        if (withMuscleGroup && muscleGroup) builder = builder.eq('muscle_group', muscleGroup);
        if (category) builder = builder.eq('category', category);
        // Any token is enough to be a candidate; ranking below sorts out how
        // good each hit is. Requiring every token would drop "shoulder
        // mobility", since no exercise name contains the word "mobility".
        if (tokens.length > 0) {
          builder = builder.or(tokens.map((t) => `display_name.ilike.%${t}%`).join(','));
        }

        return builder.limit(CANDIDATE_LIMIT);
      };

      let { data, error } = await run(true);
      if (error) return { error: 'Could not search exercises', details: error.message };

      // Roughly half the library has no muscle_group recorded, so a muscle
      // group filter alone can hide perfectly good matches. Fall back to the
      // text search rather than telling Celia nothing exists.
      if (muscleGroup && (data || []).length === 0) {
        ({ data, error } = await run(false));
        if (error) return { error: 'Could not search exercises', details: error.message };
      }

      const ranked = (data || [])
        .map((row) => {
          const name = String(row.display_name);
          const haystack = name.toLowerCase();
          const hits = tokens.filter((t) => haystack.includes(t)).length;
          return { row, name, hits };
        })
        // Most query words matched wins; shorter names break ties, which
        // favours "Shoulder press" over "Shoulder press machine seated".
        .sort((a, b) => b.hits - a.hits || a.name.length - b.name.length)
        .slice(0, limit);

      return {
        exercises: ranked.map(({ row, name }) => ({
          slug: String(row.slug),
          name,
          muscleGroup: row.muscle_group ? String(row.muscle_group) : null,
          category: row.category ? String(row.category) : null,
        })),
      };
    },
  }),

  create_routine: tool({
    description:
      "Save a playable workout routine to the user's library. You compose it yourself: look exercises up with search_exercises first, then list them here in the order the user should perform them. Every step must use an exact `exerciseSlug` from those results, because that slug is what the app plays. Only call this once the user has agreed to a specific plan.",
    inputSchema: z.object({
      title: z.string().min(3).max(80),
      description: z.string().max(300).optional(),
      difficulty: z.enum(['easy', 'medium', 'hard']).default('medium'),
      category: z
        .enum(['strength', 'cardio', 'flexibility', 'mindfulness', 'dance', 'hiit', 'yoga', 'custom'])
        .default('custom'),
      steps: z
        .array(
          z.object({
            exerciseSlug: z.string().describe('Exact slug from search_exercises'),
            title: z.string().optional().describe('Defaults to the exercise name'),
            coachingCue: z.string().max(200).optional().describe('One short line of form guidance'),
            durationSeconds: z.number().int().min(10).max(600).default(40),
          })
        )
        .min(2)
        .max(30),
      equipment: z.string().optional().describe('e.g. "None" or "Dumbbells, Mat"'),
      caloriesBurned: z.number().int().min(0).max(2000).optional(),
      tags: z.array(z.string()).max(6).default([]),
    }),
    contextSchema: userContext,
    execute: async (input, { context }) => {
      const supabase = getSupabaseAdmin();
      const slugs = Array.from(new Set(input.steps.map((s) => s.exerciseSlug)));

      const { data: known, error: lookupError } = await supabase
        .from('exercise_media')
        .select('slug,display_name')
        .in('slug', slugs);

      if (lookupError) {
        return { created: false, error: 'Could not verify the exercises', details: lookupError.message };
      }

      const nameBySlug = new Map(
        (known || []).map((row) => [String(row.slug), String(row.display_name)])
      );
      const unknown = slugs.filter((slug) => !nameBySlug.has(slug));
      if (unknown.length > 0) {
        // Handing back the bad slugs lets Celia search again and retry rather
        // than saving a routine with steps the app can't play.
        return {
          created: false,
          error: 'Some slugs are not in the exercise library',
          unknownSlugs: unknown,
        };
      }

      const steps = input.steps.map((step, index) => ({
        id: crypto.randomUUID(),
        title: step.title || nameBySlug.get(step.exerciseSlug) || 'Exercise',
        description: step.coachingCue || null,
        duration_seconds: step.durationSeconds,
        video_id: null,
        exercise_slug: step.exerciseSlug,
        // Left null on purpose: the app resolves the GIF from `exercise_slug`
        // at display time, so the URL isn't duplicated here.
        thumbnail_url: null,
        order_index: index,
      }));

      const totalSeconds = steps.reduce((sum, step) => sum + step.duration_seconds, 0);

      const { data: created, error: createError } = await supabase
        .from('routines')
        .insert({
          title: input.title,
          description: input.description || null,
          duration_minutes: Math.max(1, Math.round(totalSeconds / 60)),
          difficulty: input.difficulty,
          category: input.category,
          thumbnail_url: null,
          steps,
          created_by: context.uid,
          is_published: false,
          is_curated: false,
          tags: input.tags,
          calories_burned: input.caloriesBurned ?? null,
          equipment: input.equipment || null,
        })
        .select('id,title,duration_minutes')
        .single();

      if (createError) {
        return { created: false, error: 'Could not save the routine', details: createError.message };
      }

      // Straight into their library, so it survives an app restart.
      const { error: saveError } = await supabase.from('user_routines').insert({
        user_id: context.uid,
        routine_id: created.id,
        saved_at: new Date().toISOString(),
      });

      return {
        created: true,
        routineId: String(created.id),
        title: String(created.title),
        durationMinutes: num(created.duration_minutes),
        stepCount: steps.length,
        savedToLibrary: !saveError,
        exercises: steps.map((step) => step.title),
      };
    },
  }),

  log_meal: tool({
    description:
      "Record a meal against the user's daily nutrition. Use the user's own description and your best nutrition estimate for the macros. Only call this when they have said they ate something and want it tracked.",
    inputSchema: z.object({
      title: z.string().min(1),
      calories: z.number().min(0),
      proteinGrams: z.number().min(0).default(0),
      carbsGrams: z.number().min(0).default(0),
      fatGrams: z.number().min(0).default(0),
      items: z.array(z.string()).default([]),
    }),
    contextSchema: userContext,
    execute: async (input, { context }) => {
      const supabase = getSupabaseAdmin();
      const { data, error } = await supabase
        .from('user_meals')
        .insert({
          user_id: context.uid,
          title: input.title,
          calories: input.calories,
          protein_grams: input.proteinGrams,
          carbs_grams: input.carbsGrams,
          fat_grams: input.fatGrams,
          // Flags this row as a chat estimate rather than a photo scan, so the
          // app can show where the numbers came from.
          confidence: 0.6,
          provider: 'celia_chat',
          items: input.items.map((name) => ({ name })),
          warnings: [],
          logged_at: new Date().toISOString(),
        })
        .select('id')
        .single();

      if (error) return { logged: false, error: error.message };
      return { logged: true, mealId: String(data.id), title: input.title, calories: input.calories };
    },
  }),

  save_routine: tool({
    description:
      "Add an existing routine to the user's saved library so it appears on their home screen.",
    inputSchema: z.object({
      routineId: z.string().min(1),
    }),
    contextSchema: userContext,
    execute: async ({ routineId }, { context }) => {
      const supabase = getSupabaseAdmin();

      const { data: existing } = await supabase
        .from('user_routines')
        .select('id')
        .eq('user_id', context.uid)
        .eq('routine_id', routineId)
        .maybeSingle();

      if (existing) return { saved: true, alreadySaved: true };

      const { error } = await supabase.from('user_routines').insert({
        user_id: context.uid,
        routine_id: routineId,
        saved_at: new Date().toISOString(),
      });

      if (error) return { saved: false, error: error.message };
      return { saved: true, alreadySaved: false };
    },
  }),
};

/** Tools that change the user's data, and so need explicit confirmation. */
export const WRITE_TOOLS = ['create_routine', 'log_meal', 'save_routine'] as const;

export type CeliaToolContext = { uid: string; tzOffsetMinutes: number };

/**
 * Every tool takes the same context, but `toolsContext` is keyed by tool name.
 * Listing them explicitly rather than generating the map keeps this
 * compiler-checked: adding a tool without wiring its context fails the build.
 */
export function celiaToolsContext(context: CeliaToolContext) {
  return {
    get_my_progress: context,
    get_today_nutrition: context,
    list_my_meals: context,
    list_my_routines: context,
    get_routine_details: context,
    search_exercises: context,
    create_routine: context,
    log_meal: context,
    save_routine: context,
  };
}
