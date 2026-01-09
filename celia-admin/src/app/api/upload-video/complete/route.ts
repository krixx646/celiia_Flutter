import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL!, process.env.SUPABASE_SERVICE_ROLE_KEY!);

const CLOUDFLARE_ACCOUNT_ID = process.env.CLOUDFLARE_ACCOUNT_ID;
const CLOUDFLARE_API_TOKEN = process.env.CLOUDFLARE_STREAM_API_TOKEN;

export const runtime = 'nodejs';
export const maxDuration = 60;

function mapCloudflareState(state: unknown): 'pending' | 'processing' | 'ready' | 'error' {
  const s = (state || '').toString().toLowerCase();
  if (s === 'ready') return 'ready';
  if (s === 'error') return 'error';
  if (s === 'queued' || s === 'inprogress' || s === 'processing') return 'processing';
  return 'processing';
}

async function fetchCloudflareDetailsWithRetry(uid: string, attempts = 3, delayMs = 1000) {
  if (!CLOUDFLARE_ACCOUNT_ID || !CLOUDFLARE_API_TOKEN) {
    return { ok: false as const, status: 0, json: null, error: 'Cloudflare env not configured' };
  }

  let lastErr: any = null;
  for (let i = 0; i < attempts; i++) {
    try {
      const res = await fetch(
        `https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/stream/${uid}`,
        { headers: { Authorization: `Bearer ${CLOUDFLARE_API_TOKEN}` } }
      );

      const text = await res.text().catch(() => '');
      let json: any = null;
      try {
        json = text ? JSON.parse(text) : null;
      } catch {
        json = null;
      }

      if (res.ok && json?.success) {
        return { ok: true as const, status: res.status, json, error: null };
      }

      lastErr = {
        status: res.status,
        body: json || text,
      };
    } catch (e: any) {
      lastErr = { error: e?.message ?? String(e) };
    }

    // brief backoff (Cloudflare can be eventually consistent right after upload)
    if (i < attempts - 1) {
      await new Promise((r) => setTimeout(r, delayMs));
    }
  }

  return { ok: false as const, status: 0, json: null, error: lastErr };
}

export async function POST(req: NextRequest) {
  try {
    if (!process.env.NEXT_PUBLIC_SUPABASE_URL || !process.env.SUPABASE_SERVICE_ROLE_KEY) {
      return NextResponse.json({ error: 'Supabase is not configured' }, { status: 500 });
    }
    if (!CLOUDFLARE_ACCOUNT_ID || !CLOUDFLARE_API_TOKEN) {
      return NextResponse.json(
        { error: 'Cloudflare Stream is not configured (missing CLOUDFLARE_ACCOUNT_ID or CLOUDFLARE_STREAM_API_TOKEN)' },
        { status: 500 }
      );
    }

    const body = await req.json();
    const uid = String(body?.uid || '').trim();
    if (!uid) return NextResponse.json({ error: 'uid is required' }, { status: 400 });

    const title = String(body?.title || '');
    const description = body?.description != null ? String(body.description) : null;
    const category = body?.category != null ? String(body.category) : 'general';
    const bodyPart = body?.bodyPart != null ? String(body.bodyPart) : 'full_body';
    const difficulty = body?.difficulty != null ? String(body.difficulty).toLowerCase() : 'beginner';
    const equipment = Array.isArray(body?.equipment) ? body.equipment : [];

    // Cloudflare can be eventually consistent right after upload. Also, some API tokens may allow creating uploads
    // but not reading details. We should still save the clip as "processing" so it shows up in the dashboard.
    const details = await fetchCloudflareDetailsWithRetry(uid, 3, 1000);

    const cfResult = details.ok ? (details.json?.result || {}) : {};
    const playbackUrl =
      (cfResult?.playback?.hls as string | undefined) ||
      `https://customer-${CLOUDFLARE_ACCOUNT_ID}.cloudflarestream.com/${uid}/manifest/video.m3u8`;
    const thumbnailUrl =
      (cfResult?.thumbnail as string | undefined) || `https://videodelivery.net/${uid}/thumbnails/thumbnail.jpg`;

    const durationRaw = cfResult?.duration ?? 0;
    const durationNum = typeof durationRaw === 'number' ? durationRaw : Number(durationRaw);
    const durationSeconds = Number.isFinite(durationNum) && durationNum > 0 ? Math.round(durationNum) : 0;

    const status = details.ok ? mapCloudflareState(cfResult?.status?.state) : 'processing';

    const { data: video, error: dbError } = await supabase
      .from('videos')
      .insert({
        title,
        description,
        category,
        body_part: bodyPart,
        difficulty,
        duration_seconds: durationSeconds,
        cloudflare_video_id: uid,
        playback_url: playbackUrl,
        thumbnail_url: thumbnailUrl,
        equipment,
        is_ai_generated: false,
        status,
        uploaded_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (dbError) {
      return NextResponse.json(
        { error: 'Failed to save video metadata', details: dbError?.message || dbError },
        { status: 500 }
      );
    }

    return NextResponse.json({
      ok: true,
      video,
      cloudflare: details.ok ? { ok: true } : { ok: false, error: details.error },
    });
  } catch (e: any) {
    return NextResponse.json({ error: e?.message ?? String(e) }, { status: 500 });
  }
}


