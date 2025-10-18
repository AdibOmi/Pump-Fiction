from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from ..core.dependencies import get_db, get_current_user
from ..services.journal_service import JournalService
from ..schemas.journal_schema import (
    JournalSessionCreate, JournalSessionResponse,
    JournalEntryCreate, JournalEntryResponse, JournalEntriesListResponse
)


router = APIRouter(prefix="/journal", tags=["journal"])


@router.post("/sessions", response_model=JournalSessionResponse)
async def create_session(
    data: JournalSessionCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    service = JournalService(db)
    session = await service.create_session(current_user["id"], data.name)
    return session


@router.get("/sessions", response_model=List[JournalSessionResponse])
async def list_sessions(
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    service = JournalService(db)
    sessions = await service.list_sessions(current_user["id"])
    return sessions


@router.post("/sessions/{session_id}/entries", response_model=JournalEntryResponse)
async def add_entry(
    session_id: int,
    weight: Optional[float] = Form(None),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    service = JournalService(db)
    entry = await service.add_entry(session_id, current_user["id"], file, weight)
    return entry


@router.get("/sessions/{session_id}/entries", response_model=JournalEntriesListResponse)
async def list_entries(
    session_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    service = JournalService(db)
    entries = await service.list_entries(session_id, current_user["id"])
    return JournalEntriesListResponse(entries=entries)
