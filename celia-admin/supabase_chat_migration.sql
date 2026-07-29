-- ============================================================================
-- CELIA APP - AGENTIC CHAT MIGRATION
-- ============================================================================
-- Run this SQL in your Supabase SQL Editor.
-- Go to: Supabase Dashboard > SQL Editor > New Query > Paste & Run
--
-- Purpose: conversation storage for the Celia coach agent, replacing the
-- Botpress-hosted chat. History used to live in Firestore, but the agent runs
-- server-side and needs to read prior turns to build model context, so it
-- moves next to the rest of the app's data.
--
-- `parts` stores the full message payload (text plus any tool calls and their
-- results) so a reloaded conversation can be replayed to the model exactly as
-- it happened, rather than being flattened to plain text.
-- ============================================================================

CREATE TABLE IF NOT EXISTS chat_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- Firebase uid. TEXT (not UUID) to match user_meals / routines.created_by.
    user_id TEXT NOT NULL,
    title TEXT NOT NULL DEFAULT 'New chat',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_conversations_user
    ON chat_conversations(user_id, updated_at DESC);

CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL
        REFERENCES chat_conversations(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
    content TEXT NOT NULL DEFAULT '',
    parts JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_messages_conversation
    ON chat_messages(conversation_id, created_at);

-- Private user data: RLS on with no permissive policy, so the anon key used by
-- the mobile app cannot read or write these tables at all. Every access goes
-- through /api/mobile/chat, which verifies the Firebase token and then uses the
-- service role (which bypasses RLS) scoped to that verified uid.
ALTER TABLE chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
