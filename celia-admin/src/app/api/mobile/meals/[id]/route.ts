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

type FoodItem = {
  name?: unknown;
  servingGrams?: unknown;
  calories?: unknown;
  proteinGrams?: unknown;
  carbsGrams?: unknown;
  fatGrams?: unknown;
  confidence?: unknown;
  notes?: unknown;
  box?: unknown;
};

type UpdateMealBody = {
  title?: unknown;
  totalCalories?: unknown;
  totalProteinGrams?: unknown;
  totalCarbsGrams?: unknown;
  totalFatGrams?: unknown;
  items?: unknown;
  warnings?: unknown;
};

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

function safeNumber(value: unknown, fallback = 0) {
  const number = typeof value === 'number' ? value : Number(value);
  return Number.isFinite(number) ? Math.max(0, number) : fallback;
}

function normalizeItems(items: unknown) {
  if (!Array.isArray(items)) return [];

  return items
    .map((entry) => {
      const item = entry && typeof entry === 'object' ? (entry as FoodItem) : null;
      const name = String(item?.name || '').trim();
      if (!item || !name) return null;

      return {
        name,
        servingGrams: safeNumber(item.servingGrams),
        calories: safeNumber(item.calories),
        proteinGrams: safeNumber(item.proteinGrams),
        carbsGrams: safeNumber(item.carbsGrams),
        fatGrams: safeNumber(item.fatGrams),
        confidence: Math.min(1, safeNumber(item.confidence, 0)),
        notes: item.notes ? String(item.notes) : null,
        box: item.box && typeof item.box === 'object' ? item.box : null,
      };
    })
    .filter(Boolean);
}

export async function PATCH(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    if (!process.env.NEXT_PUBLIC_SUPABASE_URL || !process.env.SUPABASE_SERVICE_ROLE_KEY) {
      return NextResponse.json({ error: 'Supabase service is not configured' }, { status: 500 });
    }

    const user = await verifyFirebaseUser(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { id } = await params;
    const body = (await req.json()) as UpdateMealBody;
    const items = normalizeItems(body.items);
    if (items.length === 0) {
      return NextResponse.json({ error: 'Meal must have at least one item' }, { status: 400 });
    }

    const warnings = Array.isArray(body.warnings) ? body.warnings.map(String).filter(Boolean) : [];
    const payload = {
      title: String(body.title || 'Logged Meal'),
      calories: safeNumber(body.totalCalories),
      protein_grams: safeNumber(body.totalProteinGrams),
      carbs_grams: safeNumber(body.totalCarbsGrams),
      fat_grams: safeNumber(body.totalFatGrams),
      items,
      warnings,
    };

    const { data, error } = await supabase
      .from('user_meals')
      .update(payload)
      .eq('id', id)
      .eq('user_id', user.uid)
      .select()
      .single();

    if (error) {
      return NextResponse.json({ error: 'Failed to update meal', details: error.message }, { status: 500 });
    }

    return NextResponse.json({ meal: data });
  } catch (e) {
    return NextResponse.json(
      { error: 'Unexpected error', details: e instanceof Error ? e.message : String(e) },
      { status: 500 }
    );
  }
}

export async function DELETE(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    if (!process.env.NEXT_PUBLIC_SUPABASE_URL || !process.env.SUPABASE_SERVICE_ROLE_KEY) {
      return NextResponse.json({ error: 'Supabase service is not configured' }, { status: 500 });
    }

    const user = await verifyFirebaseUser(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { id } = await params;
    const { error } = await supabase
      .from('user_meals')
      .delete()
      .eq('id', id)
      .eq('user_id', user.uid);

    if (error) {
      return NextResponse.json({ error: 'Failed to delete meal', details: error.message }, { status: 500 });
    }

    return NextResponse.json({ ok: true });
  } catch (e) {
    return NextResponse.json(
      { error: 'Unexpected error', details: e instanceof Error ? e.message : String(e) },
      { status: 500 }
    );
  }
}
