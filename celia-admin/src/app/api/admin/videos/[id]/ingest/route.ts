import { NextRequest, NextResponse } from 'next/server';
import { getSupabaseAdmin } from '@/lib/supabaseAdmin';

export const runtime = 'nodejs';
export const maxDuration = 300;

const CLOUDFLARE_ACCOUNT_ID = process.env.CLOUDFLARE_ACCOUNT_ID;
const CLOUDFLARE_API_TOKEN = process.env.CLOUDFLARE_STREAM_API_TOKEN;

async function copyToCloudflareStream(url: string, title: string) {
  if (!CLOUDFLARE_ACCOUNT_ID || !CLOUDFLARE_API_TOKEN) return null;

  try {
    const res = await fetch(
      `https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/stream/copy`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${CLOUDFLARE_API_TOKEN}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          url,
          meta: { name: title },
        }),
      }
    );

    const json: any = await res.json();
    if (!json?.success) {
      console.error('Cloudflare copy failed:', json);
      return null;
    }

    const uid =
      json?.result?.uid ||
      json?.result?.result?.uid ||
      json?.result?.id ||
      json?.result?.video?.uid ||
      json?.result?.video?.id;
    return typeof uid === 'string' && uid.length > 0 ? uid : null;
  } catch (e) {
    console.error('Cloudflare copy failed (fetch error):', e);
    return null;
  }
}

async function createCloudflareDirectUpload(title: string) {
  if (!CLOUDFLARE_ACCOUNT_ID || !CLOUDFLARE_API_TOKEN) return null;
  const res = await fetch(
    `https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/stream/direct_upload`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${CLOUDFLARE_API_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        maxDurationSeconds: 600,
        meta: { name: title },
      }),
    }
  );
  const json: any = await res.json();
  if (!json?.success) {
    console.error('Cloudflare direct_upload failed:', json);
    return null;
  }
  const uploadURL = json?.result?.uploadURL;
  const uid = json?.result?.uid;
  if (typeof uploadURL !== 'string' || typeof uid !== 'string') return null;
  return { uploadURL, uid };
}

async function uploadRemoteVideoToCloudflare(uploadURL: string, sourceUrl: string, filename: string) {
  const srcRes = await fetch(sourceUrl);
  if (!srcRes.ok) {
    const text = await srcRes.text().catch(() => '');
    throw new Error(`Failed to download source video (${srcRes.status}): ${text.slice(0, 200)}`);
  }
  const arrayBuffer = await srcRes.arrayBuffer();
  const contentType = srcRes.headers.get('content-type') || 'video/mp4';
  const blob = new Blob([arrayBuffer], { type: contentType });
  const form = new FormData();
  form.append('file', blob, filename);
  const upRes = await fetch(uploadURL, { method: 'POST', body: form });
  if (!upRes.ok) {
    const text = await upRes.text().catch(() => '');
    throw new Error(`Cloudflare upload failed (${upRes.status}): ${text.slice(0, 200)}`);
  }
}

async function ingestIntoCloudflareStream(opts: { sourceUrl: string; title: string }) {
  const { sourceUrl, title } = opts;

  // Fast path: Cloudflare fetches the URL directly.
  const copiedUid = await copyToCloudflareStream(sourceUrl, title);
  if (copiedUid) return copiedUid;

  // Fallback: download the mp4 ourselves and upload to Cloudflare.
  const du = await createCloudflareDirectUpload(title);
  if (!du) return null;
  await uploadRemoteVideoToCloudflare(du.uploadURL, sourceUrl, `${title || 'celia-video'}.mp4`);
  return du.uid;
}

export async function POST(_: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    if (!CLOUDFLARE_ACCOUNT_ID || !CLOUDFLARE_API_TOKEN) {
      return NextResponse.json(
        { error: 'Cloudflare Stream is not configured (missing CLOUDFLARE_ACCOUNT_ID or CLOUDFLARE_STREAM_API_TOKEN)' },
        { status: 500 }
      );
    }

    const { id } = await params;
    const supabase = getSupabaseAdmin();

    const { data: video, error: readErr } = await supabase.from('videos').select('*').eq('id', id).single();
    if (readErr) throw readErr;

    const existingCfId = (video.cloudflare_video_id || '').trim();
    if (existingCfId && !existingCfId.startsWith('fal-')) {
      return NextResponse.json({ ok: true, video });
    }

    const playbackUrl = (video.playback_url || '').trim();
    if (!playbackUrl) {
      return NextResponse.json({ error: 'Video has no playback_url to ingest' }, { status: 400 });
    }

    const uid = await ingestIntoCloudflareStream({ sourceUrl: playbackUrl, title: video.title || 'Celia video' });
    if (!uid) {
      return NextResponse.json({ error: 'Failed to ingest video into Cloudflare Stream' }, { status: 500 });
    }

    const thumbnailUrl = `https://videodelivery.net/${uid}/thumbnails/thumbnail.jpg`;
    const cloudflarePlaybackUrl = `https://customer-${CLOUDFLARE_ACCOUNT_ID}.cloudflarestream.com/${uid}/manifest/video.m3u8`;

    const { data: updated, error: updErr } = await supabase
      .from('videos')
      .update({
        cloudflare_video_id: uid,
        thumbnail_url: video.thumbnail_url || thumbnailUrl,
        playback_url: video.playback_url || cloudflarePlaybackUrl,
        status: video.status === 'ready' ? 'ready' : 'processing',
      })
      .eq('id', id)
      .select()
      .single();
    if (updErr) throw updErr;

    return NextResponse.json({ ok: true, video: updated });
  } catch (e: any) {
    return NextResponse.json({ error: e?.message ?? String(e) }, { status: 500 });
  }
}


