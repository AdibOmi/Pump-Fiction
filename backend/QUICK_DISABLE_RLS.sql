-- =====================================================
-- QUICK FIX: Disable RLS on ALL tables (One command)
-- =====================================================
-- Copy and paste this ENTIRE block into Supabase SQL Editor
-- =====================================================

-- Disable RLS on all tables
ALTER TABLE public.ai_chat_messages DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_chat_sessions DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.journal_entries DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.journal_sessions DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_photos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_applications DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.routine_exercises DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.routine_headers DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.tracker_entries DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.trackers DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_exercises DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_logs DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_sets DISABLE ROW LEVEL SECURITY;

-- Grant full access to service_role
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Verify (should all show RLS DISABLED)
SELECT tablename, 
       CASE WHEN rowsecurity THEN 'RLS ENABLED' ELSE 'RLS DISABLED ✅' END 
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY tablename;
