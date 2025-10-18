-- Migration: Auto-create user profile when user is created
-- This trigger ensures every user automatically gets a profile entry
-- Run this SQL in Supabase SQL Editor

-- Function to create user profile automatically
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert a new profile for the newly created user
    INSERT INTO user_profiles (user_id, full_name, phone_number)
    VALUES (NEW.id, NEW.full_name, NEW.phone_number);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger that fires after a new user is inserted
DROP TRIGGER IF EXISTS trigger_create_user_profile ON users;
CREATE TRIGGER trigger_create_user_profile
    AFTER INSERT ON users
    FOR EACH ROW
    EXECUTE FUNCTION create_user_profile();

-- Comment
COMMENT ON FUNCTION create_user_profile() IS 'Automatically creates a user profile when a new user is created';
COMMENT ON TRIGGER trigger_create_user_profile ON users IS 'Trigger to auto-create user profile on user creation';
