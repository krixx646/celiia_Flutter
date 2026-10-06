import { NextRequest, NextResponse } from 'next/server';
import { verifyFirebaseUser } from '@/lib/firebaseAuth';
import { getSupabaseAdmin } from '@/lib/supabaseAdmin';
import { isBodyScanProductId, scansForProduct } from '@/lib/billingProducts';
import { verifyGooglePlayPurchase } from '@/lib/verifyGooglePlay';
import { verifyAppleTransaction } from '@/lib/verifyAppleIap';

export const runtime = 'nodejs';
export const maxDuration = 30;

type VerifyBody = {
  platform?: string;
  productId?: string;
  purchaseToken?: string;
  transactionId?: string;
  verificationData?: string;
};

export async function POST(req: NextRequest) {
  try {
    const user = await verifyFirebaseUser(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const body = (await req.json()) as VerifyBody;
    const platform = (body.platform || '').trim().toLowerCase();
    const productId = (body.productId || '').trim();
    const purchaseToken = (body.purchaseToken || body.verificationData || '').trim();

    if (platform !== 'android' && platform !== 'ios') {
      return NextResponse.json(
        { error: 'platform must be android or ios', code: 'invalidPlatform' },
        { status: 400 }
      );
    }
    if (!isBodyScanProductId(productId)) {
      return NextResponse.json(
        { error: 'Unknown product', code: 'unknownProduct' },
        { status: 400 }
      );
    }
    if (!purchaseToken) {
      return NextResponse.json(
        { error: 'Missing purchase verification data', code: 'missingToken' },
        { status: 400 }
      );
    }

    const scans = scansForProduct(productId);
    if (scans == null) {
      return NextResponse.json(
        { error: 'Unknown product', code: 'unknownProduct' },
        { status: 400 }
      );
    }

    // The store, not the client, is the source of truth for the transaction id.
    let transactionId: string;
    let rawPayload: unknown;
    try {
      if (platform === 'android') {
        const verified = await verifyGooglePlayPurchase({ productId, purchaseToken });
        transactionId = verified.orderId || purchaseToken;
        rawPayload = verified.raw;
      } else {
        const verified = await verifyAppleTransaction({
          productId,
          signedTransaction: purchaseToken,
        });
        transactionId = verified.transactionId;
        rawPayload = verified.raw;
      }
    } catch (e) {
      return NextResponse.json(
        {
          error: 'Purchase could not be verified',
          code: 'verifyFailed',
          details: e instanceof Error ? e.message : String(e),
        },
        { status: 402 }
      );
    }

    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase.rpc('record_purchase_and_grant', {
      p_user_id: user.uid,
      p_platform: platform,
      p_product_id: productId,
      p_transaction_id: transactionId,
      p_purchase_token: platform === 'android' ? purchaseToken : null,
      p_scans: scans,
      p_raw: rawPayload ?? null,
    });

    if (error) {
      return NextResponse.json(
        { error: 'Could not record purchase', code: 'persistFailed', details: error.message },
        { status: 500 }
      );
    }

    const row = Array.isArray(data) ? data[0] : data;
    const granted = Boolean(row?.granted);
    return NextResponse.json({
      ok: true,
      alreadyProcessed: !granted,
      scansGranted: granted ? scans : 0,
      remaining: Number(row?.remaining ?? 0),
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
