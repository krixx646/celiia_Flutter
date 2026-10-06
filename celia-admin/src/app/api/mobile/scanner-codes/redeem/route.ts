import { NextRequest, NextResponse } from 'next/server';
import { verifyFirebaseUser } from '@/lib/firebaseAuth';
import { getSupabaseAdmin } from '@/lib/supabaseAdmin';

export const runtime = 'nodejs';

type RedeemBody = {
  code?: string;
};

export async function POST(req: NextRequest) {
  try {
    const user = await verifyFirebaseUser(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const body = (await req.json()) as RedeemBody;
    const code = (body.code || '').trim();
    if (!code) {
      return NextResponse.json(
        { error: 'Enter a code', code: 'invalid' },
        { status: 400 }
      );
    }

    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase.rpc('redeem_scanner_code', {
      p_user_id: user.uid,
      p_code: code,
    });

    if (error) {
      return NextResponse.json(
        {
          error: 'Could not redeem code',
          code: 'redeemFailed',
          details: error.message,
        },
        { status: 500 }
      );
    }

    const row = Array.isArray(data) ? data[0] : data;
    if (!row?.ok) {
      const reason = String(row?.reason || 'invalid');
      const status =
        reason === 'not_found' || reason === 'invalid'
          ? 404
          : reason === 'already_redeemed'
            ? 409
            : 400;
      return NextResponse.json(
        {
          error: messageForReason(reason),
          code: reason,
        },
        { status }
      );
    }

    return NextResponse.json({
      ok: true,
      scansGranted: Number(row.scans_granted || 0),
      remaining: Number(row.remaining || 0),
    });
  } catch (e) {
    return NextResponse.json(
      {
        error: 'Unexpected error',
        details: e instanceof Error ? e.message : String(e),
      },
      { status: 500 }
    );
  }
}

function messageForReason(reason: string): string {
  switch (reason) {
    case 'not_found':
    case 'invalid':
      return 'That code is not valid';
    case 'expired':
      return 'That code has expired';
    case 'exhausted':
      return 'That code has no redemptions left';
    case 'already_redeemed':
      return 'You have already used that code';
    default:
      return 'That code could not be redeemed';
  }
}
