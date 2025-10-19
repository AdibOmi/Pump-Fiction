from sqlalchemy.orm import Session
from typing import List
from uuid import UUID
from datetime import date
from fastapi import HTTPException, status

from ..repositories.workout_log_repository import WorkoutLogRepository
from ..schemas.workout_log_schema import (
    WorkoutLogCreate,
    WorkoutLogUpdate,
    WorkoutLogResponse,
    WorkoutLogListResponse,
)


class WorkoutLogService:
    def __init__(self, db: Session):
        self.repository = WorkoutLogRepository(db)

    def get_all_workout_logs(self, user_id: UUID, limit: int = 100) -> List[WorkoutLogResponse]:
        """Get all workout logs for a user."""
        workout_logs = self.repository.get_all_workout_logs(user_id, limit)
        return [WorkoutLogResponse.model_validate(log) for log in workout_logs]

    def get_workout_logs_list(self, user_id: UUID, limit: int = 100) -> List[WorkoutLogListResponse]:
        """Get workout logs with summary info (optimized for list view)."""
        workout_logs = self.repository.get_all_workout_logs(user_id, limit)

        return [
            WorkoutLogListResponse(
                id=log.id,
                user_id=log.user_id,
                workout_date=log.workout_date,
                routine_title=log.routine_title,
                day_label=log.day_label,
                exercise_count=len(log.exercises),
                total_sets=sum(len(ex.sets) for ex in log.exercises),
                created_at=log.created_at,
                updated_at=log.updated_at,
            )
            for log in workout_logs
        ]

    def get_workout_logs_by_date_range(
        self, user_id: UUID, start_date: date, end_date: date
    ) -> List[WorkoutLogResponse]:
        """Get workout logs within a date range."""
        workout_logs = self.repository.get_workout_logs_by_date_range(user_id, start_date, end_date)
        return [WorkoutLogResponse.model_validate(log) for log in workout_logs]

    def get_workout_log_by_id(self, log_id: UUID, user_id: UUID) -> WorkoutLogResponse:
        """Get a specific workout log with all exercises and sets."""
        workout_log = self.repository.get_workout_log_by_id(log_id, user_id)
        if not workout_log:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Workout log with id {log_id} not found",
            )
        return WorkoutLogResponse.model_validate(workout_log)

    def create_workout_log(self, user_id: UUID, log_data: WorkoutLogCreate) -> WorkoutLogResponse:
        """Create a new workout log with exercises and sets."""
        try:
            workout_log = self.repository.create_workout_log(user_id, log_data)
            return WorkoutLogResponse.model_validate(workout_log)
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error creating workout log: {str(e)}",
            )

    def update_workout_log(
        self, log_id: UUID, user_id: UUID, log_data: WorkoutLogUpdate
    ) -> WorkoutLogResponse:
        """Update a workout log and its exercises."""
        try:
            workout_log = self.repository.update_workout_log(log_id, user_id, log_data)
            if not workout_log:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Workout log with id {log_id} not found",
                )
            return WorkoutLogResponse.model_validate(workout_log)
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error updating workout log: {str(e)}",
            )

    def delete_workout_log(self, log_id: UUID, user_id: UUID) -> None:
        """Delete a workout log."""
        try:
            success = self.repository.delete_workout_log(log_id, user_id)
            if not success:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Workout log with id {log_id} not found",
                )
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error deleting workout log: {str(e)}",
            )

    def get_exercise_history(self, user_id: UUID, exercise_name: str) -> dict:
        """Get history of a specific exercise."""
        try:
            exercises = self.repository.get_exercise_history(user_id, exercise_name, limit=50)

            # Format the response
            history = []
            for exercise in exercises:
                workout_log = exercise.workout_log
                history.append({
                    "workout_date": workout_log.workout_date,
                    "routine_title": workout_log.routine_title,
                    "day_label": workout_log.day_label,
                    "sets": [
                        {"weight": s.weight, "reps": s.reps}
                        for s in exercise.sets
                    ],
                })

            return {
                "exercise_name": exercise_name,
                "history": history,
            }
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error fetching exercise history: {str(e)}",
            )

    def get_workout_stats(self, user_id: UUID) -> dict:
        """Get workout statistics for a user."""
        try:
            return self.repository.get_workout_stats(user_id)
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error fetching workout stats: {str(e)}",
            )
