from pydantic import BaseModel, ConfigDict
from typing import Optional, List
from enum import Enum
from datetime import datetime


class ChatRole(str, Enum):
    """Message role in conversation"""
    USER = "user"
    ASSISTANT = "assistant"
    SYSTEM = "system"


# ========== Request Schemas ==========

class CreateSessionRequest(BaseModel):
    """Request to create a new AI chat session"""
    title: Optional[str] = "New Chat"


class SendMessageRequest(BaseModel):
    """Request to send a message in a chat session"""
    content: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "content": "What's the best way to improve my bench press?"
            }
        }


# ========== Response Schemas ==========

class AIChatMessageResponse(BaseModel):
    """Individual chat message"""
    model_config = ConfigDict(from_attributes=True, protected_namespaces=())

    id: str
    session_id: str
    role: ChatRole
    content: str
    tokens_used: Optional[int] = None
    model_version: Optional[str] = None
    safety_flag: bool = False
    disclaimer_shown: bool = False
    created_at: datetime


class AIChatSessionResponse(BaseModel):
    """AI chat session with metadata"""
    model_config = ConfigDict(from_attributes=True)
    
    id: str
    user_id: str
    title: str
    last_message_at: datetime
    is_archived: bool
    created_at: datetime
    updated_at: datetime


class AIChatSessionDetailResponse(BaseModel):
    """AI chat session with full message history"""
    model_config = ConfigDict(from_attributes=True)
    
    id: str
    user_id: str
    title: str
    last_message_at: datetime
    is_archived: bool
    created_at: datetime
    updated_at: datetime
    messages: List[AIChatMessageResponse]


class SendMessageResponse(BaseModel):
    """Response after sending a message"""
    user_message: AIChatMessageResponse
    assistant_message: AIChatMessageResponse
