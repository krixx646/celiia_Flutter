-- ============================================================================
-- CELIA APP - DATABASE MIGRATION
-- ============================================================================
-- Run this SQL in your Supabase SQL Editor to add new columns for video metadata
-- Go to: Supabase Dashboard > SQL Editor > New Query > Paste & Run
-- ============================================================================

-- Step 1: Add new columns to videos table
ALTER TABLE videos 
ADD COLUMN IF NOT EXISTS body_part TEXT,
ADD COLUMN IF NOT EXISTS difficulty TEXT DEFAULT 'beginner',
ADD COLUMN IF NOT EXISTS equipment TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS is_ai_generated BOOLEAN DEFAULT false;

-- Step 2: Handle stream_id -> cloudflare_video_id rename
-- First check if stream_id exists and rename it
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'videos' AND column_name = 'stream_id') THEN
        ALTER TABLE videos RENAME COLUMN stream_id TO cloudflare_video_id;
    END IF;
END $$;

-- Step 3: Add cloudflare_video_id if it doesn't exist
ALTER TABLE videos 
ADD COLUMN IF NOT EXISTS cloudflare_video_id TEXT;

-- Step 4: Drop NOT NULL constraint on cloudflare_video_id (for AI-generated videos)
ALTER TABLE videos 
ALTER COLUMN cloudflare_video_id DROP NOT NULL;

-- Step 5: Make playback_url nullable
DO $$
BEGIN
    ALTER TABLE videos ALTER COLUMN playback_url DROP NOT NULL;
EXCEPTION
    WHEN others THEN NULL;
END $$;

-- Step 6: Make uploaded_by nullable with default
DO $$
BEGIN
    ALTER TABLE videos ALTER COLUMN uploaded_by DROP NOT NULL;
    ALTER TABLE videos ALTER COLUMN uploaded_by SET DEFAULT 'admin';
EXCEPTION
    WHEN others THEN NULL;
END $$;

-- Step 7: Create indexes for new columns
CREATE INDEX IF NOT EXISTS idx_videos_body_part ON videos(body_part);
CREATE INDEX IF NOT EXISTS idx_videos_difficulty ON videos(difficulty);
CREATE INDEX IF NOT EXISTS idx_videos_ai_generated ON videos(is_ai_generated);

-- ============================================================================
-- UPDATE RLS POLICIES
-- ============================================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow public read on videos" ON videos;
DROP POLICY IF EXISTS "Allow service role insert on videos" ON videos;
DROP POLICY IF EXISTS "Allow service role update on videos" ON videos;
DROP POLICY IF EXISTS "Allow service role delete on videos" ON videos;
DROP POLICY IF EXISTS "Allow anon read on videos" ON videos;

-- Enable RLS on videos
ALTER TABLE videos ENABLE ROW LEVEL SECURITY;

-- Allow public read access to all videos
CREATE POLICY "Allow public read on videos"
ON videos FOR SELECT
TO public
USING (true);

-- Allow service role (admin dashboard) full access
CREATE POLICY "Allow service role insert on videos"
ON videos FOR INSERT
TO service_role
WITH CHECK (true);

CREATE POLICY "Allow service role update on videos"
ON videos FOR UPDATE
TO service_role
USING (true);

CREATE POLICY "Allow service role delete on videos"
ON videos FOR DELETE
TO service_role
USING (true);

-- Also allow anon to read for the dashboard (since we're using anon key in client)
CREATE POLICY "Allow anon read on videos"
ON videos FOR SELECT
TO anon
USING (true);

-- ============================================================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================================================

-- Insert sample videos if table is empty
INSERT INTO videos (title, description, category, body_part, difficulty, duration_seconds, status, is_ai_generated, uploaded_at, cloudflare_video_id, uploaded_by)
SELECT 
    'Lateral Arm Raises',
    'Shoulder strengthening exercise with proper form demonstration',
    'strength',
    'shoulders',
    'beginner',
    10,
    'ready',
    false,
    NOW(),
    'sample-' || gen_random_uuid()::text,
    'admin'
WHERE NOT EXISTS (SELECT 1 FROM videos WHERE title = 'Lateral Arm Raises');

INSERT INTO videos (title, description, category, body_part, difficulty, duration_seconds, status, is_ai_generated, uploaded_at, cloudflare_video_id, uploaded_by)
SELECT 
    'Basic Squats',
    'Lower body exercise targeting quads and glutes',
    'strength',
    'legs',
    'beginner',
    10,
    'ready',
    false,
    NOW() - INTERVAL '1 hour',
    'sample-' || gen_random_uuid()::text,
    'admin'
WHERE NOT EXISTS (SELECT 1 FROM videos WHERE title = 'Basic Squats');

INSERT INTO videos (title, description, category, body_part, difficulty, duration_seconds, status, is_ai_generated, uploaded_at, cloudflare_video_id, uploaded_by)
SELECT 
    'Plank Hold',
    'Core stability exercise',
    'strength',
    'core',
    'intermediate',
    10,
    'ready',
    false,
    NOW() - INTERVAL '2 hours',
    'sample-' || gen_random_uuid()::text,
    'admin'
WHERE NOT EXISTS (SELECT 1 FROM videos WHERE title = 'Plank Hold');

INSERT INTO videos (title, description, category, body_part, difficulty, duration_seconds, status, is_ai_generated, uploaded_at, cloudflare_video_id, uploaded_by)
SELECT 
    'Jumping Jacks',
    'Full body cardio warmup exercise',
    'cardio',
    'full_body',
    'beginner',
    10,
    'ready',
    false,
    NOW() - INTERVAL '3 hours',
    'sample-' || gen_random_uuid()::text,
    'admin'
WHERE NOT EXISTS (SELECT 1 FROM videos WHERE title = 'Jumping Jacks');

-- ============================================================================
-- VERIFICATION
-- ============================================================================
-- Run this to verify the changes:
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'videos'
ORDER BY ordinal_position;
