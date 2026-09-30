/**
 * Equipment demonstration clips. They live in `exercise_clips` so the app can
 * show them in the "How to" section, but they are form guides played once from
 * start to finish, so no workout may ever be built from them.
 */
export const HOW_TO_CLIP_SOURCE = 'premium_equipment_v1';

/**
 * Kit every home has anyway. Workouts are bodyweight sessions, so a workout
 * exercise may need nothing beyond these.
 */
export const HOUSEHOLD_EQUIPMENT = new Set(['wall', 'chair', 'bench', 'box']);

export function isWorkoutFriendlyEquipment(equipment: string[]): boolean {
  return equipment.every((tag) => HOUSEHOLD_EQUIPMENT.has(tag.toLowerCase()));
}
