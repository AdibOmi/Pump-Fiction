-- =====================================================
-- DISABLE ALL RLS POLICIES FOR ALL TABLES
-- =====================================================
-- This script disables Row Level Security on all tables
-- Run this in Supabase SQL Editor to allow backend access
-- =====================================================

-- =====================================================
-- STEP 1: Disable RLS on all tables
-- =====================================================

-- AI Chat tables
ALTER TABLE public.ai_chat_messages DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_chat_sessions DISABLE ROW LEVEL SECURITY;

-- Journal tables
ALTER TABLE public.journal_entries DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.journal_sessions DISABLE ROW LEVEL SECURITY;

-- Post tables
ALTER TABLE public.post_photos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts DISABLE ROW LEVEL SECURITY;

-- Role application tables
ALTER TABLE public.role_applications DISABLE ROW LEVEL SECURITY;

-- Routine tables
ALTER TABLE public.routine_exercises DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.routine_headers DISABLE ROW LEVEL SECURITY;

-- Tracker tables
ALTER TABLE public.tracker_entries DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.trackers DISABLE ROW LEVEL SECURITY;

-- User tables
ALTER TABLE public.user_profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;

-- Workout tables
ALTER TABLE public.workout_exercises DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_logs DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_sets DISABLE ROW LEVEL SECURITY;

-- =====================================================
-- STEP 2: Drop all existing RLS policies (optional cleanup)
-- =====================================================
-- This removes all policy definitions, not just disables them

-- AI Chat policies
DROP POLICY IF EXISTS "Users can view their own chat sessions" ON public.ai_chat_sessions;
DROP POLICY IF EXISTS "Users can insert their own chat sessions" ON public.ai_chat_sessions;
DROP POLICY IF EXISTS "Users can update their own chat sessions" ON public.ai_chat_sessions;
DROP POLICY IF EXISTS "Users can delete their own chat sessions" ON public.ai_chat_sessions;
DROP POLICY IF EXISTS "Users can view their own chat messages" ON public.ai_chat_messages;
DROP POLICY IF EXISTS "Users can insert their own chat messages" ON public.ai_chat_messages;
DROP POLICY IF EXISTS "Users can update their own chat messages" ON public.ai_chat_messages;
DROP POLICY IF EXISTS "Users can delete their own chat messages" ON public.ai_chat_messages;

-- Journal policies
DROP POLICY IF EXISTS "Users can view their own journal sessions" ON public.journal_sessions;
DROP POLICY IF EXISTS "Users can insert their own journal sessions" ON public.journal_sessions;
DROP POLICY IF EXISTS "Users can update their own journal sessions" ON public.journal_sessions;
DROP POLICY IF EXISTS "Users can delete their own journal sessions" ON public.journal_sessions;
DROP POLICY IF EXISTS "Users can view their own journal entries" ON public.journal_entries;
DROP POLICY IF EXISTS "Users can insert their own journal entries" ON public.journal_entries;
DROP POLICY IF EXISTS "Users can update their own journal entries" ON public.journal_entries;
DROP POLICY IF EXISTS "Users can delete their own journal entries" ON public.journal_entries;

-- Post policies
DROP POLICY IF EXISTS "Users can view all posts" ON public.posts;
DROP POLICY IF EXISTS "Users can view their own posts" ON public.posts;
DROP POLICY IF EXISTS "Users can insert their own posts" ON public.posts;
DROP POLICY IF EXISTS "Users can update their own posts" ON public.posts;
DROP POLICY IF EXISTS "Users can delete their own posts" ON public.posts;
DROP POLICY IF EXISTS "Users can view post photos" ON public.post_photos;
DROP POLICY IF EXISTS "Users can insert post photos" ON public.post_photos;
DROP POLICY IF EXISTS "Users can update post photos" ON public.post_photos;
DROP POLICY IF EXISTS "Users can delete post photos" ON public.post_photos;

-- Role application policies
DROP POLICY IF EXISTS "Users can view their own applications" ON public.role_applications;
DROP POLICY IF EXISTS "Users can insert their own applications" ON public.role_applications;
DROP POLICY IF EXISTS "Users can update their own applications" ON public.role_applications;
DROP POLICY IF EXISTS "Admins can view all applications" ON public.role_applications;
DROP POLICY IF EXISTS "Admins can update applications" ON public.role_applications;

-- Routine policies
DROP POLICY IF EXISTS "Users can view their own routines" ON public.routine_headers;
DROP POLICY IF EXISTS "Users can insert their own routines" ON public.routine_headers;
DROP POLICY IF EXISTS "Users can update their own routines" ON public.routine_headers;
DROP POLICY IF EXISTS "Users can delete their own routines" ON public.routine_headers;
DROP POLICY IF EXISTS "Users can view their own routine exercises" ON public.routine_exercises;
DROP POLICY IF EXISTS "Users can insert their own routine exercises" ON public.routine_exercises;
DROP POLICY IF EXISTS "Users can update their own routine exercises" ON public.routine_exercises;
DROP POLICY IF EXISTS "Users can delete their own routine exercises" ON public.routine_exercises;

-- Tracker policies
DROP POLICY IF EXISTS "Users can view their own trackers" ON public.trackers;
DROP POLICY IF EXISTS "Users can insert their own trackers" ON public.trackers;
DROP POLICY IF EXISTS "Users can update their own trackers" ON public.trackers;
DROP POLICY IF EXISTS "Users can delete their own trackers" ON public.trackers;
DROP POLICY IF EXISTS "Users can view their own tracker entries" ON public.tracker_entries;
DROP POLICY IF EXISTS "Users can insert their own tracker entries" ON public.tracker_entries;
DROP POLICY IF EXISTS "Users can update their own tracker entries" ON public.tracker_entries;
DROP POLICY IF EXISTS "Users can delete their own tracker entries" ON public.tracker_entries;

-- User policies
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can view own data" ON public.users;
DROP POLICY IF EXISTS "service_role_bypass" ON public.users;
DROP POLICY IF EXISTS "users_read_own" ON public.users;
DROP POLICY IF EXISTS "users_update_own" ON public.users;
DROP POLICY IF EXISTS "service_role_all" ON public.users;
DROP POLICY IF EXISTS "Users can view their own user profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can insert their own user profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update their own user profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can delete their own user profile" ON public.user_profiles;

-- Workout policies
DROP POLICY IF EXISTS "Users can view their own workout logs" ON public.workout_logs;
DROP POLICY IF EXISTS "Users can insert their own workout logs" ON public.workout_logs;
DROP POLICY IF EXISTS "Users can update their own workout logs" ON public.workout_logs;
DROP POLICY IF EXISTS "Users can delete their own workout logs" ON public.workout_logs;
DROP POLICY IF EXISTS "Users can view their own workout exercises" ON public.workout_exercises;
DROP POLICY IF EXISTS "Users can insert workout exercises for their logs" ON public.workout_exercises;
DROP POLICY IF EXISTS "Users can update their own workout exercises" ON public.workout_exercises;
DROP POLICY IF EXISTS "Users can delete their own workout exercises" ON public.workout_exercises;
DROP POLICY IF EXISTS "Users can view their own workout sets" ON public.workout_sets;
DROP POLICY IF EXISTS "Users can insert workout sets for their exercises" ON public.workout_sets;
DROP POLICY IF EXISTS "Users can update their own workout sets" ON public.workout_sets;
DROP POLICY IF EXISTS "Users can delete their own workout sets" ON public.workout_sets;

-- =====================================================
-- STEP 3: Grant full permissions to service_role
-- =====================================================
-- Ensures your backend can access everything

GRANT ALL ON public.ai_chat_messages TO service_role;
GRANT ALL ON public.ai_chat_sessions TO service_role;
GRANT ALL ON public.journal_entries TO service_role;
GRANT ALL ON public.journal_sessions TO service_role;
GRANT ALL ON public.post_photos TO service_role;
GRANT ALL ON public.posts TO service_role;
GRANT ALL ON public.role_applications TO service_role;
GRANT ALL ON public.routine_exercises TO service_role;
GRANT ALL ON public.routine_headers TO service_role;
GRANT ALL ON public.tracker_entries TO service_role;
GRANT ALL ON public.trackers TO service_role;
GRANT ALL ON public.user_profiles TO service_role;
GRANT ALL ON public.users TO service_role;
GRANT ALL ON public.workout_exercises TO service_role;
GRANT ALL ON public.workout_logs TO service_role;
GRANT ALL ON public.workout_sets TO service_role;

-- Grant permissions on all sequences (for auto-increment IDs)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO service_role;

-- Grant permissions to authenticated users (for frontend)
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- =====================================================
-- STEP 4: Verification
-- =====================================================
-- Check RLS status on all tables

SELECT 
    schemaname,
    tablename,
    CASE 
        WHEN rowsecurity THEN '⚠️ RLS ENABLED'
        ELSE '✅ RLS DISABLED'
    END as rls_status
FROM pg_tables
WHERE schemaname = 'public'
    AND tablename IN (
        'ai_chat_messages',
        'ai_chat_sessions',
        'journal_entries',
        'journal_sessions',
        'post_photos',
        'posts',
        'role_applications',
        'routine_exercises',
        'routine_headers',
        'tracker_entries',
        'trackers',
        'user_profiles',
        'users',
        'workout_exercises',
        'workout_logs',
        'workout_sets'
    )
ORDER BY tablename;

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '✅ ALL RLS POLICIES DISABLED!';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Changes Applied:';
    RAISE NOTICE '  ✅ Disabled RLS on 16 tables';
    RAISE NOTICE '  ✅ Dropped all existing RLS policies';
    RAISE NOTICE '  ✅ Granted full access to service_role';
    RAISE NOTICE '  ✅ Granted permissions to authenticated users';
    RAISE NOTICE '';
    RAISE NOTICE 'Your backend can now access all data!';
    RAISE NOTICE 'Your teammates can now use the backend!';
    RAISE NOTICE '';
    RAISE NOTICE 'Next Steps:';
    RAISE NOTICE '  1. Share .env file with teammates';
    RAISE NOTICE '  2. Teammates restart backend server';
    RAISE NOTICE '  3. Test endpoints at /docs';
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
END $$;
