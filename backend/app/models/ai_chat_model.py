from sqlalchemy import Column, String, Boolean, Integer, Text, DateTime, ForeignKey, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
import enum
from ..core.database import Base


class ChatRoleEnum(str, enum.Enum):
    """Message role in conversation"""
    USER = "user"
    ASSISTANT = "assistant"
    SYSTEM = "system"


class AIChatSession(Base):
    """AI chatbot conversation session"""
    __tablename__ = "ai_chat_sessions"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    title = Column(String(255), nullable=False)
    context_snapshot = Column(JSONB, default={})
    last_message_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    is_archived = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Relationship
    messages = relationship("AIChatMessage", back_populates="session", cascade="all, delete-orphan")
    
    def __repr__(self):
        return f"<AIChatSession(id={self.id}, user_id={self.user_id}, title='{self.title}')>"


class AIChatMessage(Base):
    """Individual message in AI chatbot conversation"""
    __tablename__ = "ai_chat_messages"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    session_id = Column(UUID(as_uuid=True), ForeignKey("ai_chat_sessions.id", ondelete="CASCADE"), nullable=False, index=True)
    role = Column(SQLEnum(ChatRoleEnum), nullable=False)
    content = Column(Text, nullable=False)
    citations = Column(JSONB, default=[])
    tokens_used = Column(Integer, nullable=True)
    model_version = Column(String(50), nullable=True)
    safety_flag = Column(Boolean, default=False, nullable=False)
    disclaimer_shown = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    
    # Relationship
    session = relationship("AIChatSession", back_populates="messages")
    
    def __repr__(self):
        return f"<AIChatMessage(id={self.id}, role={self.role}, session_id={self.session_id})>"
