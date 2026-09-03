import { NextRequest, NextResponse } from 'next/server';
import { randomUUID } from 'node:crypto';
import { verifyFirebaseUser } from '@/lib/firebaseAuth';
import { getSupabaseAdmin } from '@/lib/supabaseAdmin';
import {
  BodygramRequestError,
  BodygramScanFailure,
  createPhotoScan,
  isBodygramConfigured,
  type BodygramGender,
  type BodygramMeasurement,
} from '@/lib/bodygram';
import { ObjParseError, objToGlb } from '@/lib/objToGlb';

export const runtime = 'nodejs';
export const maxDuration = 60;

const MESH_BUCKET = 'body-meshes';
const MESH_URL_TTL_SECONDS = 60 * 60; // Long enough to view and cache, short enough to expire.

/** 18+ only: this flow photographs the user's body. */
const MIN_AGE = 18;
const MAX_AGE = 100;
const MIN_HEIGHT_MM = 500;
const MAX_HEIGHT_MM = 2500;
const MIN_WEIGHT_G = 10_000;
const MAX_WEIGHT_G = 200_000;

/**
 * Vercel caps a serverless request body at 4.5 MB and base64 inflates by a
 * third, so the app must downscale before upload. Rejecting here with a clear
 * message beats a platform-level 413 the client cannot interpret.
 */
const MAX_PHOTO_BASE64_CHARS = 1_800_000; // ~1.35 MB of JPEG per photo.

type BodyScanRequest = {
  frontPhotoBase64?: unknown;
  rightPhotoBase64?: unknown;
  age?: unknown;
  gender?: unknown;
  heightCm?: unknown;
  weightKg?: unknown;
};

function finiteNumber(value: unknown): number | null {
  const n = typeof value === 'number' ? value : Number(value);
  return Number.isFinite(n) ? n : null;
}

function findMeasurement(
  measurements: BodygramMeasurement[],
  name: string
): number | null {
  const match = measurements.find((m) => m.name === name);
  return match ? match.value : null;
}

export async function POST(req: NextRequest) {
  const user = await verifyFirebaseUser(req);
  if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  if (!isBodygramConfigured()) {
    return NextResponse.json({ error: 'Body scanning is not configured' }, { status: 500 });
  }

  let supabase: ReturnType<typeof getSupabaseAdmin>;
  try {
    supabase = getSupabaseAdmin();
  } catch (e) {
    return NextResponse.json(
      { error: 'Supabase service is not configured', details: e instanceof Error ? e.message : String(e) },
      { status: 500 }
    );
  }

  const body = (await req.json().catch(() => null)) as BodyScanRequest | null;
  if (!body) return NextResponse.json({ error: 'Malformed request body' }, { status: 400 });

  const frontPhotoBase64 = typeof body.frontPhotoBase64 === 'string' ? body.frontPhotoBase64 : '';
  const rightPhotoBase64 = typeof body.rightPhotoBase64 === 'string' ? body.rightPhotoBase64 : '';
  if (!frontPhotoBase64 || !rightPhotoBase64) {
    return NextResponse.json({ error: 'Both a front and a right-side photo are required' }, { status: 400 });
  }
  if (
    frontPhotoBase64.length > MAX_PHOTO_BASE64_CHARS ||
    rightPhotoBase64.length > MAX_PHOTO_BASE64_CHARS
  ) {
    return NextResponse.json(
      { error: 'Photos are too large. Capture at 1080p or downscale before upload.' },
      { status: 413 }
    );
  }

  const age = finiteNumber(body.age);
  const heightCm = finiteNumber(body.heightCm);
  const weightKg = finiteNumber(body.weightKg);
  const gender = body.gender === 'male' || body.gender === 'female' ? (body.gender as BodygramGender) : null;

  if (age === null || age < MIN_AGE || age > MAX_AGE) {
    return NextResponse.json(
      { error: 'Body scanning is only available to users aged 18 and over', code: 'ageNotEligible' },
      { status: 403 }
    );
  }
  if (!gender) {
    // The vendor's model only accepts male or female. Users who record
    // anything else pick which model to estimate against in the scan flow.
    return NextResponse.json({ error: 'gender must be male or female', code: 'genderRequired' }, { status: 400 });
  }

  const heightMm = heightCm === null ? null : Math.round(heightCm * 10);
  const weightG = weightKg === null ? null : Math.round(weightKg * 1000);
  if (heightMm === null || heightMm < MIN_HEIGHT_MM || heightMm > MAX_HEIGHT_MM) {
    return NextResponse.json({ error: 'height is out of range', code: 'heightOutOfRange' }, { status: 400 });
  }
  if (weightG === null || weightG < MIN_WEIGHT_G || weightG > MAX_WEIGHT_G) {
    return NextResponse.json({ error: 'weight is out of range', code: 'weightOutOfRange' }, { status: 400 });
  }

  // Reserve quota before spending vendor credit; refunded below if the scan
  // fails for a reason the user can fix.
  const { data: quotaRows, error: quotaError } = await supabase.rpc('consume_body_scan_quota', {
    p_user_id: user.uid,
  });
  if (quotaError) {
    return NextResponse.json(
      { error: 'Could not check your scan allowance', details: quotaError.message },
      { status: 500 }
    );
  }

  const quota = Array.isArray(quotaRows) ? quotaRows[0] : quotaRows;
  if (!quota?.allowed) {
    return NextResponse.json(
      { error: 'Scan allowance used', code: 'quotaExhausted', resetsAt: quota?.resets_at ?? null },
      { status: 402 }
    );
  }

  const refundQuota = async () => {
    const { error } = await supabase.rpc('refund_body_scan_quota', { p_user_id: user.uid });
    if (error) console.error('[body-scan] quota refund failed:', error.message);
  };

  const scanRowId = randomUUID();

  let entry;
  try {
    entry = await createPhotoScan({
      age,
      gender,
      heightMm,
      weightG,
      frontPhotoBase64,
      rightPhotoBase64,
      customScanId: scanRowId,
    });
  } catch (e) {
    await refundQuota();

    if (e instanceof BodygramScanFailure) {
      // The photos were unusable. The app turns the category into retake
      // guidance, so this is a 422 rather than a server error.
      return NextResponse.json(
        { error: 'Scan could not be produced from these photos', code: e.code, category: e.category },
        { status: 422 }
      );
    }
    if (e instanceof BodygramRequestError) {
      console.error('[body-scan] vendor request failed:', e.status, e.body);
      return NextResponse.json(
        { error: e.status === 429 ? 'Scanning is temporarily unavailable' : 'Scanning failed' },
        { status: e.status === 429 ? 503 : 502 }
      );
    }

    console.error('[body-scan] unexpected vendor error:', e);
    return NextResponse.json({ error: 'Scanning failed' }, { status: 502 });
  }

  // Convert and store the mesh. A mesh problem must not lose the metrics, so
  // every failure past this point degrades to a scan without a 3D model.
  let meshPath: string | null = null;
  if (entry.avatar?.data) {
    try {
      const raw = Buffer.from(entry.avatar.data, 'base64');
      const glb =
        entry.avatar.format?.toLowerCase() === 'glb'
          ? raw
          : objToGlb(raw.toString('utf8')).glb;

      const path = `${user.uid}/${scanRowId}.glb`;
      const { error } = await supabase.storage.from(MESH_BUCKET).upload(path, glb, {
        contentType: 'model/gltf-binary',
        upsert: true,
      });
      if (error) throw new Error(error.message);
      meshPath = path;
    } catch (e) {
      console.error(
        '[body-scan] mesh unavailable:',
        e instanceof ObjParseError ? `OBJ parse failed: ${e.message}` : e
      );
    }
  }

  const measurements = Array.isArray(entry.measurements) ? entry.measurements : [];
  const composition = entry.bodyComposition ?? null;

  const { data: inserted, error: insertError } = await supabase
    .from('body_scans')
    .insert({
      id: scanRowId,
      user_id: user.uid,
      vendor: 'bodygram',
      vendor_scan_id: entry.id,
      age: Math.round(age),
      gender,
      height_mm: heightMm,
      weight_g: weightG,
      body_fat_pct: composition?.bodyFatPercentage?.value ?? null,
      lean_mass_g: composition?.leanMass?.value ?? null,
      body_fat_mass_g: composition?.bodyFatMass?.value ?? null,
      measurements,
      posture: entry.posture ?? null,
      mesh_path: meshPath,
    })
    .select()
    .single();

  if (insertError) {
    return NextResponse.json(
      { error: 'Scan succeeded but could not be saved', details: insertError.message },
      { status: 500 }
    );
  }

  let meshUrl: string | null = null;
  if (meshPath) {
    const { data: signed } = await supabase.storage
      .from(MESH_BUCKET)
      .createSignedUrl(meshPath, MESH_URL_TTL_SECONDS);
    meshUrl = signed?.signedUrl ?? null;
  }

  return NextResponse.json({
    scan: {
      id: inserted.id,
      scannedAt: inserted.scanned_at,
      bodyFatPercentage: composition?.bodyFatPercentage?.value ?? null,
      leanMassG: composition?.leanMass?.value ?? null,
      bodyFatMassG: composition?.bodyFatMass?.value ?? null,
      waistGirthMm: findMeasurement(measurements, 'waistGirth'),
      hipGirthMm: findMeasurement(measurements, 'hipGirth'),
      bustGirthMm: findMeasurement(measurements, 'bustGirth'),
      measurements,
      meshUrl,
    },
    quota: { remaining: quota.remaining, resetsAt: quota.resets_at },
  });
}

/** Scan history, newest first, for the trend chart and the history list. */
export async function GET(req: NextRequest) {
  const user = await verifyFirebaseUser(req);
  if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  let supabase: ReturnType<typeof getSupabaseAdmin>;
  try {
    supabase = getSupabaseAdmin();
  } catch (e) {
    return NextResponse.json(
      { error: 'Supabase service is not configured', details: e instanceof Error ? e.message : String(e) },
      { status: 500 }
    );
  }

  const limitParam = Number(req.nextUrl.searchParams.get('limit'));
  const limit = Number.isFinite(limitParam) ? Math.min(Math.max(limitParam, 1), 50) : 20;

  const { data, error } = await supabase
    .from('body_scans')
    .select('id, scanned_at, body_fat_pct, lean_mass_g, body_fat_mass_g, weight_g, measurements, mesh_path')
    .eq('user_id', user.uid)
    .order('scanned_at', { ascending: false })
    .limit(limit);

  if (error) {
    return NextResponse.json({ error: 'Could not load scans', details: error.message }, { status: 500 });
  }

  const scans = await Promise.all(
    (data ?? []).map(async (row) => {
      let meshUrl: string | null = null;
      if (row.mesh_path) {
        const { data: signed } = await supabase.storage
          .from(MESH_BUCKET)
          .createSignedUrl(row.mesh_path, MESH_URL_TTL_SECONDS);
        meshUrl = signed?.signedUrl ?? null;
      }

      const measurements = Array.isArray(row.measurements)
        ? (row.measurements as BodygramMeasurement[])
        : [];

      return {
        id: row.id,
        scannedAt: row.scanned_at,
        bodyFatPercentage: row.body_fat_pct,
        leanMassG: row.lean_mass_g,
        bodyFatMassG: row.body_fat_mass_g,
        weightG: row.weight_g,
        waistGirthMm: findMeasurement(measurements, 'waistGirth'),
        hipGirthMm: findMeasurement(measurements, 'hipGirth'),
        bustGirthMm: findMeasurement(measurements, 'bustGirth'),
        meshUrl,
      };
    })
  );

  return NextResponse.json({ scans });
}
