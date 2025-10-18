from typing import List, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException
from ..repositories.journal_repository import JournalRepository
from ..models.journal_model import JournalSession, JournalEntry


class JournalService:
    def __init__(self, db: Session):
        self.db = db
        self.repo = JournalRepository(db)

    async def create_session(self, user_id: str, name: str) -> JournalSession:
        return await self.repo.create_session(user_id, name)

    async def list_sessions(self, user_id: str) -> List[JournalSession]:
        return await self.repo.list_sessions(user_id)

    async def add_entry(self, session_id: int, user_id: str, image_base64: str, weight: Optional[float]) -> JournalEntry:
        # verify session belongs to user
        session = await self.repo.get_session(session_id, user_id)
        if not session:
            raise HTTPException(status_code=404, detail="Session not found")

        if not image_base64 or ';base64,' not in image_base64:
            raise HTTPException(status_code=400, detail="image_base64 must be a data URI like data:image/jpeg;base64,<...>")

        entry = await self.repo.add_entry(session_id, image_base64, weight)

        # set cover image if session doesn't have one
        if not session.cover_image_base64:
            await self.repo.set_session_cover(session_id, image_base64)

        return entry

    async def list_entries(self, session_id: int, user_id: str) -> List[JournalEntry]:
        return await self.repo.list_entries(session_id, user_id)
