# Workout Page - "No Exercises" Issue - Debug Guide

## Problem
The workout page shows "Your routine has no exercises yet" even though routines and exercises exist in the database.

## What I've Analyzed

### Frontend Code (✅ Looks Correct)
- [workout_page.dart:67](frontend/lib/features/fitness/workout/workout_page.dart#L67) - Filters days with exercises: `selected.dayPlans.where((d) => d.exercises.isNotEmpty)`
- [routine_models.dart:151-200](frontend/lib/features/fitness/models/routine_models.dart#L151-L200) - `fromBackendJson()` groups exercises by `day_label`
- [routine_repository.dart:12-39](frontend/lib/features/fitness/repositories/routine_repository.dart#L12-L39) - Fetches routines with debug logging
- [routines_provider.dart:15-29](frontend/lib/features/fitness/state/routines_provider.dart#L15-L29) - Loads routines on startup

### Backend Code (✅ Looks Correct)
- [routine_repository.py:18-26](backend/app/repositories/routine_repository.py#L18-L26) - Uses `joinedload(RoutineHeader.exercises)` to eager load exercises
- [routine_model.py:22](backend/app/models/routine_model.py#L22) - Relationship defined with proper cascade
- [routine_schema.py:49-58](backend/app/schemas/routine_schema.py#L49-L58) - Response schema includes exercises
- [routine_service.py:18-40](backend/app/services/routine_service.py#L18-L40) - Service layer with debug logging

## Diagnostic Steps

### Step 1: Check Backend Logs
When the app starts and loads routines, you should see these logs in your backend console:

```
🔍 Service: Getting routines for user <uuid>, include_archived=False
📦 Service: Found X routines
   - <Routine Name>: X exercises
      • <Exercise Name> - X sets
✅ Service: Returning X routines with exercises
```

**If you DON'T see exercises listed**, the problem is in the database or the backend query.

### Step 2: Check Frontend Logs
In your Flutter app console, you should see:

```
📥 Fetching routines from backend...
📦 Backend response received: [...]
🔍 Parsing routine: <Routine Name>
   Exercises in response: X
   Exercises after parsing: X
✅ Total routines loaded: X
```

**If "Exercises in response: 0"**, the backend isn't returning exercises.
**If "Exercises after parsing: 0"**, the frontend parsing is failing.

### Step 3: Test the API Directly

Run this command (replace `<YOUR_TOKEN>` with a valid JWT token):

```bash
curl -H "Authorization: Bearer <YOUR_TOKEN>" \
  http://localhost:8000/api/v1/routines
```

Check the JSON response. Each routine should have an `exercises` array:

```json
[
  {
    "id": "...",
    "title": "My Routine",
    "exercises": [
      {
        "id": "...",
        "title": "Bench Press",
        "sets": 3,
        "min_reps": 8,
        "max_reps": 12,
        "day_label": "Push",
        ...
      }
    ]
  }
]
```

**If `exercises` is empty** `[]`, the backend query isn't loading them.

### Step 4: Check Database Directly

Query the database:

```sql
-- Check routine headers
SELECT id, title, day_selected FROM routine_headers WHERE is_archived = false;

-- Check exercises for a specific routine (replace <routine_id>)
SELECT title, sets, min_reps, max_reps, day_label, position
FROM routine_exercises
WHERE routine_id = '<routine_id>'
ORDER BY position;
```

## Most Likely Causes

### 1. Exercises Not Saved to Database
- When creating a routine, exercises might not be getting saved
- Check the backend logs when creating a routine - you should see:
  ```
  📥 Backend received routine data:
    Title: ...
    Exercises count: X
  💾 Saving X exercises to database...
  ✅ Routine created with X exercises
  ```

### 2. SQLAlchemy Relationship Not Loading
- The `joinedload(RoutineHeader.exercises)` might not be working
- This could be due to:
  - Session issues
  - Incorrect relationship configuration
  - Missing foreign keys

### 3. Pydantic Serialization Issue
- The exercises might be loaded but not serialized correctly
- Check if `from_attributes = True` is working

## Quick Fix to Try

### Option 1: Explicitly Query Exercises
Edit [backend/app/repositories/routine_repository.py](backend/app/repositories/routine_repository.py#L18-L26):

```python
def get_all_routines(self, user_id: UUID) -> List[RoutineHeader]:
    """Get all routines for a user (non-archived only by default)."""
    routines = (
        self.db.query(RoutineHeader)
        .filter(RoutineHeader.user_id == user_id, RoutineHeader.is_archived == False)
        .order_by(RoutineHeader.created_at.desc())
        .all()
    )

    # Explicitly load exercises for each routine
    for routine in routines:
        # This forces SQLAlchemy to load the relationship
        _ = routine.exercises
        print(f"Routine {routine.title} has {len(routine.exercises)} exercises loaded")

    return routines
```

### Option 2: Manual Join Query
Replace the joinedload with a manual join:

```python
from sqlalchemy import and_

def get_all_routines(self, user_id: UUID) -> List[RoutineHeader]:
    routines = (
        self.db.query(RoutineHeader)
        .outerjoin(RoutineExercise)
        .filter(
            and_(
                RoutineHeader.user_id == user_id,
                RoutineHeader.is_archived == False
            )
        )
        .order_by(RoutineHeader.created_at.desc())
        .all()
    )
    return routines
```

## Need More Help?

1. **Share the backend logs** when the app loads routines
2. **Share the Flutter console logs** when the workout page loads
3. **Share the API response** from the curl command
4. **Share the database query results**

This will help pinpoint exactly where the data is getting lost!
