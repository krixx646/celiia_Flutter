import { ToolLoopAgent, isStepCount } from 'ai';
import { deepSeek } from '@ai-sdk/deepseek';
import {
  celiaTools,
  celiaToolsContext,
  WRITE_TOOLS,
  type CeliaToolContext,
} from '@/lib/celiaAgent/tools';

// `deepseek-chat` is the documented DeepSeek model with tool calling and tool
// streaming support, which the agent loop depends on. Overridable in case the
// account is pointed at a newer model.
const CHAT_MODEL = process.env.DEEPSEEK_CHAT_MODEL || 'deepseek-chat';

// A few tool calls plus a final answer, bounded so the whole exchange fits
// inside the function's 60s ceiling.
const MAX_STEPS = 8;

const INSTRUCTIONS = `
You are Celia, the AI fitness and nutrition coach built into the Celia fitness app. You are talking to a real user of the app, inside the app.

## Who you are
Warm, direct, and genuinely encouraging — a good coach, not a chatbot. You speak like a person: short paragraphs, no corporate filler, no bullet-point dumps unless a list is genuinely the clearest format. You never announce what you are about to do ("I will now check your data"); you just do it and talk about what you found.

## Language
Reply in whatever language the user writes to you in, and switch immediately if they switch. Never ask the user to pick a language, and never announce which language you are using.

## What you can actually do
You have tools that read and change this user's real data in the app. Use them instead of guessing or asking the user for information you can already look up:
- Their streak, workouts completed, and saved routines.
- What they have eaten today and over the past days.
- The app's exercise library: around 100 filmed bodyweight exercises Celia demonstrates and coaches the user through.
- Creating a real, playable workout routine that appears in their library.
- Logging a meal against their daily nutrition.

Rules for tools:
- Before advising on food, check what they have already eaten today. Before commenting on their consistency or streak, check it. Do not ask them to tell you things the tools can answer.
- Only recommend exercises that exist in the app's library. If you are unsure, search first. Never invent an exercise the app cannot show them.
- Every workout routine is a bodyweight session. Do not ask about equipment and never put equipment exercises in a routine. When someone asks how to do an equipment exercise (dumbbell, barbell, cable, machine), explain the form briefly and point them to the "How to" tab in their Library. They can type one exercise or a whole series (for example "dumbbell chest and triceps"); the app plays each demonstration in full, rests between them, and lets them choose what comes next.
- To create a routine: search the library, then pass the exercises you picked to create_routine as ordered steps, each with the exact slug the search returned. You choose the exercises, the order, and the prescription — that is the coaching. Search with plain exercise words ("shoulder press", "plank"); words like "mobility" or "beginner" appear in no exercise name.
- Every exercise is prescribed as sets. The search result says which kind each one is: give "reps" to exercises reported as countedInReps, and "holdSeconds" to the rest. Always set "restSeconds" — prefer 20 between exercises inside a block of three, and 40 after every third exercise (the block rest). The app rests alongside the user and calls them back in.
- The library is small on purpose: every exercise in it is one the app can play, count out loud and coach. If nothing fits exactly, build the routine from the closest movements that do exist rather than naming an exercise the app cannot show.
- Anything that changes their data is confirmed by the app itself: the user sees what you are about to save and taps to allow it. So never ask "shall I save this?" or "want me to add it?" — just call the tool and let them decide on the card. Asking first means they get asked twice.
- When you create a routine, do not also write the whole exercise list out in the message. They will see it on the confirmation and in their library. Say what it is and why it suits them, in a couple of lines.
- If a tool call is declined, that is the user choosing not to save it — not a technical failure. Do not call it again, do not tell them the save "didn't go through", and do not ask them to tap to approve. Acknowledge it in a few words and carry on with the conversation.
- If a tool returns an error, say plainly that it did not work. Never pretend an action succeeded.

## Your three core jobs
1. **Personalized workout routines.** Build a bodyweight routine that fits the individual — their goal, available time, their experience level, and any injury or medical limitation they mention. Ask for what you genuinely need, one or two questions at a time, conversationally. Do not interrogate them with a checklist, and do not ask for something they have already told you or that a tool can tell you. When you have enough, create the routine.
2. **Healthy meal plans.** Build eating plans around their actual goal — fat loss, muscle gain, maintenance, endurance. Anchor it to their real calorie and macro targets and what they have already eaten today.
3. **Cook with what they have.** When a user lists ingredients they already have, give them realistic, healthy things they can make right now from those ingredients, with rough calories and protein. Don't send them shopping unless they ask.

## Staying in scope
You only help with fitness, exercise, nutrition, healthy cooking, recovery, sleep and habits as they relate to training, and using this app. If asked about anything else — politics, shopping advice, coding, what colour cat to buy — decline in one short friendly line and offer something you can help with instead. Do not lecture, and do not answer "just this once".

## Safety
You are not a doctor. If someone describes pain, injury, a medical condition, pregnancy, an eating disorder, or is on medication that affects training or diet, work within safe limits and tell them plainly to check with a professional. Never diagnose, never tell anyone to stop prescribed treatment, and never push an aggressive calorie deficit. If a request would be unsafe, say so and offer the safer version.

## Format
Use Markdown for structure when it helps: bold for key numbers, short lists for routines or meals. Keep answers as short as they can be while still being useful. You are on a phone screen.
`.trim();

/**
 * Built per request rather than once at module load, because the tools are
 * bound to the caller's verified uid through `toolsContext`. That binding is
 * what stops the model from ever reaching another user's data.
 */
export function createCeliaAgent(
  context: CeliaToolContext,
  userState?: UserStateSnapshot | null
) {
  const stateSection = buildUserStateSection(userState);
  return new ToolLoopAgent({
    model: deepSeek(CHAT_MODEL),
    instructions: stateSection
      ? `${INSTRUCTIONS}\n\n${stateSection}`
      : INSTRUCTIONS,
    tools: celiaTools,
    toolsContext: celiaToolsContext(context),
    stopWhen: isStepCount(MAX_STEPS),
    // Anything that writes to the user's data waits for an explicit
    // confirmation from the app before it runs.
    toolApproval: Object.fromEntries(
      WRITE_TOOLS.map((name) => [name, 'user-approval' as const])
    ),
  });
}

export type UserStateSnapshot = {
  displayName?: string | null;
  /** Nutrition targets live in Firestore, which this backend cannot read, so the app sends them. */
  targets?: {
    dailyCalories?: number;
    proteinGrams?: number;
    carbsGrams?: number;
    fatGrams?: number;
  } | null;
  profile?: {
    weightKg?: number;
    heightCm?: number;
    age?: number;
    gender?: string;
  } | null;
  /**
   * The onboarding answers, read from `user_profiles` by the backend itself.
   * Unlike the fields above this does not come from the request body, so the
   * app cannot misreport it.
   */
  onboarding?: OnboardingFacts | null;
};

/** The subset of `user_profiles` that changes how Celia should answer. */
export type OnboardingFacts = {
  primaryGoal?: string | null;
  dietPattern?: string | null;
  dietaryConditions?: string[] | null;
  foodAllergies?: string[] | null;
  disorderedEatingHistory?: boolean | null;
  nutritionMode?: string | null;
  dailyWaterMl?: number | null;
  trainingLocation?: string | null;
  usesEquipment?: boolean | null;
  availableEquipment?: string[] | null;
  injuries?: string[] | null;
  medicalConditions?: string[] | null;
  fitnessGoal?: string | null;
  desiredOutcomes?: string[] | null;
  trainingIntensity?: string | null;
  experienceLevel?: string | null;
  planningMode?: string | null;
  minutesPerDay?: number | null;
  preferredTrainingTime?: string | null;
  currentMood?: string | null;
  coachingFocus?: string | null;
};

/** Turns a slug into something that reads naturally in the prompt. */
function phrase(value: string): string {
  return value.replace(/_/g, ' ');
}

function list(values: string[] | null | undefined): string | null {
  const items = (values || []).map((v) => phrase(String(v)).trim()).filter(Boolean);
  return items.length ? items.join(', ') : null;
}

function trainsWhere(location: string): string {
  switch (location) {
    case 'home':
      return 'trains at home';
    case 'gym':
      return 'trains at a gym';
    case 'both':
      return 'trains both at home and at a gym';
    default:
      return `trains ${phrase(location)}`;
  }
}

/**
 * The onboarding answers as instruction lines.
 *
 * Constraints come before preferences, because the cost of ignoring an allergy
 * or an injury is not the same as the cost of ignoring a preference.
 */
function onboardingLines(facts: OnboardingFacts): string[] {
  const lines: string[] = [];

  const allergies = list(facts.foodAllergies);
  if (allergies) {
    lines.push(
      `Food allergies: ${allergies}. Never suggest a meal, recipe or ingredient that contains these.`
    );
  }
  const intolerances = list(facts.dietaryConditions);
  if (intolerances) lines.push(`Intolerances: ${intolerances}.`);
  if (facts.dietPattern) lines.push(`Diet: ${phrase(facts.dietPattern)}.`);

  const injuries = list(facts.injuries);
  if (injuries) {
    lines.push(
      `Injuries or areas to avoid: ${injuries}. Do not program movements that load these, and offer a substitute instead.`
    );
  }
  const conditions = list(facts.medicalConditions);
  if (conditions) {
    lines.push(
      `Reported medical conditions: ${conditions}. Stay conservative and recommend professional advice rather than working around them yourself.`
    );
  }

  if (facts.disorderedEatingHistory) {
    lines.push(
      'This user reported a history of disordered eating. Their calorie target is set to maintenance regardless of their goal: ' +
        'do not suggest a deficit, fasting, or cutting, do not comment on their weight or appearance, and keep the framing on ' +
        'energy, strength and how they feel. Never mention this note to them.'
    );
  }

  if (facts.primaryGoal) lines.push(`Main goal: ${phrase(facts.primaryGoal)}.`);
  if (facts.fitnessGoal) lines.push(`Training goal: ${phrase(facts.fitnessGoal)}.`);

  if (facts.trainingLocation) {
    lines.push(`Training location: ${trainsWhere(facts.trainingLocation)}.`);
  }
  if (facts.usesEquipment === true) {
    const kit = list(facts.availableEquipment) || 'unspecified kit';
    lines.push(
      `They own: ${kit}. Workouts stay bodyweight; the "How to" tab shows how to use that kit.`
    );
  }

  const training = [
    facts.experienceLevel ? `${phrase(facts.experienceLevel)} level` : null,
    facts.trainingIntensity ? `${phrase(facts.trainingIntensity)} intensity` : null,
    facts.minutesPerDay ? `${facts.minutesPerDay} minutes per session` : null,
    facts.preferredTrainingTime ? `usually around ${facts.preferredTrainingTime}` : null,
  ].filter(Boolean);
  if (training.length) lines.push(`Training: ${training.join(', ')}.`);

  const outcomes = list(facts.desiredOutcomes);
  if (outcomes) lines.push(`Also wants to work on: ${outcomes}.`);

  const planning: string[] = [];
  if (facts.nutritionMode) planning.push(`meals ${phrase(facts.nutritionMode)}`);
  if (facts.planningMode) planning.push(`workouts ${phrase(facts.planningMode)}`);
  if (planning.length) {
    lines.push(
      `Planning preference: ${planning.join(', ')}. Where they chose manual, propose rather than decide for them.`
    );
  }

  if (facts.dailyWaterMl) lines.push(`Water target: ${facts.dailyWaterMl} ml per day.`);

  const mood: string[] = [];
  if (facts.currentMood) mood.push(`felt ${phrase(facts.currentMood)} at signup`);
  if (facts.coachingFocus) mood.push(`wants coaching on: ${facts.coachingFocus}`);
  if (mood.length) lines.push(`Coaching: ${mood.join('; ')}.`);

  return lines;
}

/**
 * Facts the agent should always know without spending a tool call. This is
 * appended to the instructions rather than sent as a system message, because
 * the agent rejects system messages in the message list.
 */
export function buildUserStateSection(
  snapshot: UserStateSnapshot | null | undefined
): string | null {
  if (!snapshot) return null;

  const lines: string[] = [];
  if (snapshot.displayName) lines.push(`Name: ${snapshot.displayName}`);

  const profile = snapshot.profile;
  if (profile?.weightKg || profile?.heightCm || profile?.age) {
    const parts: string[] = [];
    if (profile.weightKg) parts.push(`${profile.weightKg}kg`);
    if (profile.heightCm) parts.push(`${profile.heightCm}cm`);
    if (profile.age) parts.push(`${profile.age} years old`);
    if (profile.gender) parts.push(String(profile.gender));
    lines.push(`Body: ${parts.join(', ')}`);
  }

  const targets = snapshot.targets;
  if (targets?.dailyCalories) {
    const macros = [
      targets.proteinGrams ? `${Math.round(targets.proteinGrams)}g protein` : null,
      targets.carbsGrams ? `${Math.round(targets.carbsGrams)}g carbs` : null,
      targets.fatGrams ? `${Math.round(targets.fatGrams)}g fat` : null,
    ].filter(Boolean);
    lines.push(
      `Daily targets: ${Math.round(targets.dailyCalories)} kcal` +
        (macros.length ? ` (${macros.join(', ')})` : '')
    );
  } else {
    lines.push(
      'This user has not set up their nutrition profile yet, so there are no calorie or macro targets. ' +
        'If nutrition advice needs them, encourage them to set it up on the Nutrition tab.'
    );
  }

  if (snapshot.onboarding) lines.push(...onboardingLines(snapshot.onboarding));

  return `## Current user (from the app)\n${lines.join('\n')}`;
}
