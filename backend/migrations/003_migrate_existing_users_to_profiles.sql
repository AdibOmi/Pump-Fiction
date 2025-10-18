-- Migration: Migrate existing users to user_profiles table
-- This creates profile entries for all existing users that don't have one yet
-- Run this SQL in Supabase SQL Editor

-- Insert profiles for existing users who don't have a profile yet
INSERT INTO user_profiles (user_id, full_name, phone_number)
SELECT 
    u.id,
    u.full_name,
    u.phone_number
FROM users u
LEFT JOIN user_profiles up ON u.id = up.user_id
WHERE up.id IS NULL;

-- Verify the migration
DO $$
DECLARE
    user_count INTEGER;
    profile_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO user_count FROM users;
    SELECT COUNT(*) INTO profile_count FROM user_profiles;
    
    RAISE NOTICE 'Migration completed!';
    RAISE NOTICE 'Total users: %', user_count;
    RAISE NOTICE 'Total profiles: %', profile_count;
    
    IF user_count = profile_count THEN
        RAISE NOTICE '✓ All users have profiles';
    ELSE
        RAISE WARNING '! Mismatch: % users but % profiles', user_count, profile_count;
    END IF;
END $$;
