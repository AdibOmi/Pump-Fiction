"""
AI Chat Repository
Data access layer for chat sessions and messages
"""
from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, desc
from sqlalchemy.orm import selectinload
from datetime import datetime
from ..models.ai_chat_model import AIChatSession, AIChatMessage, ChatRoleEnum
import uuid


class AIChatRepository:
    """Repository for AI chat operations"""
    
    def __init__(self, db: AsyncSession):
        self.db = db
    
    # ========== Session Operations ==========
    
    async def create_session(
        self, 
        user_id: str, 
        title: str = "New Chat"
    ) -> AIChatSession:
        """Create a new chat session"""
        session = AIChatSession(
            id=uuid.uuid4(),
            user_id=uuid.UUID(user_id),
            title=title,
            context_snapshot={},
            last_message_at=datetime.utcnow()
        )
        self.db.add(session)
        await self.db.commit()
        await self.db.refresh(session)
        return session
    
    async def get_session_by_id(
        self, 
        session_id: str, 
        user_id: str,
        include_messages: bool = False
    ) -> Optional[AIChatSession]:
        """Get a session by ID (with optional messages)"""
        query = select(AIChatSession).where(
            and_(
                AIChatSession.id == uuid.UUID(session_id),
                AIChatSession.user_id == uuid.UUID(user_id)
            )
        )
        
        if include_messages:
            query = query.options(selectinload(AIChatSession.messages))
        
        result = await self.db.execute(query)
        return result.scalar_one_or_none()
    
    async def get_user_sessions(
        self, 
        user_id: str, 
        is_archived: bool = False,
        limit: int = 50
    ) -> List[AIChatSession]:
        """Get all sessions for a user"""
        query = select(AIChatSession).where(
            and_(
                AIChatSession.user_id == uuid.UUID(user_id),
                AIChatSession.is_archived == is_archived
            )
        ).order_by(desc(AIChatSession.last_message_at)).limit(limit)
        
        result = await self.db.execute(query)
        return result.scalars().all()
    
    async def update_session_last_message(
        self, 
        session_id: str,
        title: Optional[str] = None
    ) -> None:
        """Update session's last_message_at timestamp and optionally title"""
        session = await self.db.get(AIChatSession, uuid.UUID(session_id))
        if session:
            session.last_message_at = datetime.utcnow()
            if title:
                session.title = title
            await self.db.commit()
    
    async def archive_session(self, session_id: str, user_id: str) -> bool:
        """Archive a session"""
        session = await self.get_session_by_id(session_id, user_id)
        if session:
            session.is_archived = True
            await self.db.commit()
            return True
        return False
    
    async def delete_session(self, session_id: str, user_id: str) -> bool:
        """Delete a session and all its messages"""
        session = await self.get_session_by_id(session_id, user_id)
        if session:
            await self.db.delete(session)
            await self.db.commit()
            return True
        return False
    
    # ========== Message Operations ==========
    
    async def create_message(
        self,
        session_id: str,
        role: ChatRoleEnum,
        content: str,
        tokens_used: Optional[int] = None,
        model_version: Optional[str] = None,
        safety_flag: bool = False,
        disclaimer_shown: bool = False
    ) -> AIChatMessage:
        """Create a new message in a session"""
        message = AIChatMessage(
            id=uuid.uuid4(),
            session_id=uuid.UUID(session_id),
            role=role,
            content=content,
            tokens_used=tokens_used,
            model_version=model_version,
            safety_flag=safety_flag,
            disclaimer_shown=disclaimer_shown,
            citations=[]
        )
        self.db.add(message)
        await self.db.commit()
        await self.db.refresh(message)
        return message
    
    async def get_session_messages(
        self, 
        session_id: str,
        limit: Optional[int] = None
    ) -> List[AIChatMessage]:
        """Get all messages for a session"""
        query = select(AIChatMessage).where(
            AIChatMessage.session_id == uuid.UUID(session_id)
        ).order_by(AIChatMessage.created_at)
        
        if limit:
            query = query.limit(limit)
        
        result = await self.db.execute(query)
        return result.scalars().all()
