# Quick Fix Guide - Routine Exercises Not Showing

## The Problem
When you go to **Routine → Custom Routine → Legs**, you see NO exercises, even though they're saved in the database.

## Why This Happens
The database wasn't tracking **which exercises belong to which day**. So when you create a routine with:
- Push day: Bench Press, OHP
- Pull day: Deadlift, Rows  
- Legs day: Squat, Lunges

The backend saved all 6 exercises but lost track of which day they belong to!

## The Fix (3 Steps)

### Step 1: Run Database Migration

Open your Supabase SQL Editor (or connect to your PostgreSQL database) and run:

```sql
-- Add day_label column to track which day each exercise belongs to
ALTER TABLE routine_exercises ADD COLUMN day_label TEXT;

-- Set default value for existing exercises
UPDATE routine_exercises SET day_label = 'Day 1' WHERE day_label IS NULL;

-- Add index for performance
CREATE INDEX IF NOT EXISTS idx_routine_exercises_day_label ON routine_exercises(day_label);
```

### Step 2: Restart Backend Server

```bash
cd D:\Flutter\Gym\Pump-Fiction\backend
python -m uvicorn app.main:app --reload --port 8000
```

### Step 3: Restart Flutter App

```bash
cd D:\Flutter\Gym\Pump-Fiction\frontend
flutter run -d emulator-5554
```

## What Changed

**Before:**
- Backend saved: `[Bench, OHP, Deadlift, Rows, Squat, Lunges]` (no day info)
- Frontend loaded: One big mess with all exercises

**After:**
- Backend saves: 
  - `Bench` with `day_label="Push"`
  - `OHP` with `day_label="Push"`
  - `Deadlift` with `day_label="Pull"`
  - ... etc
- Frontend loads: Separate days with correct exercises! ✅

## Testing

1. Create a new routine with multiple days
2. Add exercises to each day (e.g., "Push", "Pull", "Legs")
3. Save it
4. **Close and restart the app** (this is the critical test!)
5. Go to Routine → Custom Routine → Click your routine
6. You should see ALL exercises organized by day! ✅

## Note About Existing Routines

Routines you created BEFORE this fix will have all exercises grouped into "Day 1". You'll need to:
- Either: Delete and recreate them
- Or: Edit them and re-save (the new structure will be applied)

## Files Modified

All changes have been made to:
- ✅ Database schema (add `day_label` column)
- ✅ Backend models and repositories
- ✅ Frontend models (save/load with day labels)

Just run the 3 steps above and you're good to go!
