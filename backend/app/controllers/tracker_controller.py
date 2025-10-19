from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from ..core.dependencies import get_db, get_current_user
from ..services.tracker_service import TrackerService
from ..schemas.tracker_schema import (
    TrackerCreate, TrackerUpdate, TrackerResponse, TrackerListResponse,
    TrackerEntryCreate, TrackerEntryUpdate, TrackerEntryResponse
)


router = APIRouter(prefix="/trackers", tags=["trackers"])


# Tracker endpoints
@router.get("", response_model=List[TrackerResponse])  # Removed leading slash
async def get_all_trackers(  # Made async
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Get all trackers for the current user with full entry data"""
    tracker_service = TrackerService(db)
    return tracker_service.get_all_trackers(current_user['id'])


@router.get("/list", response_model=List[TrackerListResponse])
async def get_trackers_list(  # Made async
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Get all trackers for the current user (optimized for list view without full entry data)"""
    tracker_service = TrackerService(db)
    return tracker_service.get_trackers_list(current_user['id'])


@router.get("/{tracker_id}", response_model=TrackerResponse)
async def get_tracker(  # Made async
    tracker_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Get a specific tracker by ID"""
    tracker_service = TrackerService(db)
    return tracker_service.get_tracker(tracker_id, current_user['id'])


@router.post("", response_model=TrackerResponse, status_code=status.HTTP_201_CREATED)  # Removed leading slash
async def create_tracker(  # Made async
    tracker_data: TrackerCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Create a new tracker"""
    tracker_service = TrackerService(db)
    return tracker_service.create_tracker(current_user['id'], tracker_data)


@router.put("/{tracker_id}", response_model=TrackerResponse)
async def update_tracker(  # Made async
    tracker_id: int,
    tracker_data: TrackerUpdate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Update a tracker"""
    tracker_service = TrackerService(db)
    return tracker_service.update_tracker(tracker_id, current_user['id'], tracker_data)


@router.delete("/{tracker_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_tracker(  # Made async
    tracker_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Delete a tracker"""
    tracker_service = TrackerService(db)
    tracker_service.delete_tracker(tracker_id, current_user['id'])
    return None


# TrackerEntry endpoints
@router.get("/{tracker_id}/entries", response_model=List[TrackerEntryResponse])
async def get_tracker_entries(  # Made async
    tracker_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Get all entries for a tracker"""
    tracker_service = TrackerService(db)
    return tracker_service.get_entries(tracker_id, current_user['id'])


@router.post("/{tracker_id}/entries", response_model=TrackerEntryResponse, status_code=status.HTTP_201_CREATED)
async def create_entry(  # Made async
    tracker_id: int,
    entry_data: TrackerEntryCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Create a new entry for a tracker"""
    tracker_service = TrackerService(db)
    return tracker_service.create_entry(tracker_id, current_user['id'], entry_data)


@router.put("/{tracker_id}/entries/{entry_id}", response_model=TrackerEntryResponse)
async def update_entry(  # Made async
    tracker_id: int,
    entry_id: int,
    entry_data: TrackerEntryUpdate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Update an entry"""
    tracker_service = TrackerService(db)
    return tracker_service.update_entry(entry_id, tracker_id, current_user['id'], entry_data)


@router.delete("/{tracker_id}/entries/{entry_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_entry(  # Made async
    tracker_id: int,
    entry_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Delete an entry"""
    tracker_service = TrackerService(db)
    tracker_service.delete_entry(entry_id, tracker_id, current_user['id'])
    return None
