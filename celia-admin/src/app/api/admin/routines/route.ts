import { NextRequest, NextResponse } from 'next/server';
import { getSupabaseAdmin } from '@/lib/supabaseAdmin';

export async function GET() {
  try {
    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase.from('routines').select('*').order('created_at', { ascending: false });
    if (error) throw error;
    return NextResponse.json({ routines: data ?? [] });
  } catch (e: any) {
    return NextResponse.json({ error: e?.message ?? String(e) }, { status: 500 });
  }
}

export async function POST(req: NextRequest) {
  try {
    const supabase = getSupabaseAdmin();
    const body = await req.json();

    const {
      title,
      description,
      duration_minutes,
      difficulty,
      category,
      thumbnail_url,
      steps,
      is_published,
      is_curated,
      tags,
      calories_burned,
      equipment,
    } = body ?? {};

    if (!title || typeof title !== 'string') {
      return NextResponse.json({ error: 'title is required' }, { status: 400 });
    }
    if (!duration_minutes || typeof duration_minutes !== 'number') {
      return NextResponse.json({ error: 'duration_minutes must be a number' }, { status: 400 });
    }
    if (!difficulty || !category) {
      return NextResponse.json({ error: 'difficulty and category are required' }, { status: 400 });
    }

    const { data, error } = await supabase
      .from('routines')
      .insert({
        title,
        description: description ?? null,
        duration_minutes,
        difficulty,
        category,
        thumbnail_url: thumbnail_url ?? null,
        steps: steps ?? [],
        is_published: Boolean(is_published),
        is_curated: Boolean(is_curated),
        tags: Array.isArray(tags) ? tags : [],
        calories_burned: calories_burned ?? null,
        equipment: equipment ?? null,
        created_by: 'admin',
      })
      .select()
      .single();

    if (error) throw error;
    return NextResponse.json({ routine: data });
  } catch (e: any) {
    return NextResponse.json({ error: e?.message ?? String(e) }, { status: 500 });
  }
}


