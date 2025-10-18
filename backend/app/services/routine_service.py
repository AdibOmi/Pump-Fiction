from sqlalchemy.orm import Session
from typing import List
from uuid import UUID
from fastapi import HTTPException, status

from ..repositories.routine_repository import RoutineRepository
from ..schemas.routine_schema import (
    RoutineHeaderCreate,
    RoutineHeaderUpdate,
    RoutineHeaderResponse,
    RoutineHeaderListResponse,
)


class RoutineService:
    def __init__(self, db: Session):
        self.repository = RoutineRepository(db)

    def get_all_routines(self, user_id: UUID, include_archived: bool = False) -> List[RoutineHeaderListResponse]:
        """Get all routines for a user."""
        if include_archived:
            routines = self.repository.get_all_routines_including_archived(user_id)
        else:
            routines = self.repository.get_all_routines(user_id)

        # Convert to list response (without exercises for performance)
        return [
            RoutineHeaderListResponse(
                id=routine.id,
                user_id=routine.user_id,
                title=routine.title,
                day_selected=routine.day_selected,
                is_archived=routine.is_archived,
                exercise_count=len(routine.exercises),
                created_at=routine.created_at,
                updated_at=routine.updated_at,
            )
            for routine in routines
        ]

    def get_routine_by_id(self, routine_id: UUID, user_id: UUID) -> RoutineHeaderResponse:
        """Get a specific routine with all its exercises."""
        routine = self.repository.get_routine_by_id(routine_id, user_id)
        if not routine:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Routine with id {routine_id} not found",
            )
        return RoutineHeaderResponse.model_validate(routine)

    def create_routine(self, user_id: UUID, routine_data: RoutineHeaderCreate) -> RoutineHeaderResponse:
        """Create a new routine with exercises."""
        try:
            routine = self.repository.create_routine(user_id, routine_data)
            return RoutineHeaderResponse.model_validate(routine)
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error creating routine: {str(e)}",
            )

    def update_routine(
        self, routine_id: UUID, user_id: UUID, routine_data: RoutineHeaderUpdate
    ) -> RoutineHeaderResponse:
        """Update a routine and its exercises."""
        try:
            routine = self.repository.update_routine(routine_id, user_id, routine_data)
            if not routine:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Routine with id {routine_id} not found",
                )
            return RoutineHeaderResponse.model_validate(routine)
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error updating routine: {str(e)}",
            )

    def delete_routine(self, routine_id: UUID, user_id: UUID) -> None:
        """Delete a routine."""
        try:
            success = self.repository.delete_routine(routine_id, user_id)
            if not success:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Routine with id {routine_id} not found",
                )
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error deleting routine: {str(e)}",
            )

    def archive_routine(self, routine_id: UUID, user_id: UUID, is_archived: bool) -> RoutineHeaderResponse:
        """Archive or unarchive a routine."""
        try:
            routine = self.repository.archive_routine(routine_id, user_id, is_archived)
            if not routine:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Routine with id {routine_id} not found",
                )
            return RoutineHeaderResponse.model_validate(routine)
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error archiving routine: {str(e)}",
            )
