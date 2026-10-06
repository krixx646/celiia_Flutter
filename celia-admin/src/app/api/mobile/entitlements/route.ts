import { NextRequest, NextResponse } from 'next/server';
import { verifyFirebaseUser } from '@/lib/firebaseAuth';
import { getSupabaseAdmin } from '@/lib/supabaseAdmin';

export const runtime = 'nodejs';

type EntitlementRow = {
  scans_limit: number;
  scans_used: number;
  bonus_scans: number;
  period_start: string;
  tier: string;
};

function remainingOf(row: EntitlementRow): number {
  return Math.max(row.scans_limit - row.scans_used, 0) + (row.bonus_scans || 0);
}

const PERIOD_MS = 30 * 24 * 60 * 60 * 1000;

function resetsAtOf(periodStart: string): string {
  return new Date(new Date(periodStart).getTime() + PERIOD_MS).toISOString();
}

export async function GET(req: NextRequest) {
  try {
    const user = await verifyFirebaseUser(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from('user_entitlements')
      .select('scans_limit, scans_used, bonus_scans, period_start, tier')
      .eq('user_id', user.uid)
      .maybeSingle();

    if (error) {
      return NextResponse.json(
        { error: 'Could not load entitlements', details: error.message },
        { status: 500 }
      );
    }

    if (!data) {
      // No free scans: first row is created on consume/grant with scans_limit 0.
      return NextResponse.json({
        remaining: 0,
        bonusScans: 0,
        periodRemaining: 0,
        scansLimit: 0,
        scansUsed: 0,
        tier: 'free',
        resetsAt: resetsAtOf(new Date().toISOString()),
        productId: 'eu.thefit.celia.body_scan.single',
      });
    }

    const row = data as EntitlementRow;
    // consume_body_scan_quota only rolls the period over when someone scans,
    // so an expired period has to be treated as already reset here.
    const periodExpired =
      Date.now() - new Date(row.period_start).getTime() > PERIOD_MS;
    const effective: EntitlementRow = periodExpired
      ? { ...row, scans_used: 0, period_start: new Date().toISOString() }
      : row;
    const periodRemaining = Math.max(effective.scans_limit - effective.scans_used, 0);
    return NextResponse.json({
      remaining: remainingOf(effective),
      bonusScans: effective.bonus_scans || 0,
      periodRemaining,
      scansLimit: effective.scans_limit,
      scansUsed: effective.scans_used,
      tier: effective.tier,
      resetsAt: resetsAtOf(effective.period_start),
      productId: 'eu.thefit.celia.body_scan.single',
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
