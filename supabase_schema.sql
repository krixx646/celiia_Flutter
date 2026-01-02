-- ============================================================================
-- CELIA APP - SUPABASE DATABASE SCHEMA
-- ============================================================================
-- Run this SQL in your Supabase SQL Editor to create the required tables
-- Go to: Supabase Dashboard > SQL Editor > New Query > Paste & Run
-- ============================================================================

-- Enable UUID extension (usually already enabled)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- VIDEOS TABLE
-- Stores metadata for videos hosted on Cloudflare Stream
-- ============================================================================
CREATE TABLE IF NOT EXISTS videos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    stream_id TEXT NOT NULL UNIQUE,  -- Cloudflare Stream video ID
    title TEXT NOT NULL,
    description TEXT,
    duration_seconds INTEGER NOT NULL DEFAULT 0,
    thumbnail_url TEXT,
    playback_url TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'ready', 'error')),
    uploaded_by TEXT NOT NULL,  -- 'admin' or user ID
    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    tags TEXT[] DEFAULT '{}',
    category TEXT,
    file_size INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_videos_status ON videos(status);
CREATE INDEX IF NOT EXISTS idx_videos_category ON videos(category);
CREATE INDEX IF NOT EXISTS idx_videos_uploaded_at ON videos(uploaded_at DESC);

-- ============================================================================
-- ROUTINES TABLE
-- Stores fitness routines (both curated and AI-generated)
-- ============================================================================
CREATE TABLE IF NOT EXISTS routines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    duration_minutes INTEGER NOT NULL,
    difficulty TEXT NOT NULL CHECK (difficulty IN ('easy', 'medium', 'hard')),
    category TEXT NOT NULL CHECK (category IN ('strength', 'cardio', 'flexibility', 'mindfulness', 'dance', 'hiit', 'yoga', 'custom')),
    thumbnail_url TEXT,
    steps JSONB NOT NULL DEFAULT '[]',  -- Array of RoutineStep objects
    created_by TEXT NOT NULL,  -- 'admin', 'ai', or user ID
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    is_published BOOLEAN NOT NULL DEFAULT false,
    is_curated BOOLEAN NOT NULL DEFAULT false,  -- true for admin-created
    tags TEXT[] DEFAULT '{}',
    calories_burned INTEGER,
    equipment TEXT
);

-- Indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_routines_published ON routines(is_published);
CREATE INDEX IF NOT EXISTS idx_routines_category ON routines(category);
CREATE INDEX IF NOT EXISTS idx_routines_difficulty ON routines(difficulty);
CREATE INDEX IF NOT EXISTS idx_routines_curated ON routines(is_curated);
CREATE INDEX IF NOT EXISTS idx_routines_created_at ON routines(created_at DESC);

-- ============================================================================
-- USER_ROUTINES TABLE
-- Tracks user's saved/favorited routines and progress
-- ============================================================================
CREATE TABLE IF NOT EXISTS user_routines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT NOT NULL,  -- Firebase Auth UID
    routine_id UUID NOT NULL REFERENCES routines(id) ON DELETE CASCADE,
    saved_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_played_at TIMESTAMPTZ,
    times_completed INTEGER NOT NULL DEFAULT 0,
    is_favorite BOOLEAN NOT NULL DEFAULT false,
    
    -- Ensure a user can only save a routine once
    UNIQUE(user_id, routine_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_user_routines_user ON user_routines(user_id);
CREATE INDEX IF NOT EXISTS idx_user_routines_favorite ON user_routines(user_id, is_favorite);

-- ============================================================================
-- ROUTINE_REQUESTS TABLE
-- Stores AI routine generation requests for history/analytics
-- ============================================================================
CREATE TABLE IF NOT EXISTS routine_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT NOT NULL,
    request_text TEXT NOT NULL,
    generated_routine_id UUID REFERENCES routines(id) ON DELETE SET NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed')),
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_routine_requests_user ON routine_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_routine_requests_status ON routine_requests(status);

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function to increment routine completion count
CREATE OR REPLACE FUNCTION increment_routine_completion(routine_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE user_routines
    SET 
        times_completed = times_completed + 1,
        last_played_at = NOW()
    WHERE id = routine_id;
END;
$$ LANGUAGE plpgsql;

-- Function to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for auto-updating timestamps
CREATE TRIGGER update_videos_updated_at
    BEFORE UPDATE ON videos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_routines_updated_at
    BEFORE UPDATE ON routines
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE routines ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_routines ENABLE ROW LEVEL SECURITY;
ALTER TABLE routine_requests ENABLE ROW LEVEL SECURITY;

-- Videos: Anyone can read, only admins can write
CREATE POLICY "Videos are viewable by everyone" ON videos
    FOR SELECT USING (true);

CREATE POLICY "Videos are insertable by admins" ON videos
    FOR INSERT WITH CHECK (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Videos are updatable by admins" ON videos
    FOR UPDATE USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Videos are deletable by admins" ON videos
    FOR DELETE USING (auth.jwt() ->> 'role' = 'admin');

-- Routines: Anyone can read published, admins can write all
CREATE POLICY "Published routines are viewable by everyone" ON routines
    FOR SELECT USING (is_published = true OR auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Routines are insertable by admins" ON routines
    FOR INSERT WITH CHECK (auth.jwt() ->> 'role' = 'admin' OR created_by = 'ai');

CREATE POLICY "Routines are updatable by admins" ON routines
    FOR UPDATE USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Routines are deletable by admins" ON routines
    FOR DELETE USING (auth.jwt() ->> 'role' = 'admin');

-- User Routines: Users can only access their own
CREATE POLICY "Users can view their own saved routines" ON user_routines
    FOR SELECT USING (auth.uid()::text = user_id);

CREATE POLICY "Users can save routines" ON user_routines
    FOR INSERT WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can update their saved routines" ON user_routines
    FOR UPDATE USING (auth.uid()::text = user_id);

CREATE POLICY "Users can delete their saved routines" ON user_routines
    FOR DELETE USING (auth.uid()::text = user_id);

-- Routine Requests: Users can only access their own
CREATE POLICY "Users can view their own requests" ON routine_requests
    FOR SELECT USING (auth.uid()::text = user_id);

CREATE POLICY "Users can create requests" ON routine_requests
    FOR INSERT WITH CHECK (auth.uid()::text = user_id);

-- ============================================================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================================================

-- Insert a sample curated routine
INSERT INTO routines (title, description, duration_minutes, difficulty, category, is_published, is_curated, created_by, tags, calories_burned, equipment, steps)
VALUES (
    'Morning Energizer',
    'Start your day with this quick full-body wake-up routine. Perfect for getting your blood flowing and mind focused.',
    15,
    'easy',
    'cardio',
    true,
    true,
    'admin',
    ARRAY['morning', 'beginner', 'no-equipment'],
    120,
    'None',
    '[
        {"id": "step1", "title": "Jumping Jacks", "description": "Classic cardio to get your heart pumping", "durationSeconds": 60, "orderIndex": 0},
        {"id": "step2", "title": "High Knees", "description": "Lift those knees high and pump your arms", "durationSeconds": 45, "orderIndex": 1},
        {"id": "step3", "title": "Arm Circles", "description": "Loosen up those shoulders with big arm circles", "durationSeconds": 30, "orderIndex": 2},
        {"id": "step4", "title": "Bodyweight Squats", "description": "Engage your legs and core with controlled squats", "durationSeconds": 60, "orderIndex": 3},
        {"id": "step5", "title": "Mountain Climbers", "description": "Get that heart rate up with this core burner", "durationSeconds": 45, "orderIndex": 4},
        {"id": "step6", "title": "Cool Down Stretch", "description": "Gentle stretches to finish your workout", "durationSeconds": 120, "orderIndex": 5}
    ]'::jsonb
);

-- Insert another sample routine
INSERT INTO routines (title, description, duration_minutes, difficulty, category, is_published, is_curated, created_by, tags, calories_burned, equipment, steps)
VALUES (
    'Strength Builder',
    'Build muscle and increase strength with this medium-intensity routine using just your bodyweight.',
    30,
    'medium',
    'strength',
    true,
    true,
    'admin',
    ARRAY['strength', 'intermediate', 'no-equipment'],
    250,
    'None',
    '[
        {"id": "step1", "title": "Warm-up Jog in Place", "description": "Get your muscles warm and ready", "durationSeconds": 120, "orderIndex": 0},
        {"id": "step2", "title": "Push-ups", "description": "Classic upper body builder - modify on knees if needed", "durationSeconds": 90, "orderIndex": 1},
        {"id": "step3", "title": "Lunges", "description": "Alternate legs, keep your core tight", "durationSeconds": 90, "orderIndex": 2},
        {"id": "step4", "title": "Plank Hold", "description": "Core stability - hold as long as you can", "durationSeconds": 60, "orderIndex": 3},
        {"id": "step5", "title": "Tricep Dips", "description": "Use a chair or bench for support", "durationSeconds": 60, "orderIndex": 4},
        {"id": "step6", "title": "Glute Bridges", "description": "Squeeze at the top for maximum activation", "durationSeconds": 60, "orderIndex": 5},
        {"id": "step7", "title": "Burpees", "description": "Full body power move - take breaks as needed", "durationSeconds": 90, "orderIndex": 6},
        {"id": "step8", "title": "Cool Down", "description": "Stretch all major muscle groups", "durationSeconds": 180, "orderIndex": 7}
    ]'::jsonb
);

-- ============================================================================
-- DONE!
-- ============================================================================
-- After running this script:
-- 1. Go to Authentication > Settings and configure your auth providers
-- 2. Go to API and copy your Project URL and anon key
-- 3. Add them to your Flutter app's env.dart file
-- ============================================================================

