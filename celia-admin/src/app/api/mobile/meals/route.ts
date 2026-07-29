import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
import { createRemoteJWKSet, jwtVerify } from 'jose';

export const runtime = 'nodejs';
export const maxDuration = 30;

const FIREBASE_PROJECT_ID = process.env.FIREBASE_PROJECT_ID;
const FIREBASE_JWKS = createRemoteJWKSet(
  new URL('https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com')
);

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL || '',
  process.env.SUPABASE_SERVICE_ROLE_KEY || ''
);

async function verifyFirebaseUser(req: NextRequest): Promise<{ uid: string } | null> {
  if (!FIREBASE_PROJECT_ID) return null;

  const auth = req.headers.get('authorization') || '';
  const [scheme, token] = auth.split(' ');
  if (scheme !== 'Bearer' || !token) return null;

  try {
    const { payload } = await jwtVerify(token, FIREBASE_JWKS, {
      issuer: `https://securetoken.google.com/${FIREBASE_PROJECT_ID}`,
      audience: FIREBASE_PROJECT_ID,
    });
    const uid = typeof payload.sub === 'string' ? payload.sub : '';
    return uid ? { uid } : null;
  } catch {
    return null;
  }
}

function safeLimit(value: string | null) {
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) return 50;
  return Math.max(1, Math.min(100, Math.trunc(parsed)));
}

export async function GET(req: NextRequest) {
  try {
    if (!process.env.NEXT_PUBLIC_SUPABASE_URL || !process.env.SUPABASE_SERVICE_ROLE_KEY) {
      return NextResponse.json({ error: 'Supabase service is not configured' }, { status: 500 });
    }

    const user = await verifyFirebaseUser(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const limit = safeLimit(req.nextUrl.searchParams.get('limit'));
    const { data, error } = await supabase
      .from('user_meals')
      .select()
      .eq('user_id', user.uid)
      .order('logged_at', { ascending: false })
      .limit(limit);

    if (error) {
      return NextResponse.json({ error: 'Failed to load meals', details: error.message }, { status: 500 });
    }

    return NextResponse.json({ meals: data || [] });
  } catch (e) {
    return NextResponse.json(
      { error: 'Unexpected error', details: e instanceof Error ? e.message : String(e) },
      { status: 500 }
    );
  }
}
