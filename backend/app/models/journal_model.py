from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Float, Text
from sqlalchemy.orm import relationship
from datetime import datetime
from ..core.database import Base


class JournalSession(Base):
    __tablename__ = 'journal_sessions'

    id = Column(Integer, primary_key=True, index=True)
    # Supabase users.id is UUID; store as string
    user_id = Column(String, ForeignKey('users.id'), nullable=False, index=True)
    name = Column(String, nullable=False)
    # Store cover image as base64 string (no external storage dependency)
    cover_image_base64 = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Avoid ORM FK issues with Supabase managed users; no back_populates
    # user = relationship("User")
    entries = relationship(
        "JournalEntry",
        back_populates="session",
        cascade="all, delete-orphan",
        order_by="JournalEntry.date.asc()"
    )


class JournalEntry(Base):
    __tablename__ = 'journal_entries'

    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey('journal_sessions.id'), nullable=False, index=True)
    date = Column(DateTime, default=datetime.utcnow)
    # Store image content as base64 string
    image_base64 = Column(Text, nullable=False)
    weight = Column(Float, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    session = relationship("JournalSession", back_populates="entries")
