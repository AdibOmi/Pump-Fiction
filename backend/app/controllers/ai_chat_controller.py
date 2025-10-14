"""
AI Chat Controller
REST API endpoints for AI chatbot
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from ..schemas.ai_chat_schema import (
    CreateSessionRequest,
    SendMessageRequest,
    AIChatSessionResponse,
    AIChatSessionDetailResponse,
    SendMessageResponse,
    AIChatMessageResponse
)
from ..services.ai_chat_service import AIChatService
from ..repositories.ai_chat_repository import AIChatRepository
from ..core.database import get_db
from ..core.dependencies import get_current_user


router = APIRouter(prefix='/ai-chat', tags=['AI Chat'])


def _get_ai_chat_service(db: AsyncSession = Depends(get_db)) -> AIChatService:
    """Dependency to get AI chat service"""
    repository = AIChatRepository(db)
    return AIChatService(repository)


@router.post('/sessions', response_model=AIChatSessionResponse, status_code=status.HTTP_201_CREATED)
async def create_session(
    request: CreateSessionRequest,
    current_user: dict = Depends(get_current_user),
    service: AIChatService = Depends(_get_ai_chat_service)
):
    """
    Create a new AI chat session
    - Starts a new conversation with the AI assistant
    """
    try:
        session = await service.create_session(
            user_id=current_user["id"],
            title=request.title or "New Chat"
        )
        return AIChatSessionResponse.model_validate(session)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )


@router.get('/sessions', response_model=List[AIChatSessionResponse])
async def get_sessions(
    is_archived: bool = False,
    current_user: dict = Depends(get_current_user),
    service: AIChatService = Depends(_get_ai_chat_service)
):
    """
    Get all chat sessions for current user
    - Returns list of sessions ordered by most recent
    - Filter by archived status
    """
    try:
        sessions = await service.get_user_sessions(
            user_id=current_user["id"],
            is_archived=is_archived
        )
        return [AIChatSessionResponse.model_validate(s) for s in sessions]
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )


@router.get('/sessions/{session_id}', response_model=AIChatSessionDetailResponse)
async def get_session(
    session_id: str,
    current_user: dict = Depends(get_current_user),
    service: AIChatService = Depends(_get_ai_chat_service)
):
    """
    Get a specific chat session with all messages
    - Returns full conversation history
    """
    try:
        session = await service.get_session_with_messages(
            session_id=session_id,
            user_id=current_user["id"]
        )
        return AIChatSessionDetailResponse(
            id=str(session.id),
            user_id=str(session.user_id),
            title=session.title,
            last_message_at=session.last_message_at,
            is_archived=session.is_archived,
            created_at=session.created_at,
            updated_at=session.updated_at,
            messages=[AIChatMessageResponse.model_validate(m) for m in session.messages]
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )


@router.post('/sessions/{session_id}/messages', response_model=SendMessageResponse, status_code=status.HTTP_201_CREATED)
async def send_message(
    session_id: str,
    request: SendMessageRequest,
    current_user: dict = Depends(get_current_user),
    service: AIChatService = Depends(_get_ai_chat_service)
):
    """
    Send a message to the AI assistant
    - User sends a question/prompt
    - AI responds with helpful fitness advice
    - Returns both user and assistant messages
    """
    try:
        user_msg, assistant_msg = await service.send_message(
            session_id=session_id,
            user_id=current_user["id"],
            content=request.content
        )
        
        return SendMessageResponse(
            user_message=AIChatMessageResponse.model_validate(user_msg),
            assistant_message=AIChatMessageResponse.model_validate(assistant_msg)
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to process message: {str(e)}"
        )


@router.delete('/sessions/{session_id}', status_code=status.HTTP_204_NO_CONTENT)
async def delete_session(
    session_id: str,
    current_user: dict = Depends(get_current_user),
    service: AIChatService = Depends(_get_ai_chat_service)
):
    """
    Delete a chat session and all its messages
    - Permanently removes the conversation
    """
    try:
        await service.delete_session(
            session_id=session_id,
            user_id=current_user["id"]
        )
        return None
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )


@router.post('/sessions/{session_id}/archive', status_code=status.HTTP_200_OK)
async def archive_session(
    session_id: str,
    current_user: dict = Depends(get_current_user),
    service: AIChatService = Depends(_get_ai_chat_service)
):
    """
    Archive a chat session
    - Moves session to archived list
    """
    try:
        await service.archive_session(
            session_id=session_id,
            user_id=current_user["id"]
        )
        return {"message": "Session archived successfully"}
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
