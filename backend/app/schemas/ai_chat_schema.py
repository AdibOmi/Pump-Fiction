from pydantic import BaseModel, ConfigDict, field_serializer, Field
from typing import Optional, List, Union
from enum import Enum
from datetime import datetime
from uuid import UUID


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

    id: Union[str, UUID]
    session_id: Union[str, UUID]
    role: ChatRole
    content: str
    tokens_used: Optional[int] = None
    model_version: Optional[str] = None
    safety_flag: bool = False
    disclaimer_shown: bool = False
    created_at: datetime

    @field_serializer('id', 'session_id')
    def serialize_uuid(self, value, _info):
        """Convert UUID to string"""
        return str(value) if value else None


class AIChatSessionResponse(BaseModel):
    """AI chat session with metadata"""
    model_config = ConfigDict(from_attributes=True)

    id: Union[str, UUID]
    user_id: Union[str, UUID]
    title: str
    last_message_at: datetime
    is_archived: bool
    created_at: datetime
    updated_at: datetime

    @field_serializer('id', 'user_id')
    def serialize_uuid(self, value, _info):
        """Convert UUID to string"""
        return str(value) if value else None


class AIChatSessionDetailResponse(BaseModel):
    """AI chat session with full message history"""
    model_config = ConfigDict(from_attributes=True)

    id: Union[str, UUID]
    user_id: Union[str, UUID]
    title: str
    last_message_at: datetime
    is_archived: bool
    created_at: datetime
    updated_at: datetime
    messages: List[AIChatMessageResponse]

    @field_serializer('id', 'user_id')
    def serialize_uuid(self, value, _info):
        """Convert UUID to string"""
        return str(value) if value else None


class SendMessageResponse(BaseModel):
    """Response after sending a message"""
    user_message: AIChatMessageResponse
    assistant_message: AIChatMessageResponse
