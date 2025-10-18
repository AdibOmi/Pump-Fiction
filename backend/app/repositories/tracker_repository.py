from sqlalchemy.orm import Session, joinedload
from sqlalchemy import desc
from typing import List, Optional
from datetime import datetime

from ..models.tracker_model import Tracker, TrackerEntry
from ..schemas.tracker_schema import TrackerCreate, TrackerUpdate, TrackerEntryCreate, TrackerEntryUpdate


class TrackerRepository:
    """Repository for tracker data access operations"""

    def __init__(self, db: Session):
        self.db = db

    # Tracker CRUD operations
    def get_tracker_by_id(self, tracker_id: int, user_id: int) -> Optional[Tracker]:
        """Get a tracker by ID and user ID (with entries loaded)"""
        return self.db.query(Tracker)\
            .options(joinedload(Tracker.entries))\
            .filter(Tracker.id == tracker_id, Tracker.user_id == user_id)\
            .first()

    def get_trackers_by_user(self, user_id: int) -> List[Tracker]:
        """Get all trackers for a user (with entries loaded)"""
        return self.db.query(Tracker)\
            .options(joinedload(Tracker.entries))\
            .filter(Tracker.user_id == user_id)\
            .order_by(desc(Tracker.created_at))\
            .all()

    def get_trackers_list_by_user(self, user_id: int) -> List[Tracker]:
        """Get all trackers for a user (without entries for list view performance)"""
        return self.db.query(Tracker)\
            .filter(Tracker.user_id == user_id)\
            .order_by(desc(Tracker.created_at))\
            .all()

    def create_tracker(self, user_id: int, tracker_data: TrackerCreate) -> Tracker:
        """Create a new tracker"""
        db_tracker = Tracker(
            user_id=user_id,
            name=tracker_data.name,
            unit=tracker_data.unit,
            goal=tracker_data.goal
        )
        self.db.add(db_tracker)
        self.db.commit()
        self.db.refresh(db_tracker)
        return db_tracker

    def update_tracker(self, tracker_id: int, user_id: int, tracker_data: TrackerUpdate) -> Optional[Tracker]:
        """Update an existing tracker"""
        db_tracker = self.get_tracker_by_id(tracker_id, user_id)
        if not db_tracker:
            return None

        db_tracker.name = tracker_data.name
        db_tracker.unit = tracker_data.unit
        db_tracker.goal = tracker_data.goal
        db_tracker.updated_at = datetime.utcnow()

        self.db.commit()
        self.db.refresh(db_tracker)
        return db_tracker

    def delete_tracker(self, tracker_id: int, user_id: int) -> bool:
        """Delete a tracker (cascade deletes entries)"""
        db_tracker = self.get_tracker_by_id(tracker_id, user_id)
        if not db_tracker:
            return False

        self.db.delete(db_tracker)
        self.db.commit()
        return True

    # TrackerEntry CRUD operations
    def get_entry_by_id(self, entry_id: int, tracker_id: int, user_id: int) -> Optional[TrackerEntry]:
        """Get an entry by ID, ensuring it belongs to user's tracker"""
        return self.db.query(TrackerEntry)\
            .join(Tracker)\
            .filter(
                TrackerEntry.id == entry_id,
                TrackerEntry.tracker_id == tracker_id,
                Tracker.user_id == user_id
            ).first()

    def get_entries_by_tracker(self, tracker_id: int, user_id: int) -> List[TrackerEntry]:
        """Get all entries for a tracker"""
        # First verify the tracker belongs to the user
        tracker = self.get_tracker_by_id(tracker_id, user_id)
        if not tracker:
            return []

        return self.db.query(TrackerEntry)\
            .filter(TrackerEntry.tracker_id == tracker_id)\
            .order_by(desc(TrackerEntry.date))\
            .all()

    def create_entry(self, tracker_id: int, user_id: int, entry_data: TrackerEntryCreate) -> Optional[TrackerEntry]:
        """Create a new entry for a tracker"""
        # Verify tracker belongs to user
        tracker = self.get_tracker_by_id(tracker_id, user_id)
        if not tracker:
            return None

        db_entry = TrackerEntry(
            tracker_id=tracker_id,
            date=entry_data.date,
            value=entry_data.value
        )
        self.db.add(db_entry)
        self.db.commit()
        self.db.refresh(db_entry)
        return db_entry

    def update_entry(self, entry_id: int, tracker_id: int, user_id: int, entry_data: TrackerEntryUpdate) -> Optional[TrackerEntry]:
        """Update an existing entry"""
        db_entry = self.get_entry_by_id(entry_id, tracker_id, user_id)
        if not db_entry:
            return None

        db_entry.date = entry_data.date
        db_entry.value = entry_data.value
        db_entry.updated_at = datetime.utcnow()

        self.db.commit()
        self.db.refresh(db_entry)
        return db_entry

    def delete_entry(self, entry_id: int, tracker_id: int, user_id: int) -> bool:
        """Delete an entry"""
        db_entry = self.get_entry_by_id(entry_id, tracker_id, user_id)
        if not db_entry:
            return False

        self.db.delete(db_entry)
        self.db.commit()
        return True
