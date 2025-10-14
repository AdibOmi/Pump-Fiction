"""
AI Chat Service
Business logic for AI chatbot conversations
"""
from typing import Dict, Any, List, Tuple
from ..repositories.ai_chat_repository import AIChatRepository
from ..services.gemini_service import GeminiService
from ..models.ai_chat_model import ChatRoleEnum, AIChatSession, AIChatMessage


class AIChatService:
    """Service for AI chat business logic"""
    
    def __init__(self, repository: AIChatRepository):
        self.repository = repository
        self.gemini_service = GeminiService()
    
    async def create_session(self, user_id: str, title: str = "New Chat") -> AIChatSession:
        """Create a new chat session"""
        return await self.repository.create_session(user_id, title)
    
    async def get_user_sessions(
        self, 
        user_id: str, 
        is_archived: bool = False
    ) -> List[AIChatSession]:
        """Get all sessions for a user"""
        return await self.repository.get_user_sessions(user_id, is_archived)
    
    async def get_session_with_messages(
        self, 
        session_id: str, 
        user_id: str
    ) -> AIChatSession:
        """Get a session with all its messages"""
        session = await self.repository.get_session_by_id(
            session_id, 
            user_id, 
            include_messages=True
        )
        if not session:
            raise ValueError("Session not found")
        return session
    
    async def archive_session(self, session_id: str, user_id: str) -> bool:
        """Archive a session"""
        success = await self.repository.archive_session(session_id, user_id)
        if not success:
            raise ValueError("Session not found")
        return True
    
    async def delete_session(self, session_id: str, user_id: str) -> bool:
        """Delete a session"""
        success = await self.repository.delete_session(session_id, user_id)
        if not success:
            raise ValueError("Session not found")
        return True
    
    async def send_message(
        self, 
        session_id: str, 
        user_id: str, 
        content: str
    ) -> Tuple[AIChatMessage, AIChatMessage]:
        """
        Send a message and get AI response
        
        Returns:
            Tuple of (user_message, assistant_message)
        """
        # Verify session exists and belongs to user
        session = await self.repository.get_session_by_id(session_id, user_id)
        if not session:
            raise ValueError("Session not found")
        
        # Create user message
        user_message = await self.repository.create_message(
            session_id=session_id,
            role=ChatRoleEnum.USER,
            content=content
        )
        
        # Generate AI response using Gemini
        try:
            system_prompt = self.gemini_service.get_default_system_prompt()
            ai_response = await self.gemini_service.generate_response(
                user_message=content,
                system_prompt=system_prompt
            )
            
            # Check if medical disclaimer should be shown
            disclaimer_keywords = [
                "injury", "pain", "hurt", "medical", "doctor", "physician", 
                "surgery", "condition", "disease", "medication"
            ]
            needs_disclaimer = any(
                keyword in content.lower() 
                for keyword in disclaimer_keywords
            )
            
            # Add disclaimer to response if needed
            response_content = ai_response["response_text"]
            if needs_disclaimer:
                response_content = (
                    f"{response_content}\n\n"
                    "⚠️ **Medical Disclaimer:** This advice is for informational purposes only. "
                    "Please consult with a healthcare professional for medical concerns or injuries."
                )
            
            # Create assistant message
            assistant_message = await self.repository.create_message(
                session_id=session_id,
                role=ChatRoleEnum.ASSISTANT,
                content=response_content,
                tokens_used=ai_response.get("tokens_used"),
                model_version=ai_response.get("model_version"),
                safety_flag=ai_response.get("safety_flag", False),
                disclaimer_shown=needs_disclaimer
            )
            
            # Auto-generate title from first message if still "New Chat"
            if session.title == "New Chat":
                title = self._generate_session_title(content)
                await self.repository.update_session_last_message(
                    session_id, 
                    title=title
                )
            else:
                await self.repository.update_session_last_message(session_id)
            
            return user_message, assistant_message
        
        except Exception as e:
            # If AI generation fails, still update session timestamp
            await self.repository.update_session_last_message(session_id)
            raise ValueError(f"Failed to generate AI response: {str(e)}")
    
    def _generate_session_title(self, first_message: str) -> str:
        """Generate a short title from the first message"""
        # Take first 50 characters and add ellipsis if needed
        title = first_message.strip()[:50]
        if len(first_message) > 50:
            title += "..."
        return title
