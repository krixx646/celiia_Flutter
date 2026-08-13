-- Demo clip library for the guided, voice-coached workout player.
--
-- This is the client's filmed exercise library: one short clip per exercise,
-- looped by the player until the prescribed reps are done. It is deliberately
-- a separate table from `exercise_media` (the stock GIF pack, now suspended)
-- and from `videos` (the Cloudflare pipeline), so all three can coexist and
-- the player can fall back between them without any of the data mixing.
--
-- The columns beyond the media URLs are what make voice coaching possible:
-- the player has to know whether an exercise is counted or held, and how many
-- reps one loop of the clip is worth, before it can count along out loud.
--
-- Run this in the Supabase SQL editor.

CREATE TABLE IF NOT EXISTS exercise_clips (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug TEXT NOT NULL UNIQUE,

    name_en TEXT NOT NULL,
    name_es TEXT NOT NULL,

    -- Movement pattern the clip belongs to, taken from the client's own
    -- folder structure: squat, hinge, lunge, push, pull, carry, core, recovery.
    pattern TEXT NOT NULL,

    video_url TEXT NOT NULL,
    poster_url TEXT,

    -- 'reps' exercises are counted out loud; 'hold' exercises run a countdown.
    step_type TEXT NOT NULL CHECK (step_type IN ('reps', 'hold')),

    -- How many complete reps one play of the clip shows. Lets the player loop
    -- the clip the right number of times for the prescribed reps and keep the
    -- spoken count in step with the video. Null for holds.
    reps_per_loop INTEGER CHECK (reps_per_loop IS NULL OR reps_per_loop > 0),

    -- Length of one loop, so rest and set duration can be worked out up front.
    clip_seconds NUMERIC(5, 2) NOT NULL,

    -- What the exercise needs. Empty array means true bodyweight, which is how
    -- the generator filters for people training with nothing at home.
    equipment TEXT[] NOT NULL DEFAULT '{}',

    -- Sensible starting prescription when nothing more specific is asked for.
    default_reps INTEGER,
    default_hold_seconds INTEGER,

    orientation TEXT NOT NULL DEFAULT 'square',
    is_active BOOLEAN NOT NULL DEFAULT true,
    source TEXT NOT NULL DEFAULT 'client_clip_pack_v1',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- A rep exercise needs a rep prescription and a hold needs a duration;
    -- anything else would leave the player with nothing to count.
    CONSTRAINT exercise_clips_prescription_present CHECK (
        (step_type = 'reps' AND reps_per_loop IS NOT NULL AND default_reps IS NOT NULL)
        OR (step_type = 'hold' AND default_hold_seconds IS NOT NULL)
    )
);

CREATE INDEX IF NOT EXISTS exercise_clips_pattern_idx ON exercise_clips (pattern);
CREATE INDEX IF NOT EXISTS exercise_clips_equipment_idx ON exercise_clips USING GIN (equipment);

ALTER TABLE exercise_clips ENABLE ROW LEVEL SECURITY;

-- The library is public reference data: every signed-in user reads it, and
-- only the seed script (service role) ever writes it.
DROP POLICY IF EXISTS "Exercise clips are readable by everyone" ON exercise_clips;
CREATE POLICY "Exercise clips are readable by everyone"
    ON exercise_clips FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Only the service role can write exercise clips" ON exercise_clips;
CREATE POLICY "Only the service role can write exercise clips"
    ON exercise_clips FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');
