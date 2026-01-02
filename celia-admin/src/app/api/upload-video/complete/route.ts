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

export async function POST(req: NextRequest) {
  try {
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

    const detailsRes = await fetch(
      `https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/stream/${uid}`,
      { headers: { Authorization: `Bearer ${CLOUDFLARE_API_TOKEN}` } }
    );
    const detailsJson: any = await detailsRes.json();
    if (!detailsJson?.success) {
      return NextResponse.json({ error: 'Failed to fetch Cloudflare video details', cloudflare: detailsJson }, { status: 500 });
    }

    const result = detailsJson.result || {};
    const playbackUrl =
      (result?.playback?.hls as string | undefined) ||
      `https://customer-${CLOUDFLARE_ACCOUNT_ID}.cloudflarestream.com/${uid}/manifest/video.m3u8`;
    const thumbnailUrl =
      (result?.thumbnail as string | undefined) || `https://videodelivery.net/${uid}/thumbnails/thumbnail.jpg`;
    const durationRaw = result?.duration ?? 0;
    const durationNum = typeof durationRaw === 'number' ? durationRaw : Number(durationRaw);
    const durationSeconds = Number.isFinite(durationNum) && durationNum > 0 ? Math.round(durationNum) : 0;
    const status = mapCloudflareState(result?.status?.state);

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
      return NextResponse.json({ error: 'Failed to save video metadata', details: dbError }, { status: 500 });
    }

    return NextResponse.json({ ok: true, video });
  } catch (e: any) {
    return NextResponse.json({ error: e?.message ?? String(e) }, { status: 500 });
  }
}


