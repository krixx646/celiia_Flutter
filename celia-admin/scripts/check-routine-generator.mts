/**
 * Checks that the generator builds routines the guided player can coach.
 *
 * Driving this through HTTP needs a live Firebase token and spends a minute
 * inside DeepSeek per attempt, so this calls the same module both creation
 * paths use and asserts on what comes back: every step filmed, every step
 * carrying a prescription, and nothing needing equipment the user said they
 * do not have.
 *
 * Run: npx tsx --env-file=.env.local scripts/check-routine-generator.mts
 * Writes routines under a throwaway uid and deletes them afterwards.
 *
 * Pass --stub to answer the model call locally instead of paying for it. The
 * stub replies out of the catalog the generator actually assembled, and
 * answers badly on purpose — leaving prescriptions off, and asking for reps on
 * an exercise that can only be held — so the checks below prove the generator
 * repairs a sloppy answer rather than trusting it.
 */
import { Agent, setGlobalDispatcher } from 'undici';
import { generateRoutine } from '../src/lib/routineGenerator';
import { getSupabaseAdmin } from '../src/lib/supabaseAdmin';

// Node's fetch gives up on a connection after 10s, and reaching DeepSeek from
// a dev machine outside their region can take longer than that. Vercel has no
// such trouble, so this is a local-only allowance, not a production setting.
setGlobalDispatcher(new Agent({ connect: { timeout: 60_000 } }));

type Step = {
  title?: string;
  exercise_slug?: string | null;
  video_id?: string | null;
  sets?: number;
  reps?: number | null;
  rest_seconds?: number;
  duration_seconds?: number;
};

const uid = `generator-check-${Date.now()}`;
const supabase = getSupabaseAdmin();
const stub = process.argv.includes('--stub');

type PromptEntry = { refType: string; refId: string; name: string; stepType?: string };

if (stub) {
  const realFetch = globalThis.fetch;
  globalThis.fetch = (async (input: RequestInfo | URL, init?: RequestInit) => {
    const url = String(input instanceof Request ? input.url : input);
    if (!url.includes('deepseek')) return realFetch(input as never, init);

    const body = JSON.parse(String(init?.body ?? '{}'));
    const userPrompt = JSON.parse(body.messages.at(-1).content);
    const catalog = userPrompt.catalog as PromptEntry[];

    // Deliberately mixed: without a held exercise in here, the check that a
    // plank never gets prescribed in reps would pass without testing anything.
    const holds = catalog.filter((entry) => entry.stepType === 'hold');
    const counted = catalog.filter((entry) => entry.stepType !== 'hold');
    const picked = [...counted.slice(0, 3), ...holds.slice(0, 3)];

    const steps = picked.map((entry, index) => ({
      title: entry.name,
      description: 'Keep it controlled.',
      refType: entry.refType,
      refId: entry.refId,
      orderIndex: index,
      // Every third step is left bare, to prove the library's own defaults
      // fill the gap rather than the step reaching the player unprescribed.
      ...(index % 3 === 0
        ? {}
        : { sets: 3, reps: 10, durationSeconds: 40, restSeconds: 45 }),
    }));

    return new Response(
      JSON.stringify({
        choices: [
          {
            finish_reason: 'stop',
            message: {
              content: JSON.stringify({
                title: 'Stubbed Routine',
                description: 'Built without calling the model.',
                category: 'strength',
                steps,
                tags: [],
                caloriesBurned: 150,
                equipment: 'None',
              }),
            },
          },
        ],
        usage: { total_tokens: 0 },
      }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    );
  }) as typeof fetch;
}

let failures = 0;

function check(name: string, passed: boolean, detail = '') {
  console.log(`${passed ? 'ok  ' : 'FAIL'}  ${name}${detail ? ` — ${detail}` : ''}`);
  if (!passed) failures += 1;
}

const { data: clipRows } = await supabase
  .from('exercise_clips')
  .select('slug,equipment,step_type')
  .eq('is_active', true);

const clips = new Map(
  (clipRows || []).map((row) => [
    String(row.slug),
    {
      equipment: (Array.isArray(row.equipment) ? row.equipment : []).map(String),
      counted: row.step_type !== 'hold',
    },
  ])
);

console.log(`clip library: ${clips.size} exercises\n`);

const cases = [
  {
    name: 'home workout, no equipment',
    request: 'A full body workout I can do at home with nothing',
    equipment: ['None'],
    bodyweightOnly: true,
  },
  {
    name: 'dumbbell strength',
    request: 'Upper body strength with dumbbells',
    equipment: ['Dumbbells'],
    bodyweightOnly: false,
  },
  {
    name: 'mobility and stretching',
    request: 'A gentle stretching and mobility session for my back',
    equipment: ['None'],
    bodyweightOnly: true,
  },
];

for (const testCase of cases) {
  console.log(`--- ${testCase.name}`);

  const result = await generateRoutine({
    uid,
    request: testCase.request,
    durationMinutes: 20,
    difficulty: 'medium',
    equipment: testCase.equipment,
  });

  if (!result.ok) {
    check(testCase.name, false, `${result.error} ${JSON.stringify(result.details ?? '')}`);
    continue;
  }

  const steps = (result.routine.steps || []) as Step[];
  check(`${testCase.name}: built steps`, steps.length > 0, `${steps.length} steps`);

  const unfilmed = steps.filter((s) => !s.exercise_slug || !clips.has(s.exercise_slug));
  check(
    `${testCase.name}: every step is a filmed clip`,
    unfilmed.length === 0,
    unfilmed.map((s) => s.title).join(', ')
  );

  const unprescribed = steps.filter(
    (s) => !s.sets || (!(s.reps && s.reps > 0) && !(s.duration_seconds && s.duration_seconds > 0))
  );
  check(
    `${testCase.name}: every step has sets and either reps or a hold`,
    unprescribed.length === 0,
    unprescribed.map((s) => s.title).join(', ')
  );

  const misprescribed = steps.filter((s) => {
    const clip = s.exercise_slug ? clips.get(s.exercise_slug) : undefined;
    if (!clip) return false;
    return clip.counted !== Boolean(s.reps && s.reps > 0);
  });
  check(
    `${testCase.name}: counted exercises got reps, holds got time`,
    misprescribed.length === 0,
    misprescribed.map((s) => s.title).join(', ')
  );

  if (testCase.bodyweightOnly) {
    const needsKit = steps.filter((s) => {
      const clip = s.exercise_slug ? clips.get(s.exercise_slug) : undefined;
      return clip?.equipment.some((item) => item === 'dumbbell' || item === 'band');
    });
    check(
      `${testCase.name}: nothing needs equipment the user does not have`,
      needsKit.length === 0,
      needsKit.map((s) => s.title).join(', ')
    );
  }

  const sample = steps
    .slice(0, 4)
    .map((s) =>
      s.reps && s.reps > 0
        ? `${s.title} ${s.sets}x${s.reps}, rest ${s.rest_seconds}s`
        : `${s.title} ${s.sets}x${s.duration_seconds}s hold, rest ${s.rest_seconds}s`
    );
  console.log(`      ${result.routine.title}`);
  for (const line of sample) console.log(`        ${line}`);
  console.log('');
}

await supabase.from('routines').delete().eq('created_by', uid);
console.log(failures === 0 ? '\nall checks passed' : `\n${failures} check(s) failed`);
process.exit(failures === 0 ? 0 : 1);
