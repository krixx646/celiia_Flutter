import { getSupabaseAdmin } from '@/lib/supabaseAdmin';
import type { OnboardingFacts } from '@/lib/celiaAgent/agent';

/**
 * The columns worth spending prompt tokens on. Selected explicitly so adding a
 * column to `user_profiles` does not silently start leaking into the prompt.
 */
const COLUMNS = [
  'primary_goal',
  'diet_pattern',
  'dietary_conditions',
  'food_allergies',
  'disordered_eating_history',
  'nutrition_mode',
  'daily_water_ml',
  'training_location',
  'uses_equipment',
  'available_equipment',
  'injuries',
  'medical_conditions',
  'fitness_goal',
  'desired_outcomes',
  'training_intensity',
  'experience_level',
  'planning_mode',
  'minutes_per_day',
  'preferred_training_time',
  'current_mood',
  'coaching_focus',
].join(', ');

type Row = Record<string, unknown>;

/**
 * Loads the caller's onboarding answers for the agent prompt.
 *
 * Read here rather than accepted from the request because allergies and
 * injuries are safety constraints: the client should not be able to change
 * them by editing a request body. Returns null when the user has not onboarded
 * or the read fails, which the prompt builder treats as "no extra context"
 * rather than an error — a chat turn should not fail over a missing profile.
 */
export async function loadOnboardingFacts(
  uid: string
): Promise<OnboardingFacts | null> {
  let row: Row | null = null;
  try {
    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from('user_profiles')
      .select(COLUMNS)
      .eq('user_id', uid)
      .maybeSingle();
    if (error || !data) return null;
    row = data as unknown as Row;
  } catch {
    return null;
  }

  return {
    primaryGoal: str(row.primary_goal),
    dietPattern: str(row.diet_pattern),
    dietaryConditions: strList(row.dietary_conditions),
    foodAllergies: strList(row.food_allergies),
    disorderedEatingHistory: row.disordered_eating_history === true,
    nutritionMode: str(row.nutrition_mode),
    dailyWaterMl: num(row.daily_water_ml),
    trainingLocation: str(row.training_location),
    usesEquipment:
      typeof row.uses_equipment === 'boolean' ? row.uses_equipment : null,
    // Empty array is a real answer (bodyweight). Distinguish from "column missing".
    availableEquipment: Array.isArray(row.available_equipment)
      ? (row.available_equipment as unknown[]).filter(
          (entry): entry is string => typeof entry === 'string'
        )
      : null,
    injuries: strList(row.injuries),
    medicalConditions: strList(row.medical_conditions),
    fitnessGoal: str(row.fitness_goal),
    desiredOutcomes: strList(row.desired_outcomes),
    trainingIntensity: str(row.training_intensity),
    experienceLevel: str(row.experience_level),
    planningMode: str(row.planning_mode),
    minutesPerDay: num(row.minutes_per_day),
    preferredTrainingTime: str(row.preferred_training_time),
    currentMood: str(row.current_mood),
    coachingFocus: str(row.coaching_focus),
  };
}

function str(value: unknown): string | null {
  return typeof value === 'string' && value.trim() ? value.trim() : null;
}

function num(value: unknown): number | null {
  return typeof value === 'number' && Number.isFinite(value) ? value : null;
}

function strList(value: unknown): string[] | null {
  if (!Array.isArray(value)) return null;
  const items = value.filter((entry): entry is string => typeof entry === 'string');
  return items.length ? items : null;
}
