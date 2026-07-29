import { NextRequest, NextResponse } from 'next/server';
import { verifyFirebaseUser } from '@/lib/firebaseAuth';
import { getSupabaseAdmin } from '@/lib/supabaseAdmin';

export const runtime = 'nodejs';

type RouteContext = { params: Promise<{ id: string }> };

/**
 * Confirms the conversation belongs to the caller. Ownership is checked against
 * the verified token rather than trusting the id in the URL.
 */
async function assertOwned(conversationId: string, uid: string) {
  const supabase = getSupabaseAdmin();
  const { data } = await supabase
    .from('chat_conversations')
    .select('id,user_id')
    .eq('id', conversationId)
    .maybeSingle();

  return Boolean(data && data.user_id === uid);
}

export async function GET(req: NextRequest, context: RouteContext) {
  try {
    const user = await verifyFirebaseUser(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { id } = await context.params;
    if (!(await assertOwned(id, user.uid))) {
      return NextResponse.json({ error: 'Conversation not found' }, { status: 404 });
    }

    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from('chat_messages')
      .select('id,role,content,parts,created_at')
      .eq('conversation_id', id)
      .order('created_at', { ascending: true });

    if (error) {
      return NextResponse.json(
        { error: 'Could not load messages', details: error.message },
        { status: 500 }
      );
    }

    return NextResponse.json({
      conversationId: id,
      messages: (data || []).map((row) => ({
        id: String(row.id),
        role: row.role,
        content: row.content,
        parts: row.parts,
        createdAt: row.created_at,
      })),
    });
  } catch (e) {
    return NextResponse.json(
      { error: 'Unexpected error', details: e instanceof Error ? e.message : String(e) },
      { status: 500 }
    );
  }
}

export async function DELETE(req: NextRequest, context: RouteContext) {
  try {
    const user = await verifyFirebaseUser(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { id } = await context.params;
    if (!(await assertOwned(id, user.uid))) {
      return NextResponse.json({ error: 'Conversation not found' }, { status: 404 });
    }

    // chat_messages cascades on delete.
    const { error } = await getSupabaseAdmin()
      .from('chat_conversations')
      .delete()
      .eq('id', id);

    if (error) {
      return NextResponse.json(
        { error: 'Could not delete conversation', details: error.message },
        { status: 500 }
      );
    }

    return NextResponse.json({ deleted: true });
  } catch (e) {
    return NextResponse.json(
      { error: 'Unexpected error', details: e instanceof Error ? e.message : String(e) },
      { status: 500 }
    );
  }
}
