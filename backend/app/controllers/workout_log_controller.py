from fastapi import APIRouter, Depends, status, Query
from sqlalchemy.orm import Session
from typing import List
from uuid import UUID
from datetime import date

from ..core.dependencies import get_db, get_current_user
from ..services.workout_log_service import WorkoutLogService
from ..schemas.workout_log_schema import (
    WorkoutLogCreate,
    WorkoutLogUpdate,
    WorkoutLogResponse,
    WorkoutLogListResponse,
)

router = APIRouter(prefix="/workout-logs", tags=["Workout Logs"])


@router.get("", response_model=List[WorkoutLogResponse])
async def get_all_workout_logs(
    limit: int = Query(default=100, ge=1, le=500),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),  # dict not UserResponse!
):
    """Get all workout logs for the current user with full exercise and set data."""
    service = WorkoutLogService(db)
    return service.get_all_workout_logs(current_user["id"], limit)


@router.get("/list", response_model=List[WorkoutLogListResponse])
async def get_workout_logs_list(
    limit: int = Query(default=100, ge=1, le=500),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    """Get all workout logs for the current user (optimized for list view without full exercise data)."""
    service = WorkoutLogService(db)
    return service.get_workout_logs_list(current_user["id"], limit)


@router.get("/date-range", response_model=List[WorkoutLogResponse])
async def get_workout_logs_by_date_range(
    start_date: date = Query(..., description="Start date (YYYY-MM-DD)"),
    end_date: date = Query(..., description="End date (YYYY-MM-DD)"),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    """Get workout logs within a date range."""
    service = WorkoutLogService(db)
    return service.get_workout_logs_by_date_range(current_user["id"], start_date, end_date)


@router.get("/{log_id}", response_model=WorkoutLogResponse)
async def get_workout_log(
    log_id: UUID,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    """Get a specific workout log with all exercises and sets."""
    service = WorkoutLogService(db)
    return service.get_workout_log_by_id(log_id, current_user["id"])


@router.post("", response_model=WorkoutLogResponse, status_code=status.HTTP_201_CREATED)
async def create_workout_log(
    log_data: WorkoutLogCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    """Create a new workout log with exercises and sets."""
    service = WorkoutLogService(db)
    return service.create_workout_log(current_user["id"], log_data)


@router.put("/{log_id}", response_model=WorkoutLogResponse)
async def update_workout_log(
    log_id: UUID,
    log_data: WorkoutLogUpdate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    """Update a workout log and its exercises."""
    service = WorkoutLogService(db)
    return service.update_workout_log(log_id, current_user["id"], log_data)


@router.delete("/{log_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_workout_log(
    log_id: UUID,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    """Delete a workout log (exercises and sets will be cascade deleted)."""
    service = WorkoutLogService(db)
    service.delete_workout_log(log_id, current_user["id"])


@router.get("/exercise/{exercise_name}/history", response_model=dict)
async def get_exercise_history(
    exercise_name: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    """Get history of a specific exercise across all workouts."""
    service = WorkoutLogService(db)
    return service.get_exercise_history(current_user["id"], exercise_name)


@router.get("/stats/summary", response_model=dict)
async def get_workout_stats(
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    """Get workout statistics for the current user."""
    service = WorkoutLogService(db)
    return service.get_workout_stats(current_user["id"])
