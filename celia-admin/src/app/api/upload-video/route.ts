import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

const CLOUDFLARE_ACCOUNT_ID = process.env.CLOUDFLARE_ACCOUNT_ID;
const CLOUDFLARE_API_TOKEN = process.env.CLOUDFLARE_STREAM_API_TOKEN;

export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData();
    
    const file = formData.get('file') as File;
    const title = formData.get('title') as string;
    const description = formData.get('description') as string;
    const category = formData.get('category') as string;
    const bodyPart = formData.get('bodyPart') as string;
    const difficulty = formData.get('difficulty') as string;
    const equipment = formData.get('equipment') as string;

    if (!file) {
      return NextResponse.json({ error: 'No file provided' }, { status: 400 });
    }
    if (!CLOUDFLARE_ACCOUNT_ID || !CLOUDFLARE_API_TOKEN) {
      return NextResponse.json(
        { error: 'Cloudflare Stream is not configured (missing CLOUDFLARE_ACCOUNT_ID or CLOUDFLARE_STREAM_API_TOKEN)' },
        { status: 500 }
      );
    }

    // Step 1: Get direct upload URL from Cloudflare
    const directUploadResponse = await fetch(
      `https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/stream/direct_upload`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${CLOUDFLARE_API_TOKEN}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          // Allow longer clips; Cloudflare will still enforce account limits and reject unsupported media.
          maxDurationSeconds: 3600,
          meta: {
            name: title,
          },
        }),
      }
    );

    const directUploadData = await directUploadResponse.json();

    if (!directUploadData.success) {
      console.error('Cloudflare error:', directUploadData);
      return NextResponse.json(
        { error: 'Failed to get upload URL from Cloudflare' },
        { status: 500 }
      );
    }

    const { uploadURL, uid } = directUploadData.result;

    // Step 2: Upload the video to Cloudflare
    const uploadFormData = new FormData();
    uploadFormData.append('file', file);

    const uploadResponse = await fetch(uploadURL, {
      method: 'POST',
      body: uploadFormData,
    });

    if (!uploadResponse.ok) {
      return NextResponse.json(
        { error: 'Failed to upload video to Cloudflare' },
        { status: 500 }
      );
    }

    // Step 3: Get video details (playback URL, etc.)
    // Wait a moment for Cloudflare to process
    await new Promise(resolve => setTimeout(resolve, 2000));

    const videoDetailsResponse = await fetch(
      `https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/stream/${uid}`,
      {
        headers: {
          'Authorization': `Bearer ${CLOUDFLARE_API_TOKEN}`,
        },
      }
    );

    const videoDetails = await videoDetailsResponse.json();
    const playbackUrl = videoDetails.result?.playback?.hls || 
                        `https://customer-${CLOUDFLARE_ACCOUNT_ID}.cloudflarestream.com/${uid}/manifest/video.m3u8`;
    // Prefer videodelivery.net (works across accounts without embedding account id)
    const thumbnailUrl = videoDetails.result?.thumbnail || `https://videodelivery.net/${uid}/thumbnails/thumbnail.jpg`;
    const durationRaw = videoDetails.result?.duration ?? 0;
    const durationNum = typeof durationRaw === 'number' ? durationRaw : Number(durationRaw);
    const duration = Number.isFinite(durationNum) && durationNum > 0 ? durationNum : 0;
    const state = (videoDetails.result?.status?.state || '').toString().toLowerCase();
    const status =
      state === 'ready' ? 'ready' :
      state === 'error' ? 'error' :
      // inprogress / queued / unknown -> processing
      'processing';

    // Step 4: Save to Supabase
    const { data: video, error: dbError } = await supabase
      .from('videos')
      .insert({
        title,
        description,
        category: category || 'general',
        body_part: bodyPart || 'full_body',
        difficulty: difficulty?.toLowerCase() || 'beginner',
        duration_seconds: Math.round(duration),
        cloudflare_video_id: uid,
        playback_url: playbackUrl,
        thumbnail_url: thumbnailUrl,
        equipment: equipment ? JSON.parse(equipment) : [],
        is_ai_generated: false,
        // Cloudflare may still be processing right after upload; keep status accurate so the dashboard doesn't try to play too early.
        status,
        uploaded_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (dbError) {
      console.error('Database error:', dbError);
      return NextResponse.json(
        { error: 'Failed to save video metadata' },
        { status: 500 }
      );
    }

    return NextResponse.json({
      success: true,
      video: {
        id: video.id,
        cloudflareId: uid,
        title,
        playbackUrl,
        thumbnailUrl,
      },
      message: 'Video uploaded successfully!',
    });

  } catch (error: any) {
    console.error('Upload error:', error);
    return NextResponse.json(
      { error: 'Upload failed', details: error.message },
      { status: 500 }
    );
  }
}

