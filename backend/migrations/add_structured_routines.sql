-- Migration: create structured routines tables
-- Table 1: routines (header/meta)
CREATE TABLE IF NOT EXISTS public.routine_headers (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    title text NOT NULL,
    day_selected text, -- e.g. 'Mon, Tue' or 'Day 1'
    is_archived boolean DEFAULT false,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz
);

-- Table 2: routine_exercises (one row per exercise belonging to a routine)
CREATE TABLE IF NOT EXISTS public.routine_exercises (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    routine_id uuid NOT NULL REFERENCES public.routine_headers(id) ON DELETE CASCADE,
    title text NOT NULL,
    sets integer DEFAULT 1,
    min_reps integer DEFAULT 1,
    max_reps integer DEFAULT 1,
    position integer DEFAULT 0,
    created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_routine_exercises_routine_id ON public.routine_exercises (routine_id);
