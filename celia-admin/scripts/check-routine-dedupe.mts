/**
 * Checks the routine matcher against the live catalogue.
 *
 * The generate endpoint spends most of its minute inside DeepSeek, so driving
 * this through HTTP is slow and at the mercy of the model returning the same
 * sequence twice. This exercises the same module both creation paths call, with
 * step lists taken from routines that actually exist.
 *
 * Run: npx tsx scripts/check-routine-dedupe.mts
 * Needs NEXT_PUBLIC_SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY.
 * Set ROUTINE_ID to test against a particular routine, e.g. a private one.
 */
import { findMatchingRoutine, routineFingerprint } from '../src/lib/routineDedupe';
import { getSupabaseAdmin } from '../src/lib/supabaseAdmin';

type Step = { exercise_slug?: string | null; video_id?: string | null; title?: string; duration_seconds?: number };

let failures = 0;

function check(name: string, passed: boolean, detail = '') {
  console.log(`${passed ? 'ok  ' : 'FAIL'}  ${name}${detail ? ` — ${detail}` : ''}`);
  if (!passed) failures += 1;
}

const supabase = getSupabaseAdmin();

const { data: rows, error } = await supabase
  .from('routines')
  .select('id,title,steps,created_by,is_published')
  .not('created_by', 'is', null)
  .limit(50);

if (error) throw new Error(`could not load routines: ${error.message}`);

const wantedId = process.env.ROUTINE_ID;
const owned = (rows || []).find((row) =>
  wantedId
    ? row.id === wantedId
    : row.created_by !== 'admin' && routineFingerprint(row.steps) !== ''
);

if (!owned) throw new Error('no user-owned routine with identifiable steps to test against');

const uid = String(owned.created_by);
const steps = owned.steps as Step[];
console.log(`using "${owned.title}" (${owned.id}), owner ${uid}, ${steps.length} steps\n`);

const same = await findMatchingRoutine(uid, steps);
check('the exact sequence finds the original', same?.id === owned.id, same ? same.id : 'no match');

const retimed = steps.map((step, i) => ({
  ...step,
  title: `Renamed ${i}`,
  duration_seconds: (step.duration_seconds ?? 40) + 15,
}));
const retimedMatch = await findMatchingRoutine(uid, retimed);
check(
  'different titles and timings still match',
  retimedMatch?.id === owned.id,
  retimedMatch ? retimedMatch.id : 'no match'
);

if (steps.length > 1) {
  const reordered = [...steps].reverse();
  const reorderedMatch = await findMatchingRoutine(uid, reordered);
  const isSameForwardsAndBackwards =
    routineFingerprint(reordered) === routineFingerprint(steps);
  check(
    'a different order is a different routine',
    isSameForwardsAndBackwards || reorderedMatch?.id !== owned.id,
    reorderedMatch ? `matched ${reorderedMatch.id}` : 'no match'
  );
}

const dropped = steps.slice(0, steps.length - 1);
const droppedMatch = await findMatchingRoutine(uid, dropped);
check(
  'dropping an exercise is a different routine',
  droppedMatch?.id !== owned.id,
  droppedMatch ? `matched ${droppedMatch.id}` : 'no match'
);

const strangerMatch = await findMatchingRoutine('someone-else-entirely', steps);
check(
  owned.is_published
    ? "a stranger is sent to it too, because it's published"
    : "a stranger is not sent to someone else's private routine",
  owned.is_published ? strangerMatch?.id === owned.id : strangerMatch === null,
  strangerMatch ? `matched ${strangerMatch.id}` : 'no match'
);

const unidentifiable = await findMatchingRoutine(uid, [{ exercise_slug: null, video_id: null }]);
check('steps with nothing to identify them never match', unidentifiable === null);

console.log(`\n${failures === 0 ? 'all checks passed' : `${failures} check(s) failed`}`);
process.exit(failures === 0 ? 0 : 1);
