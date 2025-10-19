from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Text, Date, Float
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
from ..core.database import Base
import uuid


class WorkoutLog(Base):
    __tablename__ = 'workout_logs'

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    workout_date = Column(Date, nullable=False)
    routine_title = Column(Text, nullable=True)
    day_label = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    user = relationship("User", back_populates="workout_logs")
    exercises = relationship(
        "WorkoutExercise",
        back_populates="workout_log",
        cascade="all, delete-orphan",
        order_by="WorkoutExercise.position"
    )


class WorkoutExercise(Base):
    __tablename__ = 'workout_exercises'

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    workout_log_id = Column(UUID(as_uuid=True), ForeignKey('workout_logs.id', ondelete='CASCADE'), nullable=False)
    exercise_name = Column(Text, nullable=False)
    position = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)

    # Relationships
    workout_log = relationship("WorkoutLog", back_populates="exercises")
    sets = relationship(
        "WorkoutSet",
        back_populates="exercise",
        cascade="all, delete-orphan",
        order_by="WorkoutSet.position"
    )


class WorkoutSet(Base):
    __tablename__ = 'workout_sets'

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    workout_exercise_id = Column(UUID(as_uuid=True), ForeignKey('workout_exercises.id', ondelete='CASCADE'), nullable=False)
    weight = Column(Float, nullable=False)
    reps = Column(Integer, nullable=False)
    position = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)

    # Relationship
    exercise = relationship("WorkoutExercise", back_populates="sets")
