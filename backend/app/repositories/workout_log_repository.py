from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy import func, and_
from typing import List, Optional
from uuid import UUID
from datetime import date

from ..models.workout_log_model import WorkoutLog, WorkoutExercise, WorkoutSet
from ..schemas.workout_log_schema import WorkoutLogCreate, WorkoutLogUpdate


class WorkoutLogRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_all_workout_logs(self, user_id: UUID, limit: int = 100) -> List[WorkoutLog]:
        """Get all workout logs for a user, ordered by date descending."""
        return (
            self.db.query(WorkoutLog)
            .filter(WorkoutLog.user_id == user_id)
            .order_by(WorkoutLog.workout_date.desc())
            .limit(limit)
            .all()
        )

    def get_workout_logs_by_date_range(
        self, user_id: UUID, start_date: date, end_date: date
    ) -> List[WorkoutLog]:
        """Get workout logs within a date range."""
        return (
            self.db.query(WorkoutLog)
            .filter(
                and_(
                    WorkoutLog.user_id == user_id,
                    WorkoutLog.workout_date >= start_date,
                    WorkoutLog.workout_date <= end_date,
                )
            )
            .order_by(WorkoutLog.workout_date.desc())
            .all()
        )

    def get_workout_log_by_id(self, log_id: UUID, user_id: UUID) -> Optional[WorkoutLog]:
        """Get a specific workout log by ID, ensuring it belongs to the user."""
        return (
            self.db.query(WorkoutLog)
            .filter(WorkoutLog.id == log_id, WorkoutLog.user_id == user_id)
            .first()
        )

    def create_workout_log(self, user_id: UUID, log_data: WorkoutLogCreate) -> WorkoutLog:
        """Create a new workout log with exercises and sets."""
        try:
            # Create the workout log
            workout_log = WorkoutLog(
                user_id=user_id,
                workout_date=log_data.workout_date,
                routine_title=log_data.routine_title,
                day_label=log_data.day_label,
            )
            self.db.add(workout_log)
            self.db.flush()  # Get the ID without committing

            # Create exercises for this workout log
            for exercise_data in log_data.exercises:
                exercise = WorkoutExercise(
                    workout_log_id=workout_log.id,
                    exercise_name=exercise_data.exercise_name,
                    position=exercise_data.position,
                )
                self.db.add(exercise)
                self.db.flush()  # Get the exercise ID

                # Create sets for this exercise
                for set_data in exercise_data.sets:
                    workout_set = WorkoutSet(
                        workout_exercise_id=exercise.id,
                        weight=set_data.weight,
                        reps=set_data.reps,
                        position=set_data.position,
                    )
                    self.db.add(workout_set)

            self.db.commit()
            self.db.refresh(workout_log)
            return workout_log
        except SQLAlchemyError as e:
            self.db.rollback()
            raise e

    def update_workout_log(
        self, log_id: UUID, user_id: UUID, log_data: WorkoutLogUpdate
    ) -> Optional[WorkoutLog]:
        """Update a workout log and its exercises."""
        try:
            workout_log = self.get_workout_log_by_id(log_id, user_id)
            if not workout_log:
                return None

            # Update workout log fields
            workout_log.workout_date = log_data.workout_date
            workout_log.routine_title = log_data.routine_title
            workout_log.day_label = log_data.day_label

            # If exercises are provided, replace all existing exercises and sets
            if log_data.exercises is not None:
                # Delete existing exercises (cascade will delete sets)
                self.db.query(WorkoutExercise).filter(
                    WorkoutExercise.workout_log_id == log_id
                ).delete()

                # Add new exercises
                for exercise_data in log_data.exercises:
                    exercise = WorkoutExercise(
                        workout_log_id=workout_log.id,
                        exercise_name=exercise_data.exercise_name,
                        position=exercise_data.position,
                    )
                    self.db.add(exercise)
                    self.db.flush()  # Get the exercise ID

                    # Add sets for this exercise
                    for set_data in exercise_data.sets:
                        workout_set = WorkoutSet(
                            workout_exercise_id=exercise.id,
                            weight=set_data.weight,
                            reps=set_data.reps,
                            position=set_data.position,
                        )
                        self.db.add(workout_set)

            self.db.commit()
            self.db.refresh(workout_log)
            return workout_log
        except SQLAlchemyError as e:
            self.db.rollback()
            raise e

    def delete_workout_log(self, log_id: UUID, user_id: UUID) -> bool:
        """Delete a workout log (exercises and sets will be cascade deleted)."""
        try:
            workout_log = self.get_workout_log_by_id(log_id, user_id)
            if not workout_log:
                return False

            self.db.delete(workout_log)
            self.db.commit()
            return True
        except SQLAlchemyError as e:
            self.db.rollback()
            raise e

    def get_exercise_history(
        self, user_id: UUID, exercise_name: str, limit: int = 50
    ) -> List[WorkoutExercise]:
        """Get history of a specific exercise across all workouts."""
        return (
            self.db.query(WorkoutExercise)
            .join(WorkoutLog)
            .filter(
                and_(
                    WorkoutLog.user_id == user_id,
                    WorkoutExercise.exercise_name.ilike(f"%{exercise_name}%"),
                )
            )
            .order_by(WorkoutLog.workout_date.desc())
            .limit(limit)
            .all()
        )

    def get_workout_stats(self, user_id: UUID) -> dict:
        """Get workout statistics for a user."""
        total_workouts = (
            self.db.query(func.count(WorkoutLog.id))
            .filter(WorkoutLog.user_id == user_id)
            .scalar()
        )

        total_exercises = (
            self.db.query(func.count(WorkoutExercise.id))
            .join(WorkoutLog)
            .filter(WorkoutLog.user_id == user_id)
            .scalar()
        )

        total_sets = (
            self.db.query(func.count(WorkoutSet.id))
            .join(WorkoutExercise)
            .join(WorkoutLog)
            .filter(WorkoutLog.user_id == user_id)
            .scalar()
        )

        return {
            "total_workouts": total_workouts or 0,
            "total_exercises": total_exercises or 0,
            "total_sets": total_sets or 0,
        }
