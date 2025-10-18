from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from uuid import UUID


# RoutineExercise Schemas
class RoutineExerciseBase(BaseModel):
    title: str = Field(..., min_length=1)
    sets: int = Field(default=1, ge=1)
    min_reps: int = Field(default=1, ge=1)
    max_reps: int = Field(default=1, ge=1)
    position: int = Field(default=0, ge=0)


class RoutineExerciseCreate(RoutineExerciseBase):
    pass


class RoutineExerciseUpdate(RoutineExerciseBase):
    pass


class RoutineExerciseResponse(RoutineExerciseBase):
    id: UUID
    routine_id: UUID
    created_at: datetime

    class Config:
        from_attributes = True


# RoutineHeader Schemas
class RoutineHeaderBase(BaseModel):
    title: str = Field(..., min_length=1)
    day_selected: Optional[str] = None
    is_archived: bool = False


class RoutineHeaderCreate(RoutineHeaderBase):
    exercises: List[RoutineExerciseCreate] = []


class RoutineHeaderUpdate(RoutineHeaderBase):
    exercises: Optional[List[RoutineExerciseCreate]] = None


class RoutineHeaderResponse(RoutineHeaderBase):
    id: UUID
    user_id: UUID  # ⚠️ UUID not int!
    exercises: List[RoutineExerciseResponse] = []
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Simplified list response (without exercises for performance)
class RoutineHeaderListResponse(RoutineHeaderBase):
    id: UUID
    user_id: UUID  # ⚠️ UUID not int!
    exercise_count: int = 0
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
