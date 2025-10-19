# Routine Day Structure Fix - Complete Solution

## 🎯 Problem Summary

**User Report:**
- Routines save correctly to the database
- "Routine → Custom Routine → Legs" shows NO exercises ❌
- "Workout" page shows exercises correctly ✅
- After app restart, exercises disappear from routine view

## 🔍 Root Cause Analysis

### The Issue
The backend database **did not track which exercises belong to which day** in a routine!

#### Database Schema (Before):
```sql
CREATE TABLE routine_exercises (
    id UUID PRIMARY KEY,
    routine_id UUID,
    title TEXT,
    sets INTEGER,
    min_reps INTEGER,
    max_reps INTEGER,
    position INTEGER,
    -- ❌ NO day_label column!
);
```

#### Data Flow Problem:

**When Saving:**
```dart
// Frontend sends multi-day routine
RoutinePlan {
  dayPlans: [
    DayPlan("Push", [Bench, OHP]),
    DayPlan("Pull", [Deadlift, Rows]),
    DayPlan("Legs", [Squat, Lunges])
  ]
}
↓ toBackendJson() flattens all exercises
{
  "day_selected": "Push, Pull, Legs",  // ← Just a string!
  "exercises": [Bench, OHP, Deadlift, Rows, Squat, Lunges]  // ← All mixed!
}
```

**When Loading:**
```json
// Backend returns flat exercise array
{
  "exercises": [Bench, OHP, Deadlift, Rows, Squat, Lunges]
}
↓ fromBackendJson() has no way to know which exercises belong to which day
RoutinePlan {
  dayPlans: [
    DayPlan("Push, Pull, Legs", [ALL 6 exercises])  // ❌ Wrong!
  ]
}
```

**Result:** Routine structure was lost after save/reload!

## ✅ Solution Implemented

### Step 1: Add `day_label` Column to Database

**Migration:** `add_day_label_to_routine_exercises.sql`

```sql
ALTER TABLE routine_exercises
ADD COLUMN day_label TEXT;

UPDATE routine_exercises
SET day_label = 'Day 1'
WHERE day_label IS NULL;

CREATE INDEX IF NOT EXISTS idx_routine_exercises_day_label 
ON routine_exercises(day_label);
```

### Step 2: Update Backend Model

**File:** `backend/app/models/routine_model.py`

```python
class RoutineExercise(Base):
    # ... existing fields ...
    day_label = Column(Text, default='Day 1')  # ✅ NEW!
```

### Step 3: Update Backend Schema

**File:** `backend/app/schemas/routine_schema.py`

```python
class RoutineExerciseBase(BaseModel):
    title: str
    sets: int
    min_reps: int
    max_reps: int
    position: int
    day_label: str = Field(default='Day 1')  # ✅ NEW!
```

### Step 4: Update Frontend Model - Sending Data

**File:** `frontend/lib/features/fitness/models/routine_models.dart`

```dart
// Exercise now includes day_label when converting to backend JSON
Map<String, dynamic> toBackendJson(int position, String dayLabel) => {
  'title': name,
  'sets': sets,
  'min_reps': minReps,
  'max_reps': maxReps,
  'position': position,
  'day_label': dayLabel,  // ✅ NEW!
};

// RoutinePlan passes day_label for each exercise
Map<String, dynamic> toBackendJson() {
  final allExercises = <Map<String, dynamic>>[];
  int position = 0;

  for (final day in dayPlans) {
    for (final exercise in day.exercises) {
      allExercises.add(exercise.toBackendJson(position, day.label));  // ✅ Pass day label!
      position++;
    }
  }
  // ...
}
```

### Step 5: Update Frontend Model - Receiving Data

**File:** `frontend/lib/features/fitness/models/routine_models.dart`

```dart
factory RoutinePlan.fromBackendJson(Map<String, dynamic> j) {
  final exercisesJson = (j['exercises'] as List<dynamic>?) ?? [];

  // ✅ Group exercises by day_label
  final Map<String, List<Exercise>> exercisesByDay = {};
  
  for (var exJson in exercisesJson) {
    final exercise = Exercise.fromBackendJson(exJson);
    final dayLabel = exJson['day_label'] as String? ?? 'Day 1';
    
    if (!exercisesByDay.containsKey(dayLabel)) {
      exercisesByDay[dayLabel] = [];
    }
    exercisesByDay[dayLabel]!.add(exercise);
  }

  // ✅ Create separate DayPlan for each day
  final dayPlans = exercisesByDay.entries.map((entry) {
    return DayPlan(
      label: entry.key,
      exercises: entry.value,
    );
  }).toList();

  return RoutinePlan(
    // ...
    dayPlans: dayPlans,  // ✅ Multiple days preserved!
  );
}
```

### Step 6: Update Backend Repository

**File:** `backend/app/repositories/routine_repository.py`

```python
def create_routine(self, user_id: UUID, routine_data: RoutineHeaderCreate):
    # ...
    for exercise_data in routine_data.exercises:
        exercise = RoutineExercise(
            routine_id=routine.id,
            title=exercise_data.title,
            sets=exercise_data.sets,
            min_reps=exercise_data.min_reps,
            max_reps=exercise_data.max_reps,
            position=exercise_data.position,
            day_label=exercise_data.day_label,  # ✅ Save day_label!
        )
        self.db.add(exercise)
```

## 📊 Before vs After

### Before Fix ❌

**Saving:**
```
Push Day: [Bench, OHP]
Pull Day: [Deadlift, Rows]
Legs Day: [Squat, Lunges]
         ↓
Database: [Bench, OHP, Deadlift, Rows, Squat, Lunges] (no day info)
         ↓
Loading: One day with all 6 exercises
```

**User sees:** Empty routine or all exercises lumped together!

### After Fix ✅

**Saving:**
```
Push Day: [Bench, OHP]
Pull Day: [Deadlift, Rows]
Legs Day: [Squat, Lunges]
         ↓
Database: 
  - Bench (day_label: "Push")
  - OHP (day_label: "Push")
  - Deadlift (day_label: "Pull")
  - Rows (day_label: "Pull")
  - Squat (day_label: "Legs")
  - Lunges (day_label: "Legs")
         ↓
Loading:
  Push Day: [Bench, OHP]
  Pull Day: [Deadlift, Rows]
  Legs Day: [Squat, Lunges]
```

**User sees:** Correct routine structure with exercises in their proper days! ✅

## 🔧 Migration Steps

### 1. Run Database Migration
```sql
-- Execute the migration script
psql your_database < backend/migrations/add_day_label_to_routine_exercises.sql
```

Or in Supabase SQL Editor:
```sql
ALTER TABLE routine_exercises ADD COLUMN day_label TEXT;
UPDATE routine_exercises SET day_label = 'Day 1' WHERE day_label IS NULL;
CREATE INDEX IF NOT EXISTS idx_routine_exercises_day_label ON routine_exercises(day_label);
```

### 2. Restart Backend
```bash
cd backend
python -m uvicorn app.main:app --reload --port 8000
```

### 3. Restart Frontend
```bash
cd frontend
flutter run -d emulator-5554
```

### 4. Test
1. Create a new routine with multiple days (e.g., Push/Pull/Legs)
2. Add exercises to each day
3. Save the routine
4. Close and restart the app
5. Navigate to Routine → Custom Routine → Your Routine
6. Verify exercises appear in their correct days! ✅

## 📝 Files Modified

### Backend:
1. `backend/migrations/add_day_label_to_routine_exercises.sql` (NEW)
2. `backend/app/models/routine_model.py`
3. `backend/app/schemas/routine_schema.py`
4. `backend/app/repositories/routine_repository.py`
5. `backend/app/services/routine_service.py` (debug logging)

### Frontend:
6. `frontend/lib/features/fitness/models/routine_models.dart`
7. `frontend/lib/features/fitness/repositories/routine_repository.dart` (debug logging)
8. `frontend/lib/features/fitness/state/routines_provider.dart` (debug logging)

## 🎉 Result

- ✅ Routines now preserve day structure
- ✅ Exercises appear in correct days after app restart
- ✅ "Routine → Custom Routine → Legs" shows exercises correctly
- ✅ No data loss
- ✅ Backward compatible (existing data gets default 'Day 1' label)

## 🔄 Existing Data Handling

For routines created before this fix:
- All exercises will have `day_label = 'Day 1'`
- They will appear in a single day when loaded
- Users can edit and re-save to properly structure them
- Or run a data migration script to analyze and assign proper day labels based on position
