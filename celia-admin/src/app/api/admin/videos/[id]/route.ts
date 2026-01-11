import { NextRequest, NextResponse } from 'next/server';
import { getSupabaseAdmin } from '@/lib/supabaseAdmin';

export const runtime = 'nodejs';
export const maxDuration = 60;

const CLOUDFLARE_ACCOUNT_ID = process.env.CLOUDFLARE_ACCOUNT_ID;
const CLOUDFLARE_API_TOKEN = process.env.CLOUDFLARE_STREAM_API_TOKEN;

function isRecord(v: unknown): v is Record<string, unknown> {
  return typeof v === 'object' && v !== null;
}

function errMessage(e: unknown): string {
  return e instanceof Error ? e.message : String(e);
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

type CloudflareDeleteResult =
  | { skipped: true }
  | { ok: true; notFound?: true; cloudflare?: unknown }
  | { ok: false; status: number; error: string; cloudflare?: unknown };

async function deleteCloudflareVideo(uid: string): Promise<CloudflareDeleteResult> {
  if (!CLOUDFLARE_ACCOUNT_ID || !CLOUDFLARE_API_TOKEN) {
    return { skipped: true };
  }

  const res = await fetch(
    `https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/stream/${uid}`,
    {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${CLOUDFLARE_API_TOKEN}` },
    }
  );

  // Cloudflare always returns JSON, but be defensive.
  const json: unknown = await res.json().catch(() => null);

  if (res.status === 404) return { ok: true, notFound: true, cloudflare: json ?? null };

  const successFalse = isRecord(json) && json['success'] === false;
  if (!res.ok || successFalse) {
    const errs = isRecord(json) && Array.isArray(json['errors']) ? (json['errors'] as unknown[]) : [];
    const msg = errs
      .map((e) => (isRecord(e) && typeof e['message'] === 'string' ? (e['message'] as string) : String(e)))
      .filter(Boolean)
      .join(' | ');
    return { ok: false, status: res.status, error: msg || 'Cloudflare delete failed', cloudflare: json ?? null };
  }

  return { ok: true, cloudflare: json ?? null };
}

export async function DELETE(_: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const { id } = await params;
    const supabase = getSupabaseAdmin();

    const { data: video, error: readErr } = await supabase.from('videos').select('*').eq('id', id).single();
    if (readErr) throw readErr;

    const v = (video ?? {}) as Record<string, unknown>;
    const cloudflareVideoId = typeof v['cloudflare_video_id'] === 'string' ? (v['cloudflare_video_id'] as string) : '';
    const playbackUrl = typeof v['playback_url'] === 'string' ? (v['playback_url'] as string) : '';

    const uid =
      (cloudflareVideoId.trim() || tryExtractUidFromUrl(playbackUrl.trim())) ?? '';

    const cf = uid ? await deleteCloudflareVideo(uid) : { skipped: true };
    const warning = 'ok' in cf && cf.ok === false ? cf.error : null;

    const { error: delErr } = await supabase.from('videos').delete().eq('id', id);
    if (delErr) throw delErr;

    return NextResponse.json({ ok: true, warning, cloudflare: cf, deletedId: id });
  } catch (e: unknown) {
    return NextResponse.json({ error: errMessage(e) }, { status: 500 });
  }
}

