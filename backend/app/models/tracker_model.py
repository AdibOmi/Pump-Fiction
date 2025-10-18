from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
from ..core.database import Base


class Tracker(Base):
    __tablename__ = 'trackers'

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False)
    name = Column(String(255), nullable=False)
    unit = Column(String(50), nullable=False)  # e.g., kg, bpm, cm
    goal = Column(Float, nullable=True)  # Optional goal value
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    user = relationship("User", back_populates="trackers")
    entries = relationship("TrackerEntry", back_populates="tracker", cascade="all, delete-orphan")


class TrackerEntry(Base):
    __tablename__ = 'tracker_entries'

    id = Column(Integer, primary_key=True, index=True)
    tracker_id = Column(Integer, ForeignKey('trackers.id'), nullable=False)
    date = Column(DateTime, nullable=False)
    value = Column(Float, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationship
    tracker = relationship("Tracker", back_populates="entries")
