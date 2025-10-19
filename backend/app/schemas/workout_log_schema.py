from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime, date
from uuid import UUID


# ============================================
# WorkoutSet Schemas
# ============================================
class WorkoutSetBase(BaseModel):
    weight: float = Field(..., ge=0)
    reps: int = Field(..., ge=1)
    position: int = Field(default=0, ge=0)


class WorkoutSetCreate(WorkoutSetBase):
    pass


class WorkoutSetUpdate(WorkoutSetBase):
    pass


class WorkoutSetResponse(WorkoutSetBase):
    id: UUID
    workout_exercise_id: UUID
    created_at: datetime

    class Config:
        from_attributes = True


# ============================================
# WorkoutExercise Schemas
# ============================================
class WorkoutExerciseBase(BaseModel):
    exercise_name: str = Field(..., min_length=1)
    position: int = Field(default=0, ge=0)


class WorkoutExerciseCreate(WorkoutExerciseBase):
    sets: List[WorkoutSetCreate] = []


class WorkoutExerciseUpdate(WorkoutExerciseBase):
    sets: Optional[List[WorkoutSetCreate]] = None


class WorkoutExerciseResponse(WorkoutExerciseBase):
    id: UUID
    workout_log_id: UUID
    sets: List[WorkoutSetResponse] = []
    created_at: datetime

    class Config:
        from_attributes = True


# ============================================
# WorkoutLog Schemas
# ============================================
class WorkoutLogBase(BaseModel):
    workout_date: date
    routine_title: Optional[str] = None
    day_label: Optional[str] = None


class WorkoutLogCreate(WorkoutLogBase):
    exercises: List[WorkoutExerciseCreate] = []


class WorkoutLogUpdate(WorkoutLogBase):
    exercises: Optional[List[WorkoutExerciseCreate]] = None


class WorkoutLogResponse(WorkoutLogBase):
    id: UUID
    user_id: UUID  # ⚠️ UUID not int! (Learned from previous mistakes)
    exercises: List[WorkoutExerciseResponse] = []
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Simplified list response (without exercises for performance)
class WorkoutLogListResponse(WorkoutLogBase):
    id: UUID
    user_id: UUID  # ⚠️ UUID not int!
    exercise_count: int = 0
    total_sets: int = 0
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
