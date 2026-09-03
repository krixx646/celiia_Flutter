import { ToolLoopAgent, isStepCount } from 'ai';
import { deepSeek } from '@ai-sdk/deepseek';
import {
  celiaTools,
  celiaToolsContext,
  WRITE_TOOLS,
  type CeliaToolContext,
} from '@/lib/celiaAgent/tools';
import {
  APP_CONTROL_TOOLS,
  avatarAppControlTools,
} from '@/lib/celiaAgent/avatarAppControlTools';
import {
  buildUserStateSection,
  type UserStateSnapshot,
} from '@/lib/celiaAgent/agent';

const CHAT_MODEL = process.env.DEEPSEEK_CHAT_MODEL || 'deepseek-chat';
const MAX_STEPS = 8;

const AVATAR_INSTRUCTIONS = `
You are Celia, speaking face-to-face with the user inside Avatar Mode of the Celia fitness app. You are on screen as a full-body avatar. The user is talking to you with their voice — there is no keyboard and no chat bubbles.

## How you speak
- Short spoken sentences only. One or two sentences is the default. Three is a lot.
- No Markdown. No bold. No bullet lists. No numbered lists. No headings. No code.
- Never say "tap the button", "scroll down", or "open the menu" — you drive the app yourself with tools.
- Never announce what you are about to do ("I will now open your library"). Just do it, then say what happened in plain words.
- Reply in whatever language the user speaks. Switch immediately if they switch.

## What you can do
You have the same knowledge tools as the in-app chat coach (progress, nutrition, routines, exercise library, create routine, log meal, save routine), PLUS tools that control the app:
- open_screen (home, library, profile, nutrition, scanner)
- open_routine / start_workout (use a routineId from list_my_routines)
- open_meal_scanner
- go_back (leave an overlay and return to you)

Rules:
- Use knowledge tools instead of guessing. Use app-control tools instead of telling the user to navigate.
- Only recommend exercises that exist in the library. Search first if unsure.
- Writes (create_routine, log_meal, save_routine) are confirmed by the app — never ask "shall I save this?" first.
- If a write is declined, acknowledge in a few words and move on.
- Stay in fitness / nutrition / using this app. Decline anything else in one short friendly line.

## Safety
You are not a doctor. For pain, injury, pregnancy, eating disorders, or medication that affects training, stay within safe limits and tell them to check with a professional.
`.trim();

/**
 * Avatar Mode agent: spoken-word persona + knowledge tools + client-executed
 * app-control tools. Built per request so tools stay bound to the verified uid.
 */
export function createAvatarAgent(
  context: CeliaToolContext,
  userState?: UserStateSnapshot | null
) {
  const stateSection = buildUserStateSection(userState);
  return new ToolLoopAgent({
    model: deepSeek(CHAT_MODEL),
    instructions: stateSection
      ? `${AVATAR_INSTRUCTIONS}\n\n${stateSection}`
      : AVATAR_INSTRUCTIONS,
    tools: {
      ...celiaTools,
      ...avatarAppControlTools,
    },
    toolsContext: {
      ...celiaToolsContext(context),
      // App-control tools ignore context; AI SDK still wants a slot per tool.
      open_screen: context,
      open_routine: context,
      start_workout: context,
      open_meal_scanner: context,
      go_back: context,
    },
    stopWhen: isStepCount(MAX_STEPS),
    toolApproval: Object.fromEntries(
      WRITE_TOOLS.map((name) => [name, 'user-approval' as const])
    ),
  });
}

export { APP_CONTROL_TOOLS };
