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

function isMissingColumnError(error: unknown): boolean {
  const msg =
    typeof error === 'object' && error !== null && 'message' in error
      ? String((error as { message?: unknown }).message ?? '')
      : String(error ?? '');
  return msg.toLowerCase().includes('column') && msg.toLowerCase().includes('does not exist');
}

async function insertVideoRow(
  payload: Record<string, unknown>,
  payloadWithoutBackup: Record<string, unknown>
) {
  const first = await supabase.from('videos').insert(payload).select().single();
  if (!first.error) return first;
  if (!isMissingColumnError(first.error)) return first;

  // Backward compatibility for DBs that have not yet added backup/source columns.
  return supabase.from('videos').insert(payloadWithoutBackup).select().single();
}

async function fetchCloudflareDetailsWithRetry(uid: string, attempts = 3, delayMs = 1000) {
  if (!CLOUDFLARE_ACCOUNT_ID || !CLOUDFLARE_API_TOKEN) {
    return { ok: false as const, status: 0, json: null, error: 'Cloudflare env not configured' };
  }

  let lastErr: unknown = null;
  for (let i = 0; i < attempts; i++) {
    try {
      const res = await fetch(
        `https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/stream/${uid}`,
        { headers: { Authorization: `Bearer ${CLOUDFLARE_API_TOKEN}` } }
      );

      const text = await res.text().catch(() => '');
      let json: unknown = null;
      try {
        json = text ? JSON.parse(text) : null;
      } catch {
        json = null;
      }
      const parsed =
        typeof json === 'object' && json !== null
          ? (json as { success?: boolean })
          : {};

      if (res.ok && parsed.success) {
        return { ok: true as const, status: res.status, json, error: null };
      }

      lastErr = {
        status: res.status,
        body: json || text,
      };
    } catch (e: unknown) {
      lastErr = { error: e instanceof Error ? e.message : String(e) };
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
    const backupBucket = body?.backupBucket != null ? String(body.backupBucket).trim() : '';
    const backupPath = body?.backupPath != null ? String(body.backupPath).trim() : '';
    const sourceUrl = body?.sourceUrl != null ? String(body.sourceUrl).trim() : '';

    // Cloudflare can be eventually consistent right after upload. Also, some API tokens may allow creating uploads
    // but not reading details. We should still save the clip as "processing" so it shows up in the dashboard.
    const details = await fetchCloudflareDetailsWithRetry(uid, 3, 1000);

    const cfPayload =
      details.ok && typeof details.json === 'object' && details.json !== null
        ? (details.json as {
            result?: {
              playback?: { hls?: string };
              thumbnail?: string;
              duration?: number | string;
              status?: { state?: string };
            };
          })
        : {};
    const cfResult = cfPayload.result || {};
    const playbackUrl =
      (cfResult?.playback?.hls as string | undefined) ||
      `https://customer-${CLOUDFLARE_ACCOUNT_ID}.cloudflarestream.com/${uid}/manifest/video.m3u8`;
    const thumbnailUrl =
      (cfResult?.thumbnail as string | undefined) || `https://videodelivery.net/${uid}/thumbnails/thumbnail.jpg`;

    const durationRaw = cfResult?.duration ?? 0;
    const durationNum = typeof durationRaw === 'number' ? durationRaw : Number(durationRaw);
    const durationSeconds = Number.isFinite(durationNum) && durationNum > 0 ? Math.round(durationNum) : 0;

    const status = details.ok ? mapCloudflareState(cfResult?.status?.state) : 'processing';

    const basePayload: Record<string, unknown> = {
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
    };
    const payloadWithBackup: Record<string, unknown> = {
      ...basePayload,
      source_url: sourceUrl || null,
      backup_bucket: backupBucket || null,
      backup_path: backupPath || null,
    };

    const { data: video, error: dbError } = await insertVideoRow(
      payloadWithBackup,
      basePayload
    );

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
  } catch (e: unknown) {
    return NextResponse.json(
      { error: e instanceof Error ? e.message : String(e) },
      { status: 500 }
    );
  }
}


