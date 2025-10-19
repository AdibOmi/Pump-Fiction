-- =====================================================
-- Workout Logs Tables Migration
-- =====================================================
-- This migration creates tables for storing workout logs
-- Each workout log contains exercises and sets performed

-- Drop tables if they exist (for clean recreation)
-- CASCADE ensures all dependent objects are also dropped
DROP TABLE IF EXISTS workout_sets CASCADE;
DROP TABLE IF EXISTS workout_exercises CASCADE;
DROP TABLE IF EXISTS workout_logs CASCADE;

-- =====================================================
-- Table: workout_logs
-- =====================================================
-- Stores the main workout log entry (date, routine, day)
CREATE TABLE workout_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    workout_date DATE NOT NULL,
    routine_title TEXT,
    day_label TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_workout_logs_user_id ON workout_logs(user_id);
CREATE INDEX idx_workout_logs_workout_date ON workout_logs(workout_date);
CREATE INDEX idx_workout_logs_user_date ON workout_logs(user_id, workout_date);

-- =====================================================
-- Table: workout_exercises
-- =====================================================
-- Stores exercises within a workout log
CREATE TABLE workout_exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_log_id UUID NOT NULL REFERENCES workout_logs(id) ON DELETE CASCADE,
    exercise_name TEXT NOT NULL,
    position INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_workout_exercises_workout_log_id ON workout_exercises(workout_log_id);
CREATE INDEX idx_workout_exercises_position ON workout_exercises(workout_log_id, position);

-- =====================================================
-- Table: workout_sets
-- =====================================================
-- Stores individual sets within an exercise
CREATE TABLE workout_sets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_exercise_id UUID NOT NULL REFERENCES workout_exercises(id) ON DELETE CASCADE,
    weight DOUBLE PRECISION NOT NULL,
    reps INTEGER NOT NULL,
    position INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_workout_sets_workout_exercise_id ON workout_sets(workout_exercise_id);
CREATE INDEX idx_workout_sets_position ON workout_sets(workout_exercise_id, position);

-- =====================================================
-- Row Level Security (RLS) Policies
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE workout_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sets ENABLE ROW LEVEL SECURITY;

-- Policies for workout_logs
CREATE POLICY "Users can view their own workout logs"
    ON workout_logs FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own workout logs"
    ON workout_logs FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own workout logs"
    ON workout_logs FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own workout logs"
    ON workout_logs FOR DELETE
    USING (auth.uid() = user_id);

-- Policies for workout_exercises
CREATE POLICY "Users can view their own workout exercises"
    ON workout_exercises FOR SELECT
    USING (EXISTS (
        SELECT 1 FROM workout_logs
        WHERE workout_logs.id = workout_exercises.workout_log_id
        AND workout_logs.user_id = auth.uid()
    ));

CREATE POLICY "Users can insert workout exercises for their logs"
    ON workout_exercises FOR INSERT
    WITH CHECK (EXISTS (
        SELECT 1 FROM workout_logs
        WHERE workout_logs.id = workout_exercises.workout_log_id
        AND workout_logs.user_id = auth.uid()
    ));

CREATE POLICY "Users can update their own workout exercises"
    ON workout_exercises FOR UPDATE
    USING (EXISTS (
        SELECT 1 FROM workout_logs
        WHERE workout_logs.id = workout_exercises.workout_log_id
        AND workout_logs.user_id = auth.uid()
    ));

CREATE POLICY "Users can delete their own workout exercises"
    ON workout_exercises FOR DELETE
    USING (EXISTS (
        SELECT 1 FROM workout_logs
        WHERE workout_logs.id = workout_exercises.workout_log_id
        AND workout_logs.user_id = auth.uid()
    ));

-- Policies for workout_sets
CREATE POLICY "Users can view their own workout sets"
    ON workout_sets FOR SELECT
    USING (EXISTS (
        SELECT 1 FROM workout_exercises
        JOIN workout_logs ON workout_logs.id = workout_exercises.workout_log_id
        WHERE workout_exercises.id = workout_sets.workout_exercise_id
        AND workout_logs.user_id = auth.uid()
    ));

CREATE POLICY "Users can insert workout sets for their exercises"
    ON workout_sets FOR INSERT
    WITH CHECK (EXISTS (
        SELECT 1 FROM workout_exercises
        JOIN workout_logs ON workout_logs.id = workout_exercises.workout_log_id
        WHERE workout_exercises.id = workout_sets.workout_exercise_id
        AND workout_logs.user_id = auth.uid()
    ));

CREATE POLICY "Users can update their own workout sets"
    ON workout_sets FOR UPDATE
    USING (EXISTS (
        SELECT 1 FROM workout_exercises
        JOIN workout_logs ON workout_logs.id = workout_exercises.workout_log_id
        WHERE workout_exercises.id = workout_sets.workout_exercise_id
        AND workout_logs.user_id = auth.uid()
    ));

CREATE POLICY "Users can delete their own workout sets"
    ON workout_sets FOR DELETE
    USING (EXISTS (
        SELECT 1 FROM workout_exercises
        JOIN workout_logs ON workout_logs.id = workout_exercises.workout_log_id
        WHERE workout_exercises.id = workout_sets.workout_exercise_id
        AND workout_logs.user_id = auth.uid()
    ));

-- =====================================================
-- Trigger for updated_at
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_workout_logs_updated_at
    BEFORE UPDATE ON workout_logs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- Comments for documentation
-- =====================================================
COMMENT ON TABLE workout_logs IS 'Stores workout log entries with date and routine information';
COMMENT ON TABLE workout_exercises IS 'Stores exercises performed in a workout log';
COMMENT ON TABLE workout_sets IS 'Stores individual sets (weight x reps) for each exercise';

COMMENT ON COLUMN workout_logs.workout_date IS 'The date when the workout was performed';
COMMENT ON COLUMN workout_logs.routine_title IS 'The name of the routine followed (optional)';
COMMENT ON COLUMN workout_logs.day_label IS 'The day label from the routine (e.g., Push, Pull, Legs)';
COMMENT ON COLUMN workout_exercises.position IS 'Order of exercises in the workout';
COMMENT ON COLUMN workout_sets.position IS 'Order of sets within an exercise';
COMMENT ON COLUMN workout_sets.weight IS 'Weight lifted in pounds or kilograms';
COMMENT ON COLUMN workout_sets.reps IS 'Number of repetitions performed';
