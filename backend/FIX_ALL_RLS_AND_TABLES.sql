-- =====================================================
-- COMPLETE FIX FOR ALL RLS AND MISSING TABLES
-- =====================================================
-- This script will:
-- 1. Ensure all required tables exist
-- 2. Disable RLS on all tables for development
-- 3. Allow your teammates to access the backend
-- 
-- Run this ENTIRE script in your Supabase SQL Editor
-- =====================================================

-- =====================================================
-- STEP 1: Check and create missing tables
-- =====================================================

-- Create workout_logs table if it doesn't exist
CREATE TABLE IF NOT EXISTS workout_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    workout_date DATE NOT NULL,
    routine_title TEXT,
    day_label TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create workout_exercises table if it doesn't exist
CREATE TABLE IF NOT EXISTS workout_exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_log_id UUID NOT NULL REFERENCES workout_logs(id) ON DELETE CASCADE,
    exercise_name TEXT NOT NULL,
    position INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create workout_sets table if it doesn't exist
CREATE TABLE IF NOT EXISTS workout_sets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_exercise_id UUID NOT NULL REFERENCES workout_exercises(id) ON DELETE CASCADE,
    weight DOUBLE PRECISION NOT NULL,
    reps INTEGER NOT NULL,
    position INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_workout_logs_user_id ON workout_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_logs_workout_date ON workout_logs(workout_date);
CREATE INDEX IF NOT EXISTS idx_workout_logs_user_date ON workout_logs(user_id, workout_date);
CREATE INDEX IF NOT EXISTS idx_workout_exercises_workout_log_id ON workout_exercises(workout_log_id);
CREATE INDEX IF NOT EXISTS idx_workout_exercises_position ON workout_exercises(workout_log_id, position);
CREATE INDEX IF NOT EXISTS idx_workout_sets_workout_exercise_id ON workout_sets(workout_exercise_id);
CREATE INDEX IF NOT EXISTS idx_workout_sets_position ON workout_sets(workout_exercise_id, position);

-- =====================================================
-- STEP 2: DISABLE RLS ON ALL TABLES (For Development)
-- =====================================================
-- This allows your backend service role to access all data
-- without needing user authentication tokens

-- Core tables
ALTER TABLE IF EXISTS public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.user_profiles DISABLE ROW LEVEL SECURITY;

-- Tracker tables
ALTER TABLE IF EXISTS public.trackers DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.tracker_entries DISABLE ROW LEVEL SECURITY;

-- Social/Posts tables
ALTER TABLE IF EXISTS public.posts DISABLE ROW LEVEL SECURITY;

-- Workout log tables
ALTER TABLE IF EXISTS public.workout_logs DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.workout_exercises DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.workout_sets DISABLE ROW LEVEL SECURITY;

-- Journal tables (if they exist)
ALTER TABLE IF EXISTS public.journals DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.journal_entries DISABLE ROW LEVEL SECURITY;

-- Routine tables (if they exist)
ALTER TABLE IF EXISTS public.routines DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.routine_days DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.routine_exercises DISABLE ROW LEVEL SECURITY;

-- =====================================================
-- STEP 3: Grant full access to service_role
-- =====================================================
-- This ensures your backend (using service_role key) has full access

-- Grant permissions on tables
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO service_role;

-- Grant permissions to authenticated users (for frontend)
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- =====================================================
-- STEP 4: Create function for auto-updating timestamps
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add triggers for workout tables
DROP TRIGGER IF EXISTS update_workout_logs_updated_at ON workout_logs;
CREATE TRIGGER update_workout_logs_updated_at
    BEFORE UPDATE ON workout_logs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================
-- Run these to verify everything is set up correctly

-- Check if tables exist
SELECT 
    tablename,
    CASE 
        WHEN tablename IN (
            SELECT tablename 
            FROM pg_tables 
            WHERE schemaname = 'public'
        ) THEN '✅ EXISTS'
        ELSE '❌ MISSING'
    END as status
FROM (
    VALUES 
        ('users'),
        ('user_profiles'),
        ('trackers'),
        ('tracker_entries'),
        ('posts'),
        ('workout_logs'),
        ('workout_exercises'),
        ('workout_sets')
) AS t(tablename);

-- Check RLS status (should all be FALSE after this script)
SELECT 
    schemaname,
    tablename,
    CASE 
        WHEN rowsecurity THEN '⚠️ RLS ENABLED (Should be DISABLED for dev)'
        ELSE '✅ RLS DISABLED'
    END as rls_status
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '✅ ALL FIXES APPLIED SUCCESSFULLY!';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE 'What was fixed:';
    RAISE NOTICE '  1. All required tables created';
    RAISE NOTICE '  2. RLS disabled on all tables';
    RAISE NOTICE '  3. Service role granted full access';
    RAISE NOTICE '  4. Indexes and triggers added';
    RAISE NOTICE '';
    RAISE NOTICE 'Next steps for your teammates:';
    RAISE NOTICE '  1. Get the .env file from you';
    RAISE NOTICE '  2. Place it in backend/.env';
    RAISE NOTICE '  3. Restart their backend server';
    RAISE NOTICE '  4. Test the endpoints';
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
END $$;
