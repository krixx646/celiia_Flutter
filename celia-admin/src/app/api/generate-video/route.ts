import { NextRequest, NextResponse } from 'next/server';
import { fal } from '@fal-ai/client';
import { createClient } from '@supabase/supabase-js';

export const runtime = 'nodejs';
export const maxDuration = 300;

// Initialize fal.ai
fal.config({
  credentials: process.env.FAL_KEY,
});

// Initialize Supabase with service role for admin operations
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

const CLOUDFLARE_ACCOUNT_ID = process.env.CLOUDFLARE_ACCOUNT_ID;
const CLOUDFLARE_API_TOKEN = process.env.CLOUDFLARE_STREAM_API_TOKEN;

interface GenerateRequest {
  prompt: string;
  exerciseName: string;
  bodyPart: string;
  difficulty: string;
  exerciseType: string;
  duration: number;
  aspectRatio: '16:9' | '9:16' | '1:1';
  includeAudio?: boolean;
}

async function copyToCloudflareStream(url: string, title: string) {
  if (!CLOUDFLARE_ACCOUNT_ID || !CLOUDFLARE_API_TOKEN) return null;

  try {
    const res = await fetch(
      `https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/stream/copy`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${CLOUDFLARE_API_TOKEN}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          url,
          meta: { name: title },
        }),
      }
    );
    const json: any = await res.json();
    if (!json?.success) {
      console.error('Cloudflare copy failed:', json);
      return null;
    }
    const uid =
      json?.result?.uid ||
      json?.result?.result?.uid ||
      json?.result?.id ||
      json?.result?.video?.uid ||
      json?.result?.video?.id;
    return typeof uid === 'string' && uid.length > 0 ? uid : null;
  } catch (e) {
    console.error('Cloudflare copy failed (fetch error):', e);
    return null;
  }
}

async function createCloudflareDirectUpload(title: string) {
  if (!CLOUDFLARE_ACCOUNT_ID || !CLOUDFLARE_API_TOKEN) return null;
  const res = await fetch(
    `https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/stream/direct_upload`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${CLOUDFLARE_API_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        maxDurationSeconds: 600,
        meta: { name: title },
      }),
    }
  );
  const json: any = await res.json();
  if (!json?.success) {
    console.error('Cloudflare direct_upload failed:', json);
    return null;
  }
  const uploadURL = json?.result?.uploadURL;
  const uid = json?.result?.uid;
  if (typeof uploadURL !== 'string' || typeof uid !== 'string') return null;
  return { uploadURL, uid };
}

async function uploadRemoteVideoToCloudflare(uploadURL: string, sourceUrl: string, filename: string) {
  const srcRes = await fetch(sourceUrl);
  if (!srcRes.ok) {
    const text = await srcRes.text().catch(() => '');
    throw new Error(`Failed to download generated video (${srcRes.status}): ${text.slice(0, 200)}`);
  }
  const arrayBuffer = await srcRes.arrayBuffer();
  const contentType = srcRes.headers.get('content-type') || 'video/mp4';
  const blob = new Blob([arrayBuffer], { type: contentType });
  const form = new FormData();
  form.append('file', blob, filename);
  const upRes = await fetch(uploadURL, { method: 'POST', body: form });
  if (!upRes.ok) {
    const text = await upRes.text().catch(() => '');
    throw new Error(`Cloudflare upload failed (${upRes.status}): ${text.slice(0, 200)}`);
  }
}

async function ingestIntoCloudflareStream(opts: { sourceUrl: string; title: string }) {
  const { sourceUrl, title } = opts;
  const copiedUid = await copyToCloudflareStream(sourceUrl, title);
  if (copiedUid) return copiedUid;

  const du = await createCloudflareDirectUpload(title);
  if (!du) return null;
  await uploadRemoteVideoToCloudflare(du.uploadURL, sourceUrl, `${title || 'celia-video'}.mp4`);
  return du.uid;
}

async function fetchCloudflareDetails(uid: string) {
  if (!CLOUDFLARE_ACCOUNT_ID || !CLOUDFLARE_API_TOKEN) return null;
  const res = await fetch(
    `https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/stream/${uid}`,
    {
      headers: {
        Authorization: `Bearer ${CLOUDFLARE_API_TOKEN}`,
      },
    }
  );
  const json: any = await res.json();
  if (!json?.success) return null;
  return json?.result ?? null;
}

async function waitForCloudflareReady(uid: string, timeoutMs: number) {
  const started = Date.now();
  while (Date.now() - started < timeoutMs) {
    const details = await fetchCloudflareDetails(uid);
    const state = details?.status?.state as string | undefined;
    if (state === 'ready') return { state: 'ready' as const, details };
    if (state === 'error') return { state: 'error' as const, details };
    await new Promise((r) => setTimeout(r, 1000));
  }
  const details = await fetchCloudflareDetails(uid);
  return { state: (details?.status?.state as string | undefined) ?? 'unknown', details };
}

export async function POST(request: NextRequest) {
  try {
    const body: GenerateRequest = await request.json();
    
    const { prompt, exerciseName, bodyPart, difficulty, exerciseType, duration, aspectRatio, includeAudio } = body;

    if (!prompt || !exerciseName) {
      return NextResponse.json(
        { error: 'Prompt and exercise name are required' },
        { status: 400 }
      );
    }

    // Check if FAL_KEY is configured
    if (!process.env.FAL_KEY) {
      return NextResponse.json(
        { 
          error: 'fal.ai API key not configured',
          message: 'Please add FAL_KEY to your .env.local file. Get your key from https://fal.ai/dashboard/keys'
        },
        { status: 500 }
      );
    }

    // Dashboard playback uses Cloudflare Stream iframe. Enforce Cloudflare ingestion so every new video behaves consistently.
    if (!CLOUDFLARE_ACCOUNT_ID || !CLOUDFLARE_API_TOKEN) {
      return NextResponse.json(
        { error: 'Cloudflare Stream is not configured (missing CLOUDFLARE_ACCOUNT_ID or CLOUDFLARE_STREAM_API_TOKEN)' },
        { status: 500 }
      );
    }

    // Verified via fal.ai docs:
    // - Model: fal-ai/kling-video/v2.6/pro/text-to-video
    // - Audio: input `generate_audio` boolean (default true)
    // Allow env override for quick swaps, but default to the v2.6 endpoint.
    const modelToUse = process.env.FAL_KLING_MODEL || 'fal-ai/kling-video/v2.6/pro/text-to-video';

    // Call fal.ai Kling model
    const result = await fal.subscribe(modelToUse, {
      input: {
        prompt: prompt,
        duration: duration <= 5 ? '5' : '10',
        aspect_ratio: aspectRatio,
        generate_audio: Boolean(includeAudio),
      },
      logs: true,
      onQueueUpdate: (update) => {
        console.log('Queue update:', update.status);
      },
    });

    // Get the video URL from result
    const videoUrl = result.data?.video?.url;

    if (!videoUrl) {
      return NextResponse.json(
        { error: 'No video URL in response' },
        { status: 500 }
      );
    }

    const cloudflareUid = await ingestIntoCloudflareStream({ sourceUrl: videoUrl, title: exerciseName });
    if (!cloudflareUid) {
      return NextResponse.json(
        { error: 'Failed to ingest generated video into Cloudflare Stream (no uid returned)' },
        { status: 500 }
      );
    }

    // Save Cloudflare playback + thumbnail in DB so the mobile app can play HLS.
    const playbackUrl: string | null = `https://customer-${CLOUDFLARE_ACCOUNT_ID}.cloudflarestream.com/${cloudflareUid}/manifest/video.m3u8`;
    const thumbnailUrl: string | null = `https://videodelivery.net/${cloudflareUid}/thumbnails/thumbnail.jpg`;

    // Avoid "ready but not actually playable" (mobile app can hang). Wait briefly for Cloudflare to be ready.
    const readyCheck = await waitForCloudflareReady(cloudflareUid, 20000);
    const status: 'pending' | 'processing' | 'ready' | 'error' =
      readyCheck.state === 'ready' ? 'ready' : readyCheck.state === 'error' ? 'error' : 'processing';

    // Save to Supabase videos table
    const { data: video, error: dbError } = await supabase
      .from('videos')
      .insert({
        title: exerciseName,
        description: prompt,
        category: exerciseType,
        body_part: bodyPart,
        difficulty: difficulty.toLowerCase(),
        duration_seconds: duration,
        cloudflare_video_id: cloudflareUid,
        playback_url: playbackUrl,
        thumbnail_url: thumbnailUrl,
        is_ai_generated: true,
        status,
        uploaded_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (dbError) {
      console.error('Database error:', dbError);
      return NextResponse.json(
        { error: 'Failed to save video to database' },
        { status: 500 }
      );
    }

    return NextResponse.json({
      success: true,
      video: {
        id: video.id,
        title: exerciseName,
        videoUrl: videoUrl,
        duration: duration,
      },
      message: 'Video generated successfully!',
    });

  } catch (error: any) {
    console.error('Generation error:', error);
    return NextResponse.json(
      { 
        error: 'Failed to generate video',
        details: error.message 
      },
      { status: 500 }
    );
  }
}

