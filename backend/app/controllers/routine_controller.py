from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from typing import List
from uuid import UUID

from ..core.dependencies import get_db, get_current_user
from ..services.routine_service import RoutineService
from ..schemas.routine_schema import (
    RoutineHeaderCreate,
    RoutineHeaderUpdate,
    RoutineHeaderResponse,
    RoutineHeaderListResponse,
)

router = APIRouter(prefix="/routines", tags=["Routines"])


@router.get("", response_model=List[RoutineHeaderListResponse])
async def get_all_routines(
    include_archived: bool = False,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),  # dict not UserResponse!
):
    """Get all routines for the current user."""
    service = RoutineService(db)
    return service.get_all_routines(current_user["id"], include_archived)


@router.get("/{routine_id}", response_model=RoutineHeaderResponse)
async def get_routine(
    routine_id: UUID,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),  # dict not UserResponse!
):
    """Get a specific routine with all exercises."""
    service = RoutineService(db)
    return service.get_routine_by_id(routine_id, current_user["id"])


@router.post("", response_model=RoutineHeaderResponse, status_code=status.HTTP_201_CREATED)
async def create_routine(
    routine_data: RoutineHeaderCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),  # dict not UserResponse!
):
    """Create a new routine with exercises."""
    service = RoutineService(db)
    return service.create_routine(current_user["id"], routine_data)


@router.put("/{routine_id}", response_model=RoutineHeaderResponse)
async def update_routine(
    routine_id: UUID,
    routine_data: RoutineHeaderUpdate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),  # dict not UserResponse!
):
    """Update a routine and its exercises."""
    service = RoutineService(db)
    return service.update_routine(routine_id, current_user["id"], routine_data)


@router.delete("/{routine_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_routine(
    routine_id: UUID,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),  # dict not UserResponse!
):
    """Delete a routine (exercises will be cascade deleted)."""
    service = RoutineService(db)
    service.delete_routine(routine_id, current_user["id"])


@router.patch("/{routine_id}/archive", response_model=RoutineHeaderResponse)
async def archive_routine(
    routine_id: UUID,
    is_archived: bool = True,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),  # dict not UserResponse!
):
    """Archive or unarchive a routine."""
    service = RoutineService(db)
    return service.archive_routine(routine_id, current_user["id"], is_archived)
