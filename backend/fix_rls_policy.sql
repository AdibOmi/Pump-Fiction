-- FINAL FIX FOR RLS POLICIES
-- The issue: Supabase Python client doesn't properly pass service_role context
-- Solution: Temporarily disable RLS for testing, then apply proper policies

-- OPTION 1: Disable RLS completely (EASIEST - for development only)
-- Run this if you just want to test and develop:
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;

-- OPTION 2: Keep RLS enabled with proper policies (RECOMMENDED for production)
-- If you want to keep RLS enabled, run these commands instead:

-- First, drop all existing policies
DROP POLICY IF EXISTS "Users can view own data" ON public.users;
DROP POLICY IF EXISTS "Service role has full access" ON public.users;
DROP POLICY IF EXISTS "service_role_all" ON public.users;
DROP POLICY IF EXISTS "users_select_own" ON public.users;
DROP POLICY IF EXISTS "users_update_own" ON public.users;

-- Ensure RLS is enabled
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Grant full permissions to service_role at table level
GRANT ALL ON public.users TO service_role;
GRANT SELECT ON public.users TO authenticated;

-- Create a policy that allows ALL operations from service_role
-- Note: The Python client should use apikey header with service_role key
CREATE POLICY "service_role_bypass" ON public.users
  FOR ALL
  USING (
    -- Allow if request is from service role (checks the role claim in JWT)
    current_setting('request.jwt.claims', true)::json->>'role' = 'service_role'
    OR
    -- Also allow if no RLS context (direct SQL from service)
    current_setting('request.jwt.claims', true) IS NULL
  )
  WITH CHECK (
    current_setting('request.jwt.claims', true)::json->>'role' = 'service_role'
    OR
    current_setting('request.jwt.claims', true) IS NULL
  );

-- Allow authenticated users to read their own data
CREATE POLICY "users_read_own" ON public.users
  FOR SELECT
  USING (auth.uid() = id);

-- Allow authenticated users to update their own data  
CREATE POLICY "users_update_own" ON public.users
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Verify policies
SELECT schemaname, tablename, policyname, roles, cmd
FROM pg_policies
WHERE tablename = 'users';

-- FOR DEVELOPMENT: If the above still doesn't work, just disable RLS:
-- ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
