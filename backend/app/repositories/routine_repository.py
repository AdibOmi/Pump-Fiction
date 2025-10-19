from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError
from typing import List, Optional
from uuid import UUID

from ..models.routine_model import RoutineHeader, RoutineExercise
from ..schemas.routine_schema import (
    RoutineHeaderCreate,
    RoutineHeaderUpdate,
    RoutineExerciseCreate,
)


class RoutineRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_all_routines(self, user_id: UUID) -> List[RoutineHeader]:
        """Get all routines for a user (non-archived only by default)."""
        return (
            self.db.query(RoutineHeader)
            .filter(RoutineHeader.user_id == user_id, RoutineHeader.is_archived == False)
            .order_by(RoutineHeader.created_at.desc())
            .all()
        )

    def get_all_routines_including_archived(self, user_id: UUID) -> List[RoutineHeader]:
        """Get all routines for a user including archived ones."""
        return (
            self.db.query(RoutineHeader)
            .filter(RoutineHeader.user_id == user_id)
            .order_by(RoutineHeader.created_at.desc())
            .all()
        )

    def get_routine_by_id(self, routine_id: UUID, user_id: UUID) -> Optional[RoutineHeader]:
        """Get a specific routine by ID, ensuring it belongs to the user."""
        return (
            self.db.query(RoutineHeader)
            .filter(RoutineHeader.id == routine_id, RoutineHeader.user_id == user_id)
            .first()
        )

    def create_routine(self, user_id: UUID, routine_data: RoutineHeaderCreate) -> RoutineHeader:
        """Create a new routine with exercises."""
        try:
            # 🐛 DEBUG: Log what we're receiving
            print(f"📥 Backend received routine data:")
            print(f"  Title: {routine_data.title}")
            print(f"  Day selected: {routine_data.day_selected}")
            print(f"  Exercises count: {len(routine_data.exercises)}")
            for i, ex in enumerate(routine_data.exercises):
                print(f"    Exercise {i}: {ex.title} - {ex.sets} sets, {ex.min_reps}-{ex.max_reps} reps, position {ex.position}")

            # Create the routine header
            routine = RoutineHeader(
                user_id=user_id,
                title=routine_data.title,
                day_selected=routine_data.day_selected,
                is_archived=routine_data.is_archived,
            )
            self.db.add(routine)
            self.db.flush()  # Get the ID without committing

            # Create exercises for this routine
            print(f"💾 Saving {len(routine_data.exercises)} exercises to database...")
            for exercise_data in routine_data.exercises:
                exercise = RoutineExercise(
                    routine_id=routine.id,
                    title=exercise_data.title,
                    sets=exercise_data.sets,
                    min_reps=exercise_data.min_reps,
                    max_reps=exercise_data.max_reps,
                    position=exercise_data.position,
                )
                self.db.add(exercise)

            self.db.commit()
            self.db.refresh(routine)
            return routine
        except SQLAlchemyError as e:
            self.db.rollback()
            raise e

    def update_routine(
        self, routine_id: UUID, user_id: UUID, routine_data: RoutineHeaderUpdate
    ) -> Optional[RoutineHeader]:
        """Update a routine and its exercises."""
        try:
            routine = self.get_routine_by_id(routine_id, user_id)
            if not routine:
                return None

            # Update routine header fields
            routine.title = routine_data.title
            routine.day_selected = routine_data.day_selected
            routine.is_archived = routine_data.is_archived

            # If exercises are provided, replace all existing exercises
            if routine_data.exercises is not None:
                # Delete existing exercises (cascade will handle this automatically)
                self.db.query(RoutineExercise).filter(
                    RoutineExercise.routine_id == routine_id
                ).delete()

                # Add new exercises
                for exercise_data in routine_data.exercises:
                    exercise = RoutineExercise(
                        routine_id=routine.id,
                        title=exercise_data.title,
                        sets=exercise_data.sets,
                        min_reps=exercise_data.min_reps,
                        max_reps=exercise_data.max_reps,
                        position=exercise_data.position,
                    )
                    self.db.add(exercise)

            self.db.commit()
            self.db.refresh(routine)
            return routine
        except SQLAlchemyError as e:
            self.db.rollback()
            raise e

    def delete_routine(self, routine_id: UUID, user_id: UUID) -> bool:
        """Delete a routine (exercises will be cascade deleted)."""
        try:
            routine = self.get_routine_by_id(routine_id, user_id)
            if not routine:
                return False

            self.db.delete(routine)
            self.db.commit()
            return True
        except SQLAlchemyError as e:
            self.db.rollback()
            raise e

    def archive_routine(self, routine_id: UUID, user_id: UUID, is_archived: bool) -> Optional[RoutineHeader]:
        """Archive or unarchive a routine."""
        try:
            routine = self.get_routine_by_id(routine_id, user_id)
            if not routine:
                return None

            routine.is_archived = is_archived
            self.db.commit()
            self.db.refresh(routine)
            return routine
        except SQLAlchemyError as e:
            self.db.rollback()
            raise e
