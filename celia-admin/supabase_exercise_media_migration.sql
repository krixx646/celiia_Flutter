-- ============================================================================
-- CELIA APP - EXERCISE MEDIA LIBRARY MIGRATION
-- ============================================================================
-- Run this SQL in your Supabase SQL Editor to add the exercise_media table.
-- Go to: Supabase Dashboard > SQL Editor > New Query > Paste & Run
--
-- Purpose: shared, reusable exercise reference library. Used as a TEMPORARY
-- fallback visual (stock GIF) for routine steps that don't have a real
-- filmed video yet. Real Cloudflare Stream videos always take priority when
-- available — this table never overrides or replaces the `videos` table.
--
-- Because it's keyed by `slug` (not by routine/step), swapping a stock GIF
-- for the real filmed video later is a single UPDATE on one row instead of
-- hunting through every routine that references that exercise.
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS exercise_media (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    muscle_group TEXT,
    category TEXT NOT NULL CHECK (category IN (
        'strength', 'calisthenics', 'functional_hiit', 'stretching_mobility'
    )),
    gif_url TEXT,
    is_placeholder BOOLEAN NOT NULL DEFAULT true,
    source TEXT DEFAULT 'stock_pack_v1',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_exercise_media_slug ON exercise_media(slug);
CREATE INDEX IF NOT EXISTS idx_exercise_media_category ON exercise_media(category);
CREATE INDEX IF NOT EXISTS idx_exercise_media_muscle_group ON exercise_media(muscle_group);
CREATE INDEX IF NOT EXISTS idx_exercise_media_placeholder ON exercise_media(is_placeholder);

-- Let the mobile app (anon key) read this table directly — it's a public
-- reference library, not user data.
ALTER TABLE exercise_media ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read access to exercise_media" ON exercise_media;
CREATE POLICY "Public read access to exercise_media"
    ON exercise_media FOR SELECT
    USING (true);

-- Writes only via the service role (admin dashboard / seed scripts), never
-- directly from the app.
