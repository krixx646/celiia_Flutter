import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
import { buildBackupPath, ensureBackupBucket } from '@/lib/videoBackup';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

const CLOUDFLARE_ACCOUNT_ID = process.env.CLOUDFLARE_ACCOUNT_ID;
const CLOUDFLARE_API_TOKEN = process.env.CLOUDFLARE_STREAM_API_TOKEN;

function isMissingColumnError(error: unknown): boolean {
  const msg =
    typeof error === 'object' && error !== null && 'message' in error
      ? String((error as { message?: unknown }).message ?? '')
      : String(error ?? '');
  return msg.toLowerCase().includes('column') && msg.toLowerCase().includes('does not exist');
}

function parseEquipment(raw: string): string[] {
  if (!raw) return [];
  try {
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed.map((x) => String(x)) : [];
  } catch {
    return [];
  }
}

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

    let backupBucket: string | null = null;
    let backupPath: string | null = null;
    try {
      backupBucket = await ensureBackupBucket(supabase);
      backupPath = buildBackupPath({
        title: title || file.name || 'video',
        originalFileName: file.name,
      });
      const arrayBuffer = await file.arrayBuffer();
      const { error: backupError } = await supabase.storage
        .from(backupBucket)
        .upload(backupPath, arrayBuffer, {
          contentType: file.type || 'video/mp4',
          upsert: false,
        });
      if (backupError) {
        throw backupError;
      }
    } catch (backupErr) {
      console.error('Backup upload failed:', backupErr);
      backupBucket = null;
      backupPath = null;
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

    const directUploadData: unknown = await directUploadResponse.json();
    const cfUpload =
      typeof directUploadData === 'object' && directUploadData !== null
        ? (directUploadData as { success?: boolean; result?: { uploadURL?: string; uid?: string } })
        : {};

    if (!cfUpload.success || !cfUpload.result?.uploadURL || !cfUpload.result?.uid) {
      console.error('Cloudflare error:', directUploadData);
      return NextResponse.json(
        { error: 'Failed to get upload URL from Cloudflare' },
        { status: 500 }
      );
    }

    const { uploadURL, uid } = cfUpload.result;

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

    const videoDetailsRaw: unknown = await videoDetailsResponse.json();
    const videoDetails =
      typeof videoDetailsRaw === 'object' && videoDetailsRaw !== null
        ? (videoDetailsRaw as {
            result?: {
              playback?: { hls?: string };
              thumbnail?: string;
              duration?: number | string;
              status?: { state?: string };
            };
          })
        : {};
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
    const basePayload: Record<string, unknown> = {
      title,
      description,
      category: category || 'general',
      body_part: bodyPart || 'full_body',
      difficulty: difficulty?.toLowerCase() || 'beginner',
      duration_seconds: Math.round(duration),
      cloudflare_video_id: uid,
      playback_url: playbackUrl,
      thumbnail_url: thumbnailUrl,
      equipment: parseEquipment(equipment),
      is_ai_generated: false,
      // Cloudflare may still be processing right after upload; keep status accurate so the dashboard doesn't try to play too early.
      status,
      uploaded_at: new Date().toISOString(),
    };

    const payloadWithBackup: Record<string, unknown> = {
      ...basePayload,
      source_url: null,
      backup_bucket: backupBucket,
      backup_path: backupPath,
    };

    let insertResult = await supabase
      .from('videos')
      .insert(payloadWithBackup)
      .select()
      .single();

    if (insertResult.error && isMissingColumnError(insertResult.error)) {
      insertResult = await supabase
        .from('videos')
        .insert(basePayload)
        .select()
        .single();
    }

    const { data: video, error: dbError } = insertResult;

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
      backup: backupBucket && backupPath ? { bucket: backupBucket, path: backupPath } : null,
      message: 'Video uploaded successfully!',
    });

  } catch (error: unknown) {
    console.error('Upload error:', error);
    return NextResponse.json(
      {
        error: 'Upload failed',
        details: error instanceof Error ? error.message : String(error),
      },
      { status: 500 }
    );
  }
}

