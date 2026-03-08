import { NextRequest, NextResponse } from 'next/server';
import { getSupabaseAdmin } from '@/lib/supabaseAdmin';

export const runtime = 'nodejs';
export const maxDuration = 60;

const CLOUDFLARE_ACCOUNT_ID = process.env.CLOUDFLARE_ACCOUNT_ID;
const CLOUDFLARE_API_TOKEN = process.env.CLOUDFLARE_STREAM_API_TOKEN;

function isRecord(v: unknown): v is Record<string, unknown> {
  return typeof v === 'object' && v !== null;
}

function mapCloudflareState(state: unknown): 'pending' | 'processing' | 'ready' | 'error' {
  const s = (state || '').toString().toLowerCase();
  if (s === 'ready') return 'ready';
  if (s === 'error') return 'error';
  if (s === 'queued' || s === 'inprogress' || s === 'processing') return 'processing';
  return 'processing';
}

function tryExtractUidFromUrl(url: string): string | null {
  const u = (url || '').trim();
  if (!u) return null;
  const m1 = u.match(/videodelivery\.net\/([^/?#]+)/i);
  if (m1?.[1]) return m1[1];
  const m2 = u.match(/cloudflarestream\.com\/([^/?#]+)/i);
  if (m2?.[1]) return m2[1];
  return null;
}

function isLegacyCustomerDomainUrl(url: unknown): boolean {
  return typeof url === 'string' && /customer-[^.]+\.cloudflarestream\.com/i.test(url);
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

    const uid =
      ((video.cloudflare_video_id || '').trim() || tryExtractUidFromUrl((video.playback_url || '').trim())) ?? '';
    if (!uid) {
      return NextResponse.json({ error: 'No cloudflare uid on this video' }, { status: 400 });
    }

    const cfRes = await fetch(
      `https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/stream/${uid}`,
      { headers: { Authorization: `Bearer ${CLOUDFLARE_API_TOKEN}` } }
    );
    const cfJson: any = await cfRes.json();
    if (!cfJson?.success) {
      const errs = Array.isArray(cfJson?.errors) ? cfJson.errors : [];
      const msg = errs.map((e: any) => e?.message || e?.toString?.() || '').filter(Boolean).join(' | ');
      const notFound = errs.some((e: any) => {
        const code = isRecord(e) ? e['code'] : null;
        const message = isRecord(e) ? e['message'] : null;
        return code === 10003 || (typeof message === 'string' && /not found/i.test(message));
      });

      if (cfRes.status === 404 || notFound) {
        const { data: updated, error: updErr } = await supabase
          .from('videos')
          .update({ status: 'error' })
          .eq('id', id)
          .select()
          .single();
        if (updErr) throw updErr;

        return NextResponse.json({
          ok: false,
          missing: true,
          error: 'Cloudflare video asset not found',
          details: msg || null,
          video: updated,
          cloudflare: { errors: errs, uid },
        });
      }

      return NextResponse.json(
        { error: 'Failed to fetch Cloudflare video details', details: msg || null, cloudflare: { errors: errs } },
        { status: 500 }
      );
    }

    const result = cfJson.result || {};
    const status = mapCloudflareState(result?.status?.state);
    const durationRaw = result?.duration ?? null;
    const durationNum = typeof durationRaw === 'number' ? durationRaw : Number(durationRaw);
    const durationSeconds = Number.isFinite(durationNum) && durationNum > 0 ? Math.round(durationNum) : null;

    const playbackUrl =
      (result?.playback?.hls as string | undefined) ||
      `https://videodelivery.net/${uid}/manifest/video.m3u8`;
    const thumbnailUrl =
      (result?.thumbnail as string | undefined) || `https://videodelivery.net/${uid}/thumbnails/thumbnail.jpg`;

    const patch: Record<string, any> = {
      cloudflare_video_id: uid,
      status,
      playback_url: playbackUrl,
      thumbnail_url: isLegacyCustomerDomainUrl(video.thumbnail_url) ? thumbnailUrl : (video.thumbnail_url || thumbnailUrl),
    };
    if (durationSeconds != null) patch.duration_seconds = durationSeconds;

    const { data: updated, error: updErr } = await supabase
      .from('videos')
      .update(patch)
      .eq('id', id)
      .select()
      .single();
    if (updErr) throw updErr;

    const cfStatus = result?.status || null;
    return NextResponse.json({ ok: true, video: updated, cloudflare: { status: cfStatus, uid } });
  } catch (e: any) {
    return NextResponse.json({ error: e?.message ?? String(e) }, { status: 500 });
  }
}


