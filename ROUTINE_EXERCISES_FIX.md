# Routine Exercises Loading Fix

## Problem Summary
Routine headers were loading successfully in the app, but routine exercises were not appearing even though they existed in the database.

## Root Cause Analysis

### Database Structure
The database has two tables:
- `routine_headers` - Stores routine metadata (title, day_selected, etc.)
- `routine_exercises` - Stores exercises for each routine (title, sets, reps, position)

Both tables had data, and the relationship was properly defined in the SQLAlchemy models with:
```python
exercises = relationship("RoutineExercise", back_populates="routine", cascade="all, delete-orphan", order_by="RoutineExercise.position")
```

### The Issue
The problem was in the API response structure:

1. **Backend GET `/routines` endpoint** was returning `RoutineHeaderListResponse` schema
2. **`RoutineHeaderListResponse`** intentionally **excluded exercises** for performance
   - It only included `exercise_count` (number of exercises)
   - The exercises themselves were NOT included

3. **Frontend `getAllRoutines()`** called this endpoint
4. **Frontend `fromBackendJson()`** tried to parse the response and extract exercises:
   ```dart
   final exercises = (j['exercises'] as List<dynamic>?)
       ?.map((e) => Exercise.fromBackendJson(e as Map<String, dynamic>))
       .toList() ?? [];
   ```
   - Since `exercises` was not in the JSON, it defaulted to an empty list `[]`

5. **Result**: Routines loaded but appeared empty (no exercises)

## Solution Applied

### Backend Changes

#### 1. Updated `routine_service.py`
Changed the return type and implementation of `get_all_routines()`:

**Before:**
```python
def get_all_routines(self, user_id: UUID, include_archived: bool = False) -> List[RoutineHeaderListResponse]:
    # ... returned simplified response WITHOUT exercises
    return [
        RoutineHeaderListResponse(
            id=routine.id,
            # ... other fields
            exercise_count=len(routine.exercises),  # ❌ Only count, no exercises
        )
        for routine in routines
    ]
```

**After:**
```python
def get_all_routines(self, user_id: UUID, include_archived: bool = False) -> List[RoutineHeaderResponse]:
    # ... return full response WITH exercises
    return [
        RoutineHeaderResponse.model_validate(routine)  # ✅ Includes exercises
        for routine in routines
    ]
```

#### 2. Updated `routine_controller.py`
Changed response model:

**Before:**
```python
@router.get("", response_model=List[RoutineHeaderListResponse])
```

**After:**
```python
@router.get("", response_model=List[RoutineHeaderResponse])
```

#### 3. Updated `routine_repository.py`
Added eager loading to ensure exercises are loaded efficiently:

**Before:**
```python
def get_all_routines(self, user_id: UUID) -> List[RoutineHeader]:
    return (
        self.db.query(RoutineHeader)
        .filter(...)
        .all()
    )
```

**After:**
```python
from sqlalchemy.orm import Session, joinedload

def get_all_routines(self, user_id: UUID) -> List[RoutineHeader]:
    return (
        self.db.query(RoutineHeader)
        .options(joinedload(RoutineHeader.exercises))  # ✅ Eager load exercises
        .filter(...)
        .all()
    )
```

This was applied to all three query methods:
- `get_all_routines()`
- `get_all_routines_including_archived()`
- `get_routine_by_id()`

## Response Schema Comparison

### RoutineHeaderListResponse (Old - Excluded Exercises)
```python
class RoutineHeaderListResponse(RoutineHeaderBase):
    id: UUID
    user_id: UUID
    exercise_count: int = 0  # ❌ Only the count
    created_at: datetime
    updated_at: Optional[datetime] = None
```

### RoutineHeaderResponse (Now Used - Includes Exercises)
```python
class RoutineHeaderResponse(RoutineHeaderBase):
    id: UUID
    user_id: UUID
    exercises: List[RoutineExerciseResponse] = []  # ✅ Full exercise data
    created_at: datetime
    updated_at: Optional[datetime] = None
```

## Testing the Fix

### Backend Test
1. Start the backend server
2. Make a GET request to `/routines`
3. Verify the response includes the `exercises` array with full exercise data

```bash
# In backend terminal
python -m uvicorn app.main:app --reload --port 8000
```

### Frontend Test
1. Restart the Flutter app
2. Navigate to the Routines page
3. Verify that routine exercises now appear correctly
4. Check that all exercise details are visible (name, sets, reps)

```bash
# In frontend terminal
flutter run -d emulator-5554
```

## Impact
- ✅ Routine exercises now load correctly on app startup
- ✅ All exercise data (title, sets, min_reps, max_reps, position) is available
- ✅ No data loss - existing routines and exercises are preserved
- ⚠️ Slightly larger API response size (includes full exercise data)
- ✅ Better user experience - exercises visible immediately

## Files Modified
1. `backend/app/services/routine_service.py`
2. `backend/app/controllers/routine_controller.py`
3. `backend/app/repositories/routine_repository.py`

## No Frontend Changes Needed
The frontend code was already correctly trying to parse exercises from the response. Once the backend started returning them, the frontend automatically works correctly.
