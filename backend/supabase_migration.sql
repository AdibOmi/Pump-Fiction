-- ============================================
-- Supabase Migration Script
-- Creates AI Chat tables in PostgreSQL
-- ============================================

-- Create AI Chat Sessions Table
CREATE TABLE IF NOT EXISTS ai_chat_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    context_snapshot JSONB DEFAULT '{}'::jsonb,
    last_message_at TIMESTAMP NOT NULL DEFAULT NOW(),
    is_archived BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create index on user_id for faster queries
CREATE INDEX IF NOT EXISTS idx_ai_chat_sessions_user_id ON ai_chat_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_chat_sessions_last_message ON ai_chat_sessions(last_message_at DESC);

-- Create AI Chat Messages Table
CREATE TABLE IF NOT EXISTS ai_chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES ai_chat_sessions(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    citations JSONB DEFAULT '[]'::jsonb,
    tokens_used INTEGER,
    model_version VARCHAR(50),
    safety_flag BOOLEAN NOT NULL DEFAULT FALSE,
    disclaimer_shown BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_ai_chat_messages_session_id ON ai_chat_messages(session_id);
CREATE INDEX IF NOT EXISTS idx_ai_chat_messages_created_at ON ai_chat_messages(created_at);

-- Enable Row Level Security (RLS)
ALTER TABLE ai_chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_chat_messages ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies for ai_chat_sessions
-- Users can only see their own sessions
CREATE POLICY "Users can view own sessions" ON ai_chat_sessions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own sessions" ON ai_chat_sessions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own sessions" ON ai_chat_sessions
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own sessions" ON ai_chat_sessions
    FOR DELETE USING (auth.uid() = user_id);

-- Create RLS Policies for ai_chat_messages
-- Users can only see messages from their own sessions
CREATE POLICY "Users can view own messages" ON ai_chat_messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM ai_chat_sessions
            WHERE ai_chat_sessions.id = ai_chat_messages.session_id
            AND ai_chat_sessions.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own messages" ON ai_chat_messages
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM ai_chat_sessions
            WHERE ai_chat_sessions.id = ai_chat_messages.session_id
            AND ai_chat_sessions.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update own messages" ON ai_chat_messages
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM ai_chat_sessions
            WHERE ai_chat_sessions.id = ai_chat_messages.session_id
            AND ai_chat_sessions.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete own messages" ON ai_chat_messages
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM ai_chat_sessions
            WHERE ai_chat_sessions.id = ai_chat_messages.session_id
            AND ai_chat_sessions.user_id = auth.uid()
        )
    );

-- Grant permissions (if needed for service role)
-- The service role should bypass RLS automatically, but just in case:
GRANT ALL ON ai_chat_sessions TO postgres, authenticated, service_role;
GRANT ALL ON ai_chat_messages TO postgres, authenticated, service_role;

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'AI Chat tables created successfully!';
    RAISE NOTICE 'Tables: ai_chat_sessions, ai_chat_messages';
    RAISE NOTICE 'RLS policies enabled for user data protection';
END $$;
