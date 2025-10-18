from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel


class JournalSessionCreate(BaseModel):
    name: str


class JournalSessionResponse(BaseModel):
    id: int
    name: str
    cover_image_url: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


class JournalEntryCreate(BaseModel):
    weight: Optional[float] = None


class JournalEntryResponse(BaseModel):
    id: int
    session_id: int
    date: datetime
    image_url: str
    weight: Optional[float] = None
    created_at: datetime

    class Config:
        from_attributes = True


class JournalEntriesListResponse(BaseModel):
    entries: List[JournalEntryResponse]
