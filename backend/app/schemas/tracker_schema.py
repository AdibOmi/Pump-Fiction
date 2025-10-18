from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from uuid import UUID


# TrackerEntry Schemas
class TrackerEntryBase(BaseModel):
    date: datetime
    value: float


class TrackerEntryCreate(TrackerEntryBase):
    pass


class TrackerEntryUpdate(TrackerEntryBase):
    pass


class TrackerEntryResponse(TrackerEntryBase):
    id: int
    tracker_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# Tracker Schemas
class TrackerBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    unit: str = Field(..., min_length=1, max_length=50)
    goal: Optional[float] = None


class TrackerCreate(TrackerBase):
    pass


class TrackerUpdate(TrackerBase):
    pass


class TrackerResponse(TrackerBase):
    id: int
    user_id: UUID  # Changed from int to UUID
    entries: List[TrackerEntryResponse] = []
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# Simplified response for list views (without entries for performance)
class TrackerListResponse(TrackerBase):
    id: int
    user_id: UUID  # Changed from int to UUID
    entry_count: int = 0
    last_entry_date: Optional[datetime] = None
    last_entry_value: Optional[float] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
