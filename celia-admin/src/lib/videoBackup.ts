import type { SupabaseClient } from '@supabase/supabase-js';

export const DEFAULT_BACKUP_BUCKET =
  process.env.SUPABASE_VIDEO_BACKUP_BUCKET || 'video-backups';

function sanitizeSegment(value: string): string {
  return value
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9\-_.]+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '')
    .slice(0, 80);
}

function extractExtension(fileName?: string): string {
  const candidate = (fileName || '').trim().toLowerCase();
  const idx = candidate.lastIndexOf('.');
  if (idx <= 0 || idx >= candidate.length - 1) return 'mp4';
  const ext = candidate.slice(idx + 1).replace(/[^a-z0-9]/g, '');
  return ext || 'mp4';
}

export function buildBackupPath(opts: {
  title: string;
  originalFileName?: string;
}): string {
  const datePrefix = new Date().toISOString().slice(0, 10);
  const safeTitle = sanitizeSegment(opts.title || 'video');
  const ext = extractExtension(opts.originalFileName);
  const randomPart = crypto.randomUUID();
  return `${datePrefix}/${safeTitle}-${randomPart}.${ext}`;
}

export async function ensureBackupBucket(
  supabase: SupabaseClient,
  bucket = DEFAULT_BACKUP_BUCKET
): Promise<string> {
  const { data: existing, error: readErr } = await supabase.storage.getBucket(
    bucket
  );
  if (existing && !readErr) return bucket;

  const { error: createErr } = await supabase.storage.createBucket(bucket, {
    public: false,
    fileSizeLimit: '2GB',
  });

  // Ignore "already exists" race and proceed.
  if (createErr && !createErr.message.toLowerCase().includes('already')) {
    throw createErr;
  }

  return bucket;
}

export type BackupUploadTicket = {
  bucket: string;
  path: string;
  token: string;
};

export async function createBackupUploadTicket(
  supabase: SupabaseClient,
  opts: { title: string; originalFileName?: string; bucket?: string }
): Promise<BackupUploadTicket> {
  const bucket = await ensureBackupBucket(
    supabase,
    opts.bucket || DEFAULT_BACKUP_BUCKET
  );
  const path = buildBackupPath({
    title: opts.title,
    originalFileName: opts.originalFileName,
  });

  const { data, error } = await supabase.storage
    .from(bucket)
    .createSignedUploadUrl(path);

  if (error || !data?.token) {
    throw error ?? new Error('Failed to create backup upload ticket');
  }

  return {
    bucket,
    path,
    token: data.token,
  };
}

export async function createBackupDownloadUrl(
  supabase: SupabaseClient,
  bucket: string,
  path: string,
  expiresInSeconds = 60 * 30
): Promise<string | null> {
  const b = (bucket || '').trim();
  const p = (path || '').trim();
  if (!b || !p) return null;

  const { data, error } = await supabase.storage
    .from(b)
    .createSignedUrl(p, expiresInSeconds);

  if (error || !data?.signedUrl) return null;
  return data.signedUrl;
}
