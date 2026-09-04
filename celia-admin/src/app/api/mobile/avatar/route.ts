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
import { createAvatarAgent } from '@/lib/celiaAgent/avatarAgent';
import type { UserStateSnapshot } from '@/lib/celiaAgent/agent';

export const runtime = 'nodejs';
export const maxDuration = 60;

const MAX_HISTORY_MESSAGES = 40;
/** Separates Avatar Mode threads from the manual chat tab. */
const CONVERSATION_MODE = 'avatar';

type ApprovalDecision = {
  approvalId: string;
  approved: boolean;
};

type AvatarBody = {
  conversationId?: string;
  message?: string;
  tzOffsetMinutes?: number;
  state?: UserStateSnapshot;
  approvals?: ApprovalDecision[];
};

type ApprovalRequestedPart = {
  state: string;
  approval?: { id?: string };
};

function applyApprovals(history: UIMessage[], decisions: ApprovalDecision[]) {
  const byId = new Map(decisions.map((d) => [d.approvalId, d.approved]));
  const changed: UIMessage[] = [];

  for (const message of history) {
    if (message.role !== 'assistant') continue;
    let touched = false;

    message.parts = message.parts.map((part) => {
      const candidate = part as ApprovalRequestedPart;
      if (candidate.state !== 'approval-requested') return part;

      const id = candidate.approval?.id;
      if (!id || !byId.has(id)) return part;

      touched = true;
      return {
        ...part,
        state: 'approval-responded',
        approval: { ...candidate.approval, approved: byId.get(id) },
      } as UIMessage['parts'][number];
    });

    if (touched) changed.push(message);
  }

  return changed;
}

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

    const body = (await req.json()) as AvatarBody;
    const messageText = String(body.message || '').trim();
    const approvals = Array.isArray(body.approvals) ? body.approvals : [];

    if (!messageText && approvals.length === 0) {
      return NextResponse.json({ error: 'Missing message' }, { status: 400 });
    }

    const tzOffsetMinutes = Number.isFinite(body.tzOffsetMinutes)
      ? Number(body.tzOffsetMinutes)
      : 0;

    const supabase = getSupabaseAdmin();

    let conversationId = body.conversationId?.trim() || '';
    if (conversationId) {
      const { data: existing } = await supabase
        .from('chat_conversations')
        .select('id,user_id,mode')
        .eq('id', conversationId)
        .maybeSingle();

      if (
        !existing ||
        existing.user_id !== user.uid ||
        (existing.mode != null && existing.mode !== CONVERSATION_MODE)
      ) {
        return NextResponse.json({ error: 'Conversation not found' }, { status: 404 });
      }
    } else {
      const row: Record<string, string> = {
        user_id: user.uid,
        title: messageText ? titleFrom(messageText) : 'Avatar chat',
        mode: CONVERSATION_MODE,
      };

      let { data: created, error: createErr } = await supabase
        .from('chat_conversations')
        .insert(row)
        .select('id')
        .single();

      // Same fallback as /api/mobile/chat: the mode column may not exist yet.
      if (createErr?.code === 'PGRST204' || /mode/i.test(createErr?.message || '')) {
        delete row.mode;
        ({ data: created, error: createErr } = await supabase
          .from('chat_conversations')
          .insert(row)
          .select('id')
          .single());
      }

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

    if (approvals.length > 0) {
      const changed = applyApprovals(history, approvals);
      for (const message of changed) {
        await supabase
          .from('chat_messages')
          .update({ parts: message.parts })
          .eq('id', message.id);
      }
    }

    if (messageText) {
      history.push({
        id: crypto.randomUUID(),
        role: 'user',
        parts: [{ type: 'text', text: messageText }],
      });
    }

    const messages: ModelMessage[] = await convertToModelMessages(history);

    if (messageText) {
      await supabase.from('chat_messages').insert({
        conversation_id: conversationId,
        user_id: user.uid,
        role: 'user',
        content: messageText,
        parts: [{ type: 'text', text: messageText }],
      });
    }

    const agent = createAvatarAgent({ uid: user.uid, tzOffsetMinutes }, body.state);
    const result = await agent.stream({ messages });

    return createUIMessageStreamResponse({
      headers: { 'x-conversation-id': conversationId },
      stream: toUIMessageStream({
        stream: result.stream,
        originalMessages: history,
        onError: (error) => {
          console.error('[avatar] stream error', error);
          return error instanceof Error ? error.message : String(error);
        },
        onEnd: async ({ responseMessage, isContinuation }) => {
          const parts = responseMessage.parts ?? [];
          const text = parts
            .filter((part): part is { type: 'text'; text: string } => part.type === 'text')
            .map((part) => part.text)
            .join('\n')
            .trim();

          if (parts.length === 0) return;

          if (isContinuation) {
            await supabase
              .from('chat_messages')
              .update({ content: text, parts })
              .eq('id', responseMessage.id)
              .eq('user_id', user.uid);
          } else {
            await supabase.from('chat_messages').insert({
              conversation_id: conversationId,
              user_id: user.uid,
              role: 'assistant',
              content: text,
              parts,
            });
          }

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
