import { NextRequest, NextResponse } from 'next/server';
import { verifyFirebaseUser } from '@/lib/firebaseAuth';
import { getSupabaseAdmin } from '@/lib/supabaseAdmin';

export const runtime = 'nodejs';
export const maxDuration = 30;

/**
 * Apple Guideline 5.1.1(v): apps that support account creation must also
 * support account deletion. The Firebase Auth identity itself is deleted
 * client-side (it needs the user's own recent-login session); this route
 * wipes everything we hold in Supabase for that uid first, while the
 * caller's ID token is still valid.
 */
export async function DELETE(req: NextRequest) {
  try {
    const user = await verifyFirebaseUser(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const supabase = getSupabaseAdmin();

    // chat_messages cascades from chat_conversations.
    const tables = [
      'chat_conversations',
      'user_meals',
      'user_routines',
      'routine_requests',
    ] as const;

    for (const table of tables) {
      const { error } = await supabase
        .from(table)
        .delete()
        .eq('user_id', user.uid);

      if (error) {
        return NextResponse.json(
          { error: `Could not delete ${table}`, details: error.message },
          { status: 500 }
        );
      }
    }

    return NextResponse.json({ ok: true });
  } catch (e) {
    return NextResponse.json(
      { error: 'Unexpected error', details: e instanceof Error ? e.message : String(e) },
      { status: 500 }
    );
  }
}
