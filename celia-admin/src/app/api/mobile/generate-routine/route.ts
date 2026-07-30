import { NextRequest, NextResponse } from 'next/server';
import { verifyFirebaseUser } from '@/lib/firebaseAuth';
import {
  clampDurationMinutes,
  generateRoutine,
  normalizeDifficulty,
} from '@/lib/routineGenerator';

export const runtime = 'nodejs';
export const maxDuration = 60;

type GenerateBody = {
  request?: string;
  durationMinutes?: number;
  difficulty?: string;
  equipment?: string[];
};

export async function POST(req: NextRequest) {
  try {
    if (!process.env.NEXT_PUBLIC_SUPABASE_URL || !process.env.SUPABASE_SERVICE_ROLE_KEY) {
      return NextResponse.json({ error: 'Supabase service is not configured' }, { status: 500 });
    }

    const user = await verifyFirebaseUser(req);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const body = (await req.json()) as GenerateBody;
    const result = await generateRoutine({
      uid: user.uid,
      request: String(body.request || '').trim(),
      durationMinutes: clampDurationMinutes(body.durationMinutes),
      difficulty: normalizeDifficulty(body.difficulty),
      equipment: Array.isArray(body.equipment) ? body.equipment.map(String) : [],
    });

    if (!result.ok) {
      return NextResponse.json(
        { error: result.error, details: result.details },
        { status: result.status }
      );
    }

    return NextResponse.json({
      routine: result.routine,
      alreadyExisted: result.alreadyExisted === true,
    });
  } catch (e) {
    return NextResponse.json(
      { error: 'Unexpected error', details: e instanceof Error ? e.message : String(e) },
      { status: 500 }
    );
  }
}
