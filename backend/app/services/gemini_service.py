"""
Google Gemini AI Service
Handles direct integration with Google's Generative AI API
"""
from typing import Optional, Dict, Any
import asyncio
import google.generativeai as genai
from ..core.config import settings


class GeminiService:
    """Service for interacting with Google Gemini AI"""
    
    def __init__(self):
        """Initialize Gemini API with API key"""
        genai.configure(api_key=settings.GEMINI_API_KEY)
        
        # Configure the model
        self.generation_config = {
            "temperature": 0.7,
            "top_p": 0.95,
            "top_k": 40,
            "max_output_tokens": 2048,
        }
        
        # Safety settings
        self.safety_settings = [
            {
                "category": "HARM_CATEGORY_HARASSMENT",
                "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            },
            {
                "category": "HARM_CATEGORY_HATE_SPEECH",
                "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            },
            {
                "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
                "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            },
            {
                "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
                "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            },
        ]
        
        # Initialize model
        # Using gemini-2.0-flash-exp (latest available model)
        self.model = genai.GenerativeModel(
            model_name="gemini-2.0-flash-exp",
            generation_config=self.generation_config,
            safety_settings=self.safety_settings
        )
    
    async def generate_response(
        self,
        user_message: str,
        system_prompt: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Generate AI response using Gemini

        Args:
            user_message: User's input message
            system_prompt: Optional system instructions for context

        Returns:
            Dict with response text, model version, and token usage
        """
        try:
            # Build the prompt
            if system_prompt:
                prompt = f"{system_prompt}\n\nUser: {user_message}\n\nAssistant:"
            else:
                prompt = user_message

            # Generate response (run in executor to avoid blocking)
            response = await asyncio.to_thread(
                self.model.generate_content,
                prompt
            )

            # Extract response text
            response_text = response.text if response.text else ""

            # Get token usage (if available)
            tokens_used = None
            if hasattr(response, 'usage_metadata'):
                tokens_used = (
                    response.usage_metadata.prompt_token_count +
                    response.usage_metadata.candidates_token_count
                )

            # Check for safety flags
            safety_flag = False
            if hasattr(response, 'prompt_feedback'):
                safety_flag = response.prompt_feedback.block_reason is not None

            return {
                "response_text": response_text,
                "model_version": "gemini-2.0-flash-exp",
                "tokens_used": tokens_used,
                "safety_flag": safety_flag
            }

        except Exception as e:
            raise ValueError(f"Gemini API error: {str(e)}")
    
    def get_default_system_prompt(self) -> str:
        """Get the default system prompt for fitness coaching"""
        return """You are an expert fitness and nutrition coach AI assistant for Pump Fiction, 
a comprehensive fitness tracking app. Your role is to provide helpful, accurate, and safe 
advice on workout routines, exercise techniques, nutrition, and general fitness topics.

Guidelines:
- Provide clear, actionable advice based on exercise science
- Always prioritize safety and proper form
- Encourage progressive overload and consistency
- Be supportive and motivating
- If asked about medical conditions or injuries, recommend consulting a healthcare professional
- Base recommendations on the user's experience level when known
- Keep responses concise but informative

Remember: You're a fitness coach, not a medical doctor. Always encourage users to consult 
professionals for medical concerns."""
