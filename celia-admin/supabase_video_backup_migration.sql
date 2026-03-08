-- ============================================================================
-- CELIA ADMIN - VIDEO BACKUP METADATA + STORAGE BUCKET
-- ============================================================================
-- Run in Supabase SQL Editor for the same project used by celia-admin.
-- ============================================================================

-- 1) Track original/recoverable source metadata per video row.
ALTER TABLE videos
ADD COLUMN IF NOT EXISTS source_url TEXT,
ADD COLUMN IF NOT EXISTS backup_bucket TEXT,
ADD COLUMN IF NOT EXISTS backup_path TEXT;

CREATE INDEX IF NOT EXISTS idx_videos_backup_path ON videos (backup_path);
CREATE INDEX IF NOT EXISTS idx_videos_source_url ON videos (source_url);

-- 2) Create private storage bucket used for raw video backups.
--    The server uses service-role and signed URLs, so this stays private.
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('video-backups', 'video-backups', false, 2147483648)
ON CONFLICT (id) DO NOTHING;
