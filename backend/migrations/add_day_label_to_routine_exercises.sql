-- Migration: Add day_label to routine_exercises table
-- This allows us to preserve which exercises belong to which day in a routine

-- Add day_label column to routine_exercises
ALTER TABLE routine_exercises
ADD COLUMN day_label TEXT;

-- Set default value for existing rows
UPDATE routine_exercises
SET day_label = 'Day 1'
WHERE day_label IS NULL;

-- Add index for faster queries
CREATE INDEX IF NOT EXISTS idx_routine_exercises_day_label ON routine_exercises(day_label);

-- Comment for documentation
COMMENT ON COLUMN routine_exercises.day_label IS 'The day/label this exercise belongs to (e.g., Push, Pull, Legs, Monday, etc.)';
