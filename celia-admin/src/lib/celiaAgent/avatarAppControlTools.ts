import { tool } from 'ai';
import { z } from 'zod';

/**
 * Client-executed tools for Avatar Mode.
 *
 * These run on Vercel only long enough to acknowledge the intent. The Flutter
 * app receives the tool call over the SSE stream and performs the real
 * navigation / workout launch locally — the server cannot call Navigator.
 *
 * Returning an immediate acknowledgement means the agent loop does not need a
 * resume protocol for these tools in v1.
 */
export const avatarAppControlTools = {
  open_screen: tool({
    description:
      'Open a screen in the Celia app. Use when the user asks to go somewhere ' +
      '(home, library, profile, nutrition, meal scanner).',
    inputSchema: z.object({
      screen: z.enum(['home', 'library', 'profile', 'nutrition', 'scanner']),
    }),
    execute: async ({ screen }) => ({
      ok: true,
      action: 'open_screen',
      screen,
      clientExecuted: true,
    }),
  }),

  open_routine: tool({
    description:
      'Open a saved routine\'s detail screen. Pass the routineId from ' +
      'list_my_routines or get_routine_details.',
    inputSchema: z.object({
      routineId: z.string().min(1),
    }),
    execute: async ({ routineId }) => ({
      ok: true,
      action: 'open_routine',
      routineId,
      clientExecuted: true,
    }),
  }),

  start_workout: tool({
    description:
      'Start a guided workout for a saved routine. Pass the routineId from ' +
      'list_my_routines. Prefer this when the user says "start", "let\'s go", ' +
      'or "train now".',
    inputSchema: z.object({
      routineId: z.string().min(1),
    }),
    execute: async ({ routineId }) => ({
      ok: true,
      action: 'start_workout',
      routineId,
      clientExecuted: true,
    }),
  }),

  open_meal_scanner: tool({
    description:
      'Open the meal / calorie scanner camera so the user can photograph food.',
    inputSchema: z.object({}),
    execute: async () => ({
      ok: true,
      action: 'open_meal_scanner',
      clientExecuted: true,
    }),
  }),

  go_back: tool({
    description:
      'Leave the current overlay screen and return to the avatar. Use when ' +
      'the user says "go back", "close that", or "return to you".',
    inputSchema: z.object({}),
    execute: async () => ({
      ok: true,
      action: 'go_back',
      clientExecuted: true,
    }),
  }),
} as const;

export const APP_CONTROL_TOOLS = [
  'open_screen',
  'open_routine',
  'start_workout',
  'open_meal_scanner',
  'go_back',
] as const;
