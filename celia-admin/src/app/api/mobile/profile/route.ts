import { NextRequest, NextResponse } from 'next/server';
import { verifyFirebaseUser } from '@/lib/firebaseAuth';
import { getSupabaseAdmin } from '@/lib/supabaseAdmin';

export const runtime = 'nodejs';
export const maxDuration = 30;

/**
 * The onboarding profile.
 *
 * PUT is a partial update: the app saves after each step, so a user who
 * abandons onboarding halfway keeps the answers they already gave and resumes
 * where they stopped. Only keys present in the body are written.
 */

const TABLE = 'user_profiles';

const SEX = ['male', 'female', 'other'] as const;
const PRIMARY_GOAL = ['lose_weight', 'gain_weight', 'build_muscle'] as const;
const DIET_PATTERN = ['omnivore', 'vegetarian', 'vegan', 'pescatarian'] as const;
const MODE = ['automatic', 'manual'] as const;
const TRAINING_LOCATION = ['home', 'gym', 'both'] as const;
const FITNESS_GOAL = ['lose_fat', 'strength', 'tone', 'health', 'tactical', 'custom'] as const;
const INTENSITY = ['easy', 'moderate', 'intense'] as const;
const EXPERIENCE = ['beginner', 'regular'] as const;
const WEARABLE = ['google_fit', 'health_connect', 'apple_health', 'fitbit', 'garmin'] as const;

/** Free-text answers are capped so a malformed client cannot write an essay. */
const MAX_TEXT = 400;
const MAX_LIST_ITEMS = 40;

function enumValue<T extends readonly string[]>(value: unknown, allowed: T): T[number] | null {
  return typeof value === 'string' && (allowed as readonly string[]).includes(value)
    ? (value as T[number])
    : null;
}

function intInRange(value: unknown, min: number, max: number): number | null {
  const n = typeof value === 'number' ? value : Number(value);
  if (!Number.isFinite(n)) return null;
  const rounded = Math.round(n);
  return rounded < min || rounded > max ? null : rounded;
}

function numberInRange(value: unknown, min: number, max: number): number | null {
  const n = typeof value === 'number' ? value : Number(value);
  if (!Number.isFinite(n)) return null;
  return n < min || n > max ? null : n;
}

function text(value: unknown): string | null {
  if (typeof value !== 'string') return null;
  const trimmed = value.trim();
  return trimmed ? trimmed.slice(0, MAX_TEXT) : null;
}

/** Free-text lists (allergies, injuries) are normalised but not vocabulary-checked. */
function textList(value: unknown): string[] | null {
  if (!Array.isArray(value)) return null;
  const items = value
    .map((entry) => (typeof entry === 'string' ? entry.trim().slice(0, MAX_TEXT) : ''))
    .filter((entry) => entry.length > 0);
  return Array.from(new Set(items)).slice(0, MAX_LIST_ITEMS);
}

const EQUIPMENT_TAGS = [
  'dumbbell',
  'barbell',
  'kettlebell',
  'band',
  'cable',
  'machine',
  'smith',
  'pull_up_bar',
  'jump_rope',
  'mat',
] as const;

/**
 * Equipment preference. An empty array is a valid answer (bodyweight only),
 * so it must not be treated as "no value" the way other list fields are.
 */
function equipmentList(value: unknown): string[] | null {
  if (!Array.isArray(value)) return null;
  const allowed = new Set<string>(EQUIPMENT_TAGS);
  const items = value
    .map((entry) => (typeof entry === 'string' ? entry.trim().toLowerCase() : ''))
    .filter((entry) => allowed.has(entry));
  return Array.from(new Set(items)).slice(0, MAX_LIST_ITEMS);
}

function timeOfDay(value: unknown): string | null {
  return typeof value === 'string' && /^([01]\d|2[0-3]):[0-5]\d$/.test(value) ? value : null;
}

function isoTimestamp(value: unknown): string | null {
  if (typeof value !== 'string') return null;
  const parsed = Date.parse(value);
  return Number.isNaN(parsed) ? null : new Date(parsed).toISOString();
}

function boolean(value: unknown): boolean | null {
  return typeof value === 'boolean' ? value : null;
}

/** Notification toggles: a flat map of name -> on/off, so new types need no migration. */
function notificationPrefs(value: unknown): Record<string, boolean> | null {
  if (!value || typeof value !== 'object' || Array.isArray(value)) return null;
  const prefs: Record<string, boolean> = {};
  for (const [key, on] of Object.entries(value as Record<string, unknown>)) {
    if (typeof on === 'boolean') prefs[key.slice(0, 64)] = on;
  }
  return prefs;
}

/**
 * Request key -> column, with the parser that decides whether a value is
 * acceptable. A parser returning null means "not a usable value", and the key
 * is skipped rather than writing junk over a good answer.
 */
const FIELDS: Record<string, { column: string; parse: (value: unknown) => unknown }> = {
  termsAcceptedAt: { column: 'terms_accepted_at', parse: isoTimestamp },
  termsVersion: { column: 'terms_version', parse: text },

  sex: { column: 'sex', parse: (v) => enumValue(v, SEX) },
  age: { column: 'age', parse: (v) => intInRange(v, 13, 100) },
  weightKg: { column: 'weight_kg', parse: (v) => numberInRange(v, 25, 400) },
  heightCm: { column: 'height_cm', parse: (v) => numberInRange(v, 90, 250) },
  bmrKcal: { column: 'bmr_kcal', parse: (v) => numberInRange(v, 500, 6000) },

  primaryGoal: { column: 'primary_goal', parse: (v) => enumValue(v, PRIMARY_GOAL) },

  dietPattern: { column: 'diet_pattern', parse: (v) => enumValue(v, DIET_PATTERN) },
  dietaryConditions: { column: 'dietary_conditions', parse: textList },
  foodAllergies: { column: 'food_allergies', parse: textList },
  disorderedEatingHistory: { column: 'disordered_eating_history', parse: boolean },
  nutritionMode: { column: 'nutrition_mode', parse: (v) => enumValue(v, MODE) },
  dailyWaterMl: { column: 'daily_water_ml', parse: (v) => intInRange(v, 500, 8000) },

  dailyCalories: { column: 'daily_calories', parse: (v) => numberInRange(v, 800, 8000) },
  dailyProteinGrams: { column: 'daily_protein_grams', parse: (v) => numberInRange(v, 0, 500) },
  dailyCarbsGrams: { column: 'daily_carbs_grams', parse: (v) => numberInRange(v, 0, 1000) },
  dailyFatGrams: { column: 'daily_fat_grams', parse: (v) => numberInRange(v, 0, 500) },

  trainingLocation: { column: 'training_location', parse: (v) => enumValue(v, TRAINING_LOCATION) },
  usesEquipment: { column: 'uses_equipment', parse: boolean },
  availableEquipment: { column: 'available_equipment', parse: equipmentList },
  injuries: { column: 'injuries', parse: textList },
  medicalConditions: { column: 'medical_conditions', parse: textList },
  fitnessGoal: { column: 'fitness_goal', parse: (v) => enumValue(v, FITNESS_GOAL) },
  desiredOutcomes: { column: 'desired_outcomes', parse: textList },
  trainingIntensity: { column: 'training_intensity', parse: (v) => enumValue(v, INTENSITY) },
  experienceLevel: { column: 'experience_level', parse: (v) => enumValue(v, EXPERIENCE) },
  planningMode: { column: 'planning_mode', parse: (v) => enumValue(v, MODE) },
  minutesPerDay: { column: 'minutes_per_day', parse: (v) => intInRange(v, 5, 300) },
  preferredTrainingTime: { column: 'preferred_training_time', parse: timeOfDay },

  currentMood: { column: 'current_mood', parse: text },
  coachingFocus: { column: 'coaching_focus', parse: text },

  notificationPrefs: { column: 'notification_prefs', parse: notificationPrefs },
  wearableProvider: { column: 'wearable_provider', parse: (v) => enumValue(v, WEARABLE) },

  onboardingVersion: { column: 'onboarding_version', parse: (v) => intInRange(v, 0, 1000) },
  onboardingCompletedAt: { column: 'onboarding_completed_at', parse: isoTimestamp },
};

/** Inverse of FIELDS, for shaping a row back into the app's camelCase. */
const COLUMN_TO_KEY = Object.fromEntries(
  Object.entries(FIELDS).map(([key, field]) => [field.column, key])
);

function toApiShape(row: Record<string, unknown>) {
  const profile: Record<string, unknown> = {};
  for (const [column, value] of Object.entries(row)) {
    const key = COLUMN_TO_KEY[column];
    if (key && value !== null && value !== undefined) profile[key] = value;
  }
  return profile;
}

export async function GET(req: NextRequest) {
  const user = await verifyFirebaseUser(req);
  if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  let supabase: ReturnType<typeof getSupabaseAdmin>;
  try {
    supabase = getSupabaseAdmin();
  } catch (e) {
    return NextResponse.json(
      { error: 'Supabase service is not configured', details: e instanceof Error ? e.message : String(e) },
      { status: 500 }
    );
  }

  const { data, error } = await supabase
    .from(TABLE)
    .select('*')
    .eq('user_id', user.uid)
    .maybeSingle();

  if (error) {
    return NextResponse.json(
      { error: 'Failed to load profile', details: error.message },
      { status: 500 }
    );
  }

  // A user who has never onboarded has no row yet. That is not an error: the
  // app reads null as "start at step one".
  return NextResponse.json({ profile: data ? toApiShape(data) : null });
}

export async function PUT(req: NextRequest) {
  const user = await verifyFirebaseUser(req);
  if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  let supabase: ReturnType<typeof getSupabaseAdmin>;
  try {
    supabase = getSupabaseAdmin();
  } catch (e) {
    return NextResponse.json(
      { error: 'Supabase service is not configured', details: e instanceof Error ? e.message : String(e) },
      { status: 500 }
    );
  }

  const body = (await req.json().catch(() => null)) as Record<string, unknown> | null;
  if (!body) return NextResponse.json({ error: 'Malformed request body' }, { status: 400 });

  const update: Record<string, unknown> = {};
  const rejected: string[] = [];
  for (const [key, field] of Object.entries(FIELDS)) {
    if (!(key in body)) continue;
    const parsed = field.parse(body[key]);
    if (parsed === null) {
      rejected.push(key);
      continue;
    }
    update[field.column] = parsed;
  }

  if (Object.keys(update).length === 0) {
    return NextResponse.json(
      { error: 'No valid profile fields to save', rejected },
      { status: 400 }
    );
  }

  const { data, error } = await supabase
    .from(TABLE)
    .upsert(
      { user_id: user.uid, ...update, updated_at: new Date().toISOString() },
      { onConflict: 'user_id' }
    )
    .select()
    .single();

  if (error) {
    return NextResponse.json(
      { error: 'Failed to save profile', details: error.message },
      { status: 500 }
    );
  }

  // `rejected` is returned rather than failing the whole save: one bad field
  // should not lose the rest of a step, but the client can still log it.
  return NextResponse.json({ profile: toApiShape(data), rejected });
}
