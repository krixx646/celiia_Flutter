import { NextRequest, NextResponse } from 'next/server';
import { getSupabaseAdmin } from '@/lib/supabaseAdmin';

export async function PATCH(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const supabase = getSupabaseAdmin();
    const { id } = await params;
    const body = await req.json();

    const patch: Record<string, any> = {};

    if (body && 'is_published' in body) {
      if (typeof body.is_published !== 'boolean') {
        return NextResponse.json({ error: 'is_published must be boolean' }, { status: 400 });
      }
      patch.is_published = body.is_published;
    }
    if (typeof body?.title === 'string') patch.title = body.title;
    if ('description' in (body ?? {})) patch.description = body.description ?? null;
    if (typeof body?.duration_minutes === 'number') patch.duration_minutes = body.duration_minutes;
    if (typeof body?.difficulty === 'string') patch.difficulty = body.difficulty;
    if (typeof body?.category === 'string') patch.category = body.category;
    if ('thumbnail_url' in (body ?? {})) patch.thumbnail_url = body.thumbnail_url ?? null;
    if ('is_curated' in (body ?? {})) patch.is_curated = Boolean(body.is_curated);
    if ('tags' in (body ?? {})) patch.tags = Array.isArray(body.tags) ? body.tags : [];
    if ('calories_burned' in (body ?? {})) patch.calories_burned = body.calories_burned ?? null;
    if ('equipment' in (body ?? {})) patch.equipment = body.equipment ?? null;
    if ('steps' in (body ?? {})) {
      if (!Array.isArray(body.steps)) {
        return NextResponse.json({ error: 'steps must be an array' }, { status: 400 });
      }
      patch.steps = body.steps;
    }

    if (Object.keys(patch).length === 0) {
      return NextResponse.json({ error: 'No fields provided to update' }, { status: 400 });
    }

    const { data, error } = await supabase.from('routines').update(patch).eq('id', id).select().single();
    if (error) throw error;
    return NextResponse.json({ ok: true, routine: data });
  } catch (e: any) {
    return NextResponse.json({ error: e?.message ?? String(e) }, { status: 500 });
  }
}

export async function DELETE(_: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const supabase = getSupabaseAdmin();
    const { id } = await params;
    const { error } = await supabase.from('routines').delete().eq('id', id);
    if (error) throw error;
    return NextResponse.json({ ok: true });
  } catch (e: any) {
    return NextResponse.json({ error: e?.message ?? String(e) }, { status: 500 });
  }
}


