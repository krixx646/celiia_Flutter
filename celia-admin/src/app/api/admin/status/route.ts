import { NextResponse } from 'next/server';
import { getSupabaseAdmin } from '@/lib/supabaseAdmin';

export async function GET() {
  const missing: string[] = [];
  if (!process.env.NEXT_PUBLIC_SUPABASE_URL) missing.push('NEXT_PUBLIC_SUPABASE_URL');
  if (!process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY) missing.push('NEXT_PUBLIC_SUPABASE_ANON_KEY');
  if (!process.env.SUPABASE_SERVICE_ROLE_KEY) missing.push('SUPABASE_SERVICE_ROLE_KEY');
  if (!process.env.FAL_KEY) missing.push('FAL_KEY');
  if (!process.env.CLOUDFLARE_ACCOUNT_ID) missing.push('CLOUDFLARE_ACCOUNT_ID');
  if (!process.env.CLOUDFLARE_STREAM_API_TOKEN) missing.push('CLOUDFLARE_STREAM_API_TOKEN');

  let supabaseOk = false;
  let supabaseError: string | null = null;
  try {
    const admin = getSupabaseAdmin();
    const { error } = await admin.from('routines').select('id', { count: 'exact', head: true }).limit(1);
    if (error) throw error;
    supabaseOk = true;
  } catch (e: any) {
    supabaseOk = false;
    supabaseError = e?.message ?? String(e);
  }

  return NextResponse.json({
    ok: missing.length === 0 && supabaseOk,
    missing,
    supabaseOk,
    supabaseError,
    falOk: Boolean(process.env.FAL_KEY),
    cloudflareOk: Boolean(process.env.CLOUDFLARE_ACCOUNT_ID && process.env.CLOUDFLARE_STREAM_API_TOKEN),
    kling: {
      baseModel: process.env.FAL_KLING_MODEL || null,
      audioModel: process.env.FAL_KLING_MODEL_WITH_AUDIO || null,
    },
  });
}


