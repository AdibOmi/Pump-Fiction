import uuid
from typing import List, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, UploadFile
from ..repositories.journal_repository import JournalRepository
from ..models.journal_model import JournalSession, JournalEntry
from ..core.supabase_client import get_supabase_client


class JournalService:
    def __init__(self, db: Session):
        self.db = db
        self.repo = JournalRepository(db)
        self.supabase = get_supabase_client()
        self.storage_bucket = "journal"

    async def create_session(self, user_id: str, name: str) -> JournalSession:
        return await self.repo.create_session(user_id, name)

    async def list_sessions(self, user_id: str) -> List[JournalSession]:
        return await self.repo.list_sessions(user_id)

    async def add_entry(self, session_id: int, user_id: str, file: UploadFile, weight: Optional[float]) -> JournalEntry:
        # verify session belongs to user
        session = await self.repo.get_session(session_id, user_id)
        if not session:
            raise HTTPException(status_code=404, detail="Session not found")

        if not file.content_type.startswith('image/'):
            raise HTTPException(status_code=400, detail="Only image uploads are allowed")

        content = await file.read()
        ext = file.filename.split('.')[-1] if '.' in file.filename else 'jpg'
        filename = f"entry_{session_id}_{uuid.uuid4()}.{ext}"
        path = f"sessions/{session_id}/{filename}"

        result = self.supabase.storage.from_(self.storage_bucket).upload(
            path=path,
            file=content,
            file_options={"content-type": file.content_type}
        )

        if result.status_code != 200:
            raise HTTPException(status_code=500, detail="Failed to upload image")

        public_url = self.supabase.storage.from_(self.storage_bucket).get_public_url(path)

        entry = await self.repo.add_entry(session_id, public_url, path, weight)

        # set cover image if session doesn't have one
        if not session.cover_image_url:
            await self.repo.set_session_cover(session_id, public_url, path)

        return entry

    async def list_entries(self, session_id: int, user_id: str) -> List[JournalEntry]:
        return await self.repo.list_entries(session_id, user_id)
