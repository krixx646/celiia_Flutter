import { NextRequest, NextResponse } from 'next/server';
import {
  convertToModelMessages,
  createUIMessageStreamResponse,
  toUIMessageStream,
  type ModelMessage,
  type UIMessage,
} from 'ai';
import { verifyFirebaseUser } from '@/lib/firebaseAuth';
import { getSupabaseAdmin } from '@/lib/supabaseAdmin';
import { createCeliaAgent, type UserStateSnapshot } from '@/lib/celiaAgent/agent';

export const runtime = 'nodejs';
export const maxDuration = 60;

// Enough for a long coaching answer; older turns are dropped so a long-running
// conversation can't grow the prompt without bound.
const MAX_HISTORY_MESSAGES = 40;

type ApprovalDecision = {
  approvalId: string;
  approved: boolean;
};

type ChatBody = {
  /** Omit to start a new conversation. */
  conversationId?: string;
  /** The new user message. Omitted when only answering a pending approval. */
  message?: string;
  /** Minutes east of UTC on the device, so "today" matches the app. */
  tzOffsetMinutes?: number;
  /** Profile/targets the backend can't read itself (they live in Firestore). */
  state?: UserStateSnapshot;
  /** Responses to tool confirmations Celia asked for on a previous turn. */
  approvals?: ApprovalDecision[];
};

function titleFrom(message: string) {
  const trimmed = message.trim().replace(/\s+/g, ' ');
  return trimmed.length <= 60 ? trimmed : `${trimmed.slice(0, 57)}...`;
}

export async function POST(req: NextRequest) {
  try {
    if (!process.env.DEEPSEEK_API_KEY) {
      return NextResponse.json({ error: 'DEEPSEEK_API_KEY is not configured' }, { status: 500 });
    }

    const user = await verifyFirebaseUser(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const body = (await req.json()) as ChatBody;
    const messageText = String(body.message || '').trim();
    const approvals = Array.isArray(body.approvals) ? body.approvals : [];

    if (!messageText && approvals.length === 0) {
      return NextResponse.json({ error: 'Missing message' }, { status: 400 });
    }

    const tzOffsetMinutes = Number.isFinite(body.tzOffsetMinutes)
      ? Number(body.tzOffsetMinutes)
      : 0;

    const supabase = getSupabaseAdmin();

    // Resolve the conversation, refusing ids that belong to someone else.
    let conversationId = body.conversationId?.trim() || '';
    if (conversationId) {
      const { data: existing } = await supabase
        .from('chat_conversations')
        .select('id,user_id')
        .eq('id', conversationId)
        .maybeSingle();

      if (!existing || existing.user_id !== user.uid) {
        return NextResponse.json({ error: 'Conversation not found' }, { status: 404 });
      }
    } else {
      const { data: created, error: createErr } = await supabase
        .from('chat_conversations')
        .insert({
          user_id: user.uid,
          title: messageText ? titleFrom(messageText) : 'New chat',
        })
        .select('id')
        .single();

      if (createErr || !created) {
        return NextResponse.json(
          { error: 'Could not start conversation', details: createErr?.message },
          { status: 500 }
        );
      }
      conversationId = String(created.id);
    }

    const { data: historyRows } = await supabase
      .from('chat_messages')
      .select('id,role,parts')
      .eq('conversation_id', conversationId)
      .order('created_at', { ascending: true })
      .limit(MAX_HISTORY_MESSAGES);

    const history: UIMessage[] = (historyRows || []).map((row) => ({
      id: String(row.id),
      role: row.role as UIMessage['role'],
      parts: (Array.isArray(row.parts) ? row.parts : []) as UIMessage['parts'],
    }));

    if (messageText) {
      history.push({
        id: crypto.randomUUID(),
        role: 'user',
        parts: [{ type: 'text', text: messageText }],
      });
    }

    const messages: ModelMessage[] = await convertToModelMessages(history);

    // Answers to tool confirmations from the previous turn. Without these the
    // agent would just re-ask instead of running the approved tool.
    if (approvals.length > 0) {
      messages.push({
        role: 'tool',
        content: approvals.map((decision) => ({
          type: 'tool-approval-response' as const,
          approvalId: decision.approvalId,
          approved: decision.approved,
        })),
      });
    }

    // Persist the user's turn now, so it isn't lost if generation fails.
    if (messageText) {
      await supabase.from('chat_messages').insert({
        conversation_id: conversationId,
        user_id: user.uid,
        role: 'user',
        content: messageText,
        parts: [{ type: 'text', text: messageText }],
      });
    }

    const agent = createCeliaAgent({ uid: user.uid, tzOffsetMinutes }, body.state);
    const result = await agent.stream({ messages });

    return createUIMessageStreamResponse({
      headers: { 'x-conversation-id': conversationId },
      stream: toUIMessageStream({
        stream: result.stream,
        // The SDK's default swallows the cause behind "An error occurred.",
        // which leaves nothing to debug from once this is running on a device.
        onError: (error) => {
          console.error('[chat] stream error', error);
          return error instanceof Error ? error.message : String(error);
        },
        onEnd: async ({ responseMessage }) => {
          const parts = responseMessage.parts ?? [];
          const text = parts
            .filter((part): part is { type: 'text'; text: string } => part.type === 'text')
            .map((part) => part.text)
            .join('\n')
            .trim();

          await supabase.from('chat_messages').insert({
            conversation_id: conversationId,
            user_id: user.uid,
            role: 'assistant',
            content: text,
            parts,
          });

          await supabase
            .from('chat_conversations')
            .update({ updated_at: new Date().toISOString() })
            .eq('id', conversationId);
        },
      }),
    });
  } catch (e) {
    return NextResponse.json(
      { error: 'Unexpected error', details: e instanceof Error ? e.message : String(e) },
      { status: 500 }
    );
  }
}
