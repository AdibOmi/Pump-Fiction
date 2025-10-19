-- Migration: Create tracker tables
-- Description: Creates tables for fitness progress trackers and their entries
-- Author: System
-- Date: 2025-10-19

-- ============================================
-- Create trackers table
-- ============================================
CREATE TABLE IF NOT EXISTS trackers (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    goal DOUBLE PRECISION,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index on user_id for faster queries
CREATE INDEX IF NOT EXISTS idx_trackers_user_id ON trackers(user_id);

-- Add comment to table
COMMENT ON TABLE trackers IS 'Stores custom fitness trackers (e.g., body weight, blood pressure)';
COMMENT ON COLUMN trackers.name IS 'Name of the tracker (e.g., "Body Weight", "Blood Pressure")';
COMMENT ON COLUMN trackers.unit IS 'Unit of measurement (e.g., "kg", "bpm", "cm")';
COMMENT ON COLUMN trackers.goal IS 'Optional target goal value';


-- ============================================
-- Create tracker_entries table
-- ============================================
CREATE TABLE IF NOT EXISTS tracker_entries (
    id BIGSERIAL PRIMARY KEY,
    tracker_id BIGINT NOT NULL REFERENCES trackers(id) ON DELETE CASCADE,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    value DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_tracker_entries_tracker_id ON tracker_entries(tracker_id);
CREATE INDEX IF NOT EXISTS idx_tracker_entries_date ON tracker_entries(date);

-- Add comment to table
COMMENT ON TABLE tracker_entries IS 'Stores individual data points for trackers';
COMMENT ON COLUMN tracker_entries.date IS 'Date when the measurement was taken';
COMMENT ON COLUMN tracker_entries.value IS 'The measured value';


-- ============================================
-- Enable Row Level Security (RLS)
-- ============================================
ALTER TABLE trackers ENABLE ROW LEVEL SECURITY;
ALTER TABLE tracker_entries ENABLE ROW LEVEL SECURITY;


-- ============================================
-- Create RLS Policies for trackers
-- ============================================

-- Policy: Users can view their own trackers
CREATE POLICY "Users can view their own trackers"
    ON trackers
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Users can insert their own trackers
CREATE POLICY "Users can insert their own trackers"
    ON trackers
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own trackers
CREATE POLICY "Users can update their own trackers"
    ON trackers
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own trackers
CREATE POLICY "Users can delete their own trackers"
    ON trackers
    FOR DELETE
    USING (auth.uid() = user_id);


-- ============================================
-- Create RLS Policies for tracker_entries
-- ============================================

-- Policy: Users can view entries for their own trackers
CREATE POLICY "Users can view their own tracker entries"
    ON tracker_entries
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM trackers
            WHERE trackers.id = tracker_entries.tracker_id
            AND auth.uid() = trackers.user_id
        )
    );

-- Policy: Users can insert entries for their own trackers
CREATE POLICY "Users can insert their own tracker entries"
    ON tracker_entries
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM trackers
            WHERE trackers.id = tracker_entries.tracker_id
            AND auth.uid() = trackers.user_id
        )
    );

-- Policy: Users can update entries for their own trackers
CREATE POLICY "Users can update their own tracker entries"
    ON tracker_entries
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM trackers
            WHERE trackers.id = tracker_entries.tracker_id
            AND auth.uid() = trackers.user_id
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM trackers
            WHERE trackers.id = tracker_entries.tracker_id
            AND auth.uid() = trackers.user_id
        )
    );

-- Policy: Users can delete entries for their own trackers
CREATE POLICY "Users can delete their own tracker entries"
    ON tracker_entries
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM trackers
            WHERE trackers.id = tracker_entries.tracker_id
            AND auth.uid() = trackers.user_id
        )
    );


-- ============================================
-- Create function to auto-update updated_at timestamp
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for auto-updating updated_at
CREATE TRIGGER update_trackers_updated_at
    BEFORE UPDATE ON trackers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tracker_entries_updated_at
    BEFORE UPDATE ON tracker_entries
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


-- ============================================
-- Grant permissions (if needed for service role)
-- ============================================
-- Note: Adjust these based on your Supabase setup
-- GRANT ALL ON trackers TO service_role;
-- GRANT ALL ON tracker_entries TO service_role;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO service_role;
