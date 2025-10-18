# Tracker Schema Fix - user_id Type Mismatch

## Problem
500 Internal Server Error when creating or retrieving trackers:

```
pydantic_core._pydantic_core.ValidationError: 1 validation error for TrackerResponse
user_id
  Input should be a valid integer [type=int_type, input_value=UUID('ec827cb5-bfcb-4b83-9d8d-d643b3a7fa04'), input_type=UUID]
```

## Root Cause

**Mismatch between database and Pydantic schema:**

1. **Database (`tracker_model.py`)**: Uses `UUID` type for `user_id`
   ```python
   user_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False)
   ```

2. **Pydantic Schema (`tracker_schema.py`)**: Expected `int` type
   ```python
   user_id: int  # ❌ WRONG!
   ```

3. **Result**: When trying to serialize the database model to JSON, Pydantic validation fails because UUID ≠ int

## The Fix

### File: `backend/app/schemas/tracker_schema.py`

**Added UUID import:**
```python
from uuid import UUID
```

**Updated TrackerResponse:**
```python
class TrackerResponse(TrackerBase):
    id: int
    user_id: UUID  # ✅ Changed from int to UUID
    entries: List[TrackerEntryResponse] = []
    created_at: datetime
    updated_at: datetime
```

**Updated TrackerListResponse:**
```python
class TrackerListResponse(TrackerBase):
    id: int
    user_id: UUID  # ✅ Changed from int to UUID
    entry_count: int = 0
    last_entry_date: Optional[datetime] = None
    last_entry_value: Optional[float] = None
    created_at: datetime
    updated_at: datetime
```

## Why This Happened

When we fixed the database models to use UUID for `user_id` (to match Supabase), we updated:
- ✅ `tracker_model.py` - Changed `user_id` to `UUID(as_uuid=True)`
- ✅ `user_model.py` - Changed `id` to `UUID(as_uuid=True)`
- ❌ **FORGOT** `tracker_schema.py` - Left as `int`

This created a validation mismatch.

## Database vs API Flow

```
Database (PostgreSQL/Supabase)
  ↓
user_id: UUID('ec827cb5-bfcb-4b83-9d8d-d643b3a7fa04')
  ↓
SQLAlchemy Model (tracker_model.py)
  ↓
user_id: UUID(as_uuid=True) ✅
  ↓
Pydantic Schema (tracker_schema.py)
  ↓
user_id: UUID ✅ (NOW FIXED - was int ❌)
  ↓
JSON Response to Frontend
  ↓
{
  "id": 1,
  "user_id": "ec827cb5-bfcb-4b83-9d8d-d643b3a7fa04",
  "name": "Sleep",
  ...
}
```

## Testing

**Restart the backend** (auto-reload should work but restart to be safe):
```bash
# If running, it will auto-reload
# Or manually restart:
cd backend
python -m uvicorn app.main:app --reload --port 8000
```

**Test in Flutter app:**
1. Go to Fitness → Progress → Your Trackers
2. Click "Add Tracker"
3. Fill in details (e.g., Sleep, Hours, 8)
4. Click "Add"
5. ✅ Should work without 500 error!

**Expected backend log:**
```
INFO: POST /trackers - 201 Created
✅ Tracker added successfully
```

## Status

✅ **FIXED** - Pydantic schema now matches database model UUID types.

All tracker endpoints should now work:
- ✅ GET /trackers
- ✅ POST /trackers
- ✅ PUT /trackers/{id}
- ✅ DELETE /trackers/{id}
- ✅ All entry endpoints

## Lesson Learned

When changing database column types, always update **both**:
1. **SQLAlchemy models** (database layer)
2. **Pydantic schemas** (API layer)

Otherwise, serialization will fail with validation errors!
