import { NextRequest, NextResponse } from 'next/server';
import { getSupabaseAdmin } from '@/lib/supabaseAdmin';
import {
  createBackupDownloadUrl,
  DEFAULT_BACKUP_BUCKET,
} from '@/lib/videoBackup';

export const runtime = 'nodejs';
export const maxDuration = 300;

const CLOUDFLARE_ACCOUNT_ID = process.env.CLOUDFLARE_ACCOUNT_ID;
const CLOUDFLARE_API_TOKEN = process.env.CLOUDFLARE_STREAM_API_TOKEN;

function tryExtractUidFromUrl(url: string): string | null {
  const u = (url || '').trim();
  if (!u) return null;
  const m1 = u.match(/videodelivery\.net\/([^/?#]+)/i);
  if (m1?.[1]) return m1[1];
  const m2 = u.match(/cloudflarestream\.com\/([^/?#]+)/i);
  if (m2?.[1]) return m2[1];
  return null;
}

function looksLikeCloudflareUrl(url: string): boolean {
  return /videodelivery\.net|cloudflarestream\.com/i.test(url);
}

async function cloudflareVideoExists(uid: string): Promise<boolean> {
  if (!CLOUDFLARE_ACCOUNT_ID || !CLOUDFLARE_API_TOKEN) return false;
  try {
    const res = await fetch(
      `https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/stream/${uid}`,
      { headers: { Authorization: `Bearer ${CLOUDFLARE_API_TOKEN}` } }
    );
    const json: unknown = await res.json().catch(() => null);
    const parsed =
      typeof json === 'object' && json !== null
        ? (json as { success?: boolean })
        : {};
    return Boolean(res.ok && parsed.success);
  } catch {
    return false;
  }
}

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

    const json: unknown = await res.json();
    const payload =
      typeof json === 'object' && json !== null
        ? (json as {
            success?: boolean;
            result?: {
              uid?: string;
              id?: string;
              result?: { uid?: string };
              video?: { uid?: string; id?: string };
            };
          })
        : {};
    if (!payload.success) {
      console.error('Cloudflare copy failed:', json);
      return null;
    }

    const uid =
      payload.result?.uid ||
      payload.result?.result?.uid ||
      payload.result?.id ||
      payload.result?.video?.uid ||
      payload.result?.video?.id;
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
  const json: unknown = await res.json();
  const payload =
    typeof json === 'object' && json !== null
      ? (json as { success?: boolean; result?: { uploadURL?: string; uid?: string } })
      : {};
  if (!payload.success) {
    console.error('Cloudflare direct_upload failed:', json);
    return null;
  }
  const uploadURL = payload.result?.uploadURL;
  const uid = payload.result?.uid;
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

function safeString(v: unknown): string {
  return typeof v === 'string' ? v.trim() : '';
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

    const playbackUrl = safeString(video.playback_url);
    const sourceUrl = safeString(video.source_url);
    const backupPath = safeString(video.backup_path);
    const backupBucket = safeString(video.backup_bucket) || DEFAULT_BACKUP_BUCKET;
    const playbackUid = tryExtractUidFromUrl(playbackUrl);
    const existingCfId = safeString(video.cloudflare_video_id);
    if (existingCfId && !existingCfId.startsWith('fal-')) {
      const exists = await cloudflareVideoExists(existingCfId);
      if (exists) {
        return NextResponse.json({ ok: true, video });
      }

      // If playback URL points to a different valid Cloudflare UID, repair metadata to that UID.
      if (playbackUid && playbackUid !== existingCfId) {
        const playbackUidExists = await cloudflareVideoExists(playbackUid);
        if (playbackUidExists) {
          const repairedPlaybackUrl = `https://customer-${CLOUDFLARE_ACCOUNT_ID}.cloudflarestream.com/${playbackUid}/manifest/video.m3u8`;
          const repairedThumbUrl = `https://videodelivery.net/${playbackUid}/thumbnails/thumbnail.jpg`;
          const { data: repaired, error: repairErr } = await supabase
            .from('videos')
            .update({
              cloudflare_video_id: playbackUid,
              playback_url: repairedPlaybackUrl,
              thumbnail_url: repairedThumbUrl,
              status: 'processing',
            })
            .eq('id', id)
            .select()
            .single();
          if (repairErr) throw repairErr;
          return NextResponse.json({ ok: true, repaired: true, video: repaired });
        }
      }
    }

    const backupSignedUrl = backupPath
      ? await createBackupDownloadUrl(supabase, backupBucket, backupPath)
      : null;
    const ingestionSourceUrl =
      backupSignedUrl ||
      (sourceUrl && !looksLikeCloudflareUrl(sourceUrl) ? sourceUrl : '') ||
      (playbackUrl && !looksLikeCloudflareUrl(playbackUrl) ? playbackUrl : '');

    if (!ingestionSourceUrl) {
      if (!playbackUrl && !sourceUrl && !backupPath) {
        return NextResponse.json(
          { error: 'Video has no recoverable source (missing backup, source_url, and playback_url).' },
          { status: 400 }
        );
      }
      if (looksLikeCloudflareUrl(playbackUrl) || looksLikeCloudflareUrl(sourceUrl)) {
        return NextResponse.json(
          {
            error:
              'Cloudflare asset is missing and no backup file is stored. Re-upload the original file to restore this video.',
          },
          { status: 409 }
        );
      }
      return NextResponse.json(
        { error: 'Could not determine a recoverable source URL for re-ingestion.' },
        { status: 400 }
      );
    }

    const uid = await ingestIntoCloudflareStream({
      sourceUrl: ingestionSourceUrl,
      title: safeString(video.title) || 'Celia video',
    });
    if (!uid) {
      return NextResponse.json({ error: 'Failed to ingest video into Cloudflare Stream' }, { status: 500 });
    }

    const thumbnailUrl = `https://videodelivery.net/${uid}/thumbnails/thumbnail.jpg`;
    const cloudflarePlaybackUrl = `https://customer-${CLOUDFLARE_ACCOUNT_ID}.cloudflarestream.com/${uid}/manifest/video.m3u8`;

    const { data: updated, error: updErr } = await supabase
      .from('videos')
      .update({
        cloudflare_video_id: uid,
        thumbnail_url: thumbnailUrl,
        playback_url: cloudflarePlaybackUrl,
        status: 'processing',
      })
      .eq('id', id)
      .select()
      .single();
    if (updErr) throw updErr;

    return NextResponse.json({ ok: true, video: updated });
  } catch (e: unknown) {
    return NextResponse.json(
      { error: e instanceof Error ? e.message : String(e) },
      { status: 500 }
    );
  }
}


