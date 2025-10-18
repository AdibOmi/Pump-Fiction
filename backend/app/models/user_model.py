from sqlalchemy import Column, Integer, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from ..core.database import Base
import uuid


class User(Base):
    __tablename__ = 'users'
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)

    # Relationships
    posts = relationship("Post", back_populates="user")
    profile = relationship("UserProfile", back_populates="user", uselist=False)
    trackers = relationship("Tracker", back_populates="user")
    routines = relationship("RoutineHeader", back_populates="user")
