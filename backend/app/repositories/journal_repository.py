from typing import List, Optional
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import desc, asc
from ..models.journal_model import JournalSession, JournalEntry


class JournalRepository:
    def __init__(self, db: Session):
        self.db = db

    async def create_session(self, user_id: str, name: str) -> JournalSession:
        session = JournalSession(user_id=user_id, name=name)
        self.db.add(session)
        self.db.commit()
        self.db.refresh(session)
        return session

    async def list_sessions(self, user_id: str) -> List[JournalSession]:
        return (
            self.db.query(JournalSession)
            .filter(JournalSession.user_id == user_id)
            .order_by(desc(JournalSession.created_at))
            .all()
        )

    async def get_session(self, session_id: int, user_id: str) -> Optional[JournalSession]:
        return (
            self.db.query(JournalSession)
            .options(joinedload(JournalSession.entries))
            .filter(JournalSession.id == session_id, JournalSession.user_id == user_id)
            .first()
        )

    async def set_session_cover(self, session_id: int, cover_image_base64: str):
        session = self.db.query(JournalSession).filter(JournalSession.id == session_id).first()
        if session:
            session.cover_image_base64 = cover_image_base64
            self.db.commit()
            self.db.refresh(session)
        return session

    async def add_entry(self, session_id: int, image_base64: str, weight: Optional[float]) -> JournalEntry:
        entry = JournalEntry(
            session_id=session_id,
            image_base64=image_base64,
            weight=weight,
        )
        self.db.add(entry)
        self.db.commit()
        self.db.refresh(entry)
        return entry

    async def list_entries(self, session_id: int, user_id: str) -> List[JournalEntry]:
        # ensure session belongs to user
        session = (
            self.db.query(JournalSession)
            .filter(JournalSession.id == session_id, JournalSession.user_id == user_id)
            .first()
        )
        if not session:
            return []

        return (
            self.db.query(JournalEntry)
            .filter(JournalEntry.session_id == session_id)
            .order_by(asc(JournalEntry.date))
            .all()
        )
