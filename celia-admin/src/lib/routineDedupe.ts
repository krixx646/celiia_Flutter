import { getSupabaseAdmin } from '@/lib/supabaseAdmin';

/** The only parts of a step that decide whether two routines are the same workout. */
export type FingerprintStep = {
  exercise_slug?: string | null;
  video_id?: string | null;
};

export type MatchingRoutine = {
  id: string;
  title: string;
  /** The whole row, so a caller can hand it back to the app unchanged. */
  row: Record<string, unknown>;
};

/**
 * What makes two routines the same workout: the same exercises, in the same
 * order. Titles, coaching cues and per-step seconds are deliberately excluded —
 * two generations of one request differ in those constantly while being the
 * same session to perform.
 *
 * Returns '' for anything that cannot be compared safely, which callers treat
 * as "no match" rather than risking a false one.
 */
export function routineFingerprint(steps: unknown): string {
  if (!Array.isArray(steps) || steps.length === 0) return '';

  const parts = steps.map((step) => {
    const { exercise_slug: slug, video_id: video } = (step ?? {}) as FingerprintStep;
    if (typeof slug === 'string' && slug.trim()) return slug.trim();
    if (typeof video === 'string' && video.trim()) return `video:${video.trim()}`;
    return '';
  });

  // An unidentifiable step would make two different routines look alike.
  if (parts.some((part) => part === '')) return '';
  return parts.join('>');
}

// The whole table is in the low tens of rows, so these caps only exist to keep
// the query bounded if the library grows.
const OWN_LIMIT = 200;
const LIBRARY_LIMIT = 200;

/**
 * The routine a user should be sent to instead of storing another copy of the
 * same sequence, or null when the sequence really is new to them.
 *
 * Their own routines are checked before the shared library, and older rows
 * before newer ones, so a repeated request always lands on the original rather
 * than on some later copy of it.
 */
export async function findMatchingRoutine(
  uid: string,
  steps: readonly FingerprintStep[]
): Promise<MatchingRoutine | null> {
  const wanted = routineFingerprint(steps);
  if (!wanted) return null;

  const supabase = getSupabaseAdmin();

  const own = await supabase
    .from('routines')
    .select('*')
    .eq('created_by', uid)
    .order('created_at', { ascending: true })
    .limit(OWN_LIMIT);

  const mine = firstMatch(own.data, wanted);
  if (mine) return mine;

  // Nothing of theirs matches, so try the shared library: if this sequence is
  // already published, that routine is the original worth pointing at.
  const library = await supabase
    .from('routines')
    .select('*')
    .eq('is_published', true)
    .order('created_at', { ascending: true })
    .limit(LIBRARY_LIMIT);

  return firstMatch(library.data, wanted);
}

function firstMatch(rows: unknown, wanted: string): MatchingRoutine | null {
  if (!Array.isArray(rows)) return null;

  for (const row of rows as Record<string, unknown>[]) {
    if (routineFingerprint(row.steps) !== wanted) continue;
    const id = row.id;
    if (typeof id !== 'string' || !id) continue;
    return {
      id,
      title: typeof row.title === 'string' && row.title ? row.title : 'Your routine',
      row,
    };
  }

  return null;
}

/**
 * Adds a routine to the user's library unless it is already there, so pointing
 * someone at an existing routine still leaves it somewhere they can find it.
 */
export async function ensureSavedToLibrary(uid: string, routineId: string): Promise<boolean> {
  const supabase = getSupabaseAdmin();

  const { data, error } = await supabase
    .from('user_routines')
    .select('id')
    .eq('user_id', uid)
    .eq('routine_id', routineId)
    .limit(1);

  if (error) return false;
  if (Array.isArray(data) && data.length > 0) return true;

  const { error: insertError } = await supabase.from('user_routines').insert({
    user_id: uid,
    routine_id: routineId,
    saved_at: new Date().toISOString(),
  });

  return !insertError;
}
