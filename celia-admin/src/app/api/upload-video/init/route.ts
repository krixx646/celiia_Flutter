import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
import { createBackupUploadTicket } from '@/lib/videoBackup';

const CLOUDFLARE_ACCOUNT_ID = process.env.CLOUDFLARE_ACCOUNT_ID;
const CLOUDFLARE_API_TOKEN = process.env.CLOUDFLARE_STREAM_API_TOKEN;
const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

export const runtime = 'nodejs';
export const maxDuration = 30;

export async function POST(req: NextRequest) {
  try {
    if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
      return NextResponse.json(
        { error: 'Supabase is not configured' },
        { status: 500 }
      );
    }
    if (!CLOUDFLARE_ACCOUNT_ID || !CLOUDFLARE_API_TOKEN) {
      return NextResponse.json(
        { error: 'Cloudflare Stream is not configured (missing CLOUDFLARE_ACCOUNT_ID or CLOUDFLARE_STREAM_API_TOKEN)' },
        { status: 500 }
      );
    }

    const body = await req.json().catch(() => ({}));
    const title = String(body?.title || 'Celia video');
    const maxDurationSeconds = Number(body?.maxDurationSeconds || 3600);
    const fileName = String(body?.fileName || '');

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

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

    const json: unknown = await res.json();
    const payload =
      typeof json === 'object' && json !== null
        ? (json as { success?: boolean; result?: { uploadURL?: string; uid?: string } })
        : {};
    if (!payload.success || !payload.result?.uploadURL || !payload.result?.uid) {
      return NextResponse.json(
        { error: 'Failed to get upload URL from Cloudflare', cloudflare: json },
        { status: 500 }
      );
    }

    let backup: { bucket: string; path: string; token: string } | null = null;
    let backupWarning: string | null = null;
    try {
      backup = await createBackupUploadTicket(supabase, {
        title,
        originalFileName: fileName,
      });
    } catch (e) {
      backupWarning = e instanceof Error ? e.message : String(e);
      console.error('Backup ticket generation failed:', e);
    }

    return NextResponse.json({
      ok: true,
      uploadURL: payload.result.uploadURL,
      uid: payload.result.uid,
      backup,
      backupWarning,
    });
  } catch (e: unknown) {
    return NextResponse.json(
      { error: e instanceof Error ? e.message : String(e) },
      { status: 500 }
    );
  }
}


