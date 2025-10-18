from typing import List, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status

from ..repositories.tracker_repository import TrackerRepository
from ..schemas.tracker_schema import (
    TrackerCreate, TrackerUpdate, TrackerResponse, TrackerListResponse,
    TrackerEntryCreate, TrackerEntryUpdate, TrackerEntryResponse
)
from ..models.tracker_model import Tracker, TrackerEntry


class TrackerService:
    """Service layer for tracker business logic"""

    def __init__(self, db: Session):
        self.repository = TrackerRepository(db)

    # Tracker operations
    def get_tracker(self, tracker_id: int, user_id: int) -> TrackerResponse:
        """Get a tracker by ID"""
        tracker = self.repository.get_tracker_by_id(tracker_id, user_id)
        if not tracker:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Tracker not found"
            )

        # Sort entries by date (newest first) before returning
        tracker.entries.sort(key=lambda e: e.date, reverse=True)
        return TrackerResponse.from_orm(tracker)

    def get_all_trackers(self, user_id: int) -> List[TrackerResponse]:
        """Get all trackers for a user with full entry data"""
        trackers = self.repository.get_trackers_by_user(user_id)

        # Sort entries within each tracker
        for tracker in trackers:
            tracker.entries.sort(key=lambda e: e.date, reverse=True)

        return [TrackerResponse.from_orm(tracker) for tracker in trackers]

    def get_trackers_list(self, user_id: int) -> List[TrackerListResponse]:
        """Get all trackers for a user (optimized for list view)"""
        trackers = self.repository.get_trackers_list_by_user(user_id)

        result = []
        for tracker in trackers:
            # Get last entry info if exists
            last_entry_date = None
            last_entry_value = None
            entry_count = len(tracker.entries)

            if tracker.entries:
                # Sort to get the latest entry
                sorted_entries = sorted(tracker.entries, key=lambda e: e.date, reverse=True)
                last_entry_date = sorted_entries[0].date
                last_entry_value = sorted_entries[0].value

            result.append(TrackerListResponse(
                id=tracker.id,
                user_id=tracker.user_id,
                name=tracker.name,
                unit=tracker.unit,
                goal=tracker.goal,
                entry_count=entry_count,
                last_entry_date=last_entry_date,
                last_entry_value=last_entry_value,
                created_at=tracker.created_at,
                updated_at=tracker.updated_at
            ))

        return result

    def create_tracker(self, user_id: int, tracker_data: TrackerCreate) -> TrackerResponse:
        """Create a new tracker"""
        tracker = self.repository.create_tracker(user_id, tracker_data)
        return TrackerResponse.from_orm(tracker)

    def update_tracker(self, tracker_id: int, user_id: int, tracker_data: TrackerUpdate) -> TrackerResponse:
        """Update a tracker"""
        tracker = self.repository.update_tracker(tracker_id, user_id, tracker_data)
        if not tracker:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Tracker not found"
            )

        tracker.entries.sort(key=lambda e: e.date, reverse=True)
        return TrackerResponse.from_orm(tracker)

    def delete_tracker(self, tracker_id: int, user_id: int) -> bool:
        """Delete a tracker"""
        success = self.repository.delete_tracker(tracker_id, user_id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Tracker not found"
            )
        return True

    # TrackerEntry operations
    def get_entries(self, tracker_id: int, user_id: int) -> List[TrackerEntryResponse]:
        """Get all entries for a tracker"""
        entries = self.repository.get_entries_by_tracker(tracker_id, user_id)
        return [TrackerEntryResponse.from_orm(entry) for entry in entries]

    def create_entry(self, tracker_id: int, user_id: int, entry_data: TrackerEntryCreate) -> TrackerEntryResponse:
        """Create a new entry"""
        entry = self.repository.create_entry(tracker_id, user_id, entry_data)
        if not entry:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Tracker not found"
            )
        return TrackerEntryResponse.from_orm(entry)

    def update_entry(self, entry_id: int, tracker_id: int, user_id: int, entry_data: TrackerEntryUpdate) -> TrackerEntryResponse:
        """Update an entry"""
        entry = self.repository.update_entry(entry_id, tracker_id, user_id, entry_data)
        if not entry:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Entry not found"
            )
        return TrackerEntryResponse.from_orm(entry)

    def delete_entry(self, entry_id: int, tracker_id: int, user_id: int) -> bool:
        """Delete an entry"""
        success = self.repository.delete_entry(entry_id, tracker_id, user_id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Entry not found"
            )
        return True
