import { NextRequest, NextResponse } from 'next/server';
import { verifyFirebaseUser } from '@/lib/firebaseAuth';
import { getSupabaseAdmin } from '@/lib/supabaseAdmin';

export const runtime = 'nodejs';

/** The signed-in user's chat history, newest first. */
export async function GET(req: NextRequest) {
  try {
    const user = await verifyFirebaseUser(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const supabase = getSupabaseAdmin();
    // Manual chat only — Avatar Mode threads live under mode='avatar'.
    // If the mode column is missing (migration not applied yet), list everything
    // for this user rather than failing the history screen.
    let { data, error } = await supabase
      .from('chat_conversations')
      .select('id,title,updated_at')
      .eq('user_id', user.uid)
      .or('mode.eq.chat,mode.is.null')
      .order('updated_at', { ascending: false })
      .limit(50);

    if (error && (/mode/i.test(error.message) || error.code === '42703' || error.code === '42809')) {
      ({ data, error } = await supabase
        .from('chat_conversations')
        .select('id,title,updated_at')
        .eq('user_id', user.uid)
        .order('updated_at', { ascending: false })
        .limit(50));
    }

    if (error) {
      return NextResponse.json(
        { error: 'Could not load conversations', details: error.message },
        { status: 500 }
      );
    }

    return NextResponse.json({
      conversations: (data || []).map((row) => ({
        id: String(row.id),
        title: String(row.title || 'Chat'),
        updatedAt: row.updated_at,
      })),
    });
  } catch (e) {
    return NextResponse.json(
      { error: 'Unexpected error', details: e instanceof Error ? e.message : String(e) },
      { status: 500 }
    );
  }
}
