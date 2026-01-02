import { NextRequest, NextResponse } from 'next/server';

const CLOUDFLARE_ACCOUNT_ID = process.env.CLOUDFLARE_ACCOUNT_ID;
const CLOUDFLARE_API_TOKEN = process.env.CLOUDFLARE_STREAM_API_TOKEN;

export const runtime = 'nodejs';
export const maxDuration = 30;

export async function POST(req: NextRequest) {
  try {
    if (!CLOUDFLARE_ACCOUNT_ID || !CLOUDFLARE_API_TOKEN) {
      return NextResponse.json(
        { error: 'Cloudflare Stream is not configured (missing CLOUDFLARE_ACCOUNT_ID or CLOUDFLARE_STREAM_API_TOKEN)' },
        { status: 500 }
      );
    }

    const body = await req.json().catch(() => ({}));
    const title = String(body?.title || 'Celia video');
    const maxDurationSeconds = Number(body?.maxDurationSeconds || 3600);

    const res = await fetch(
      `https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/stream/direct_upload`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${CLOUDFLARE_API_TOKEN}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          maxDurationSeconds: Number.isFinite(maxDurationSeconds) ? maxDurationSeconds : 3600,
          meta: { name: title },
        }),
      }
    );

    const json: any = await res.json();
    if (!json?.success) {
      return NextResponse.json({ error: 'Failed to get upload URL from Cloudflare', cloudflare: json }, { status: 500 });
    }

    return NextResponse.json({
      ok: true,
      uploadURL: json.result.uploadURL,
      uid: json.result.uid,
    });
  } catch (e: any) {
    return NextResponse.json({ error: e?.message ?? String(e) }, { status: 500 });
  }
}


