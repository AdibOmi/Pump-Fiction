from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
from ..core.database import Base
import uuid


class RoutineHeader(Base):
    __tablename__ = 'routine_headers'

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False)
    title = Column(Text, nullable=False)
    day_selected = Column(Text, nullable=True)  # e.g. 'Mon, Tue' or 'Day 1'
    is_archived = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    user = relationship("User", back_populates="routines")
    exercises = relationship("RoutineExercise", back_populates="routine", cascade="all, delete-orphan", order_by="RoutineExercise.position")


class RoutineExercise(Base):
    __tablename__ = 'routine_exercises'

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    routine_id = Column(UUID(as_uuid=True), ForeignKey('routine_headers.id', ondelete='CASCADE'), nullable=False)
    title = Column(Text, nullable=False)
    sets = Column(Integer, default=1)
    min_reps = Column(Integer, default=1)
    max_reps = Column(Integer, default=1)
    position = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)

    # Relationship
    routine = relationship("RoutineHeader", back_populates="exercises")
