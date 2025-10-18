-- Migration: Create user_profiles table
-- Run this SQL in Supabase SQL Editor

-- Create ENUM types
CREATE TYPE gender_enum AS ENUM ('male', 'female', 'other', 'prefer_not_to_say');
CREATE TYPE fitness_goal_enum AS ENUM ('strength', 'muscle_gain', 'fat_loss', 'endurance', 'general_fitness');
CREATE TYPE experience_level_enum AS ENUM ('beginner', 'intermediate', 'advanced');
CREATE TYPE nutrition_goal_enum AS ENUM ('cut', 'bulk', 'recomp', 'maintain');

-- Create user_profiles table
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,

    -- Basic info
    full_name VARCHAR(255),
    phone_number VARCHAR(50),
    gender gender_enum,

    -- Physical attributes
    weight_kg REAL CHECK (weight_kg IS NULL OR weight_kg > 0),
    height_cm REAL CHECK (height_cm IS NULL OR height_cm > 0),

    -- Fitness preferences
    fitness_goal fitness_goal_enum,
    experience_level experience_level_enum,
    training_frequency INTEGER CHECK (training_frequency IS NULL OR (training_frequency >= 1 AND training_frequency <= 7)),
    nutrition_goal nutrition_goal_enum,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create index on user_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON user_profiles(user_id);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to auto-update updated_at
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Add comment to table
COMMENT ON TABLE user_profiles IS 'Extended user profile information including fitness goals and physical attributes';
