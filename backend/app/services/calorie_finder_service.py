"""
Calorie Finder Service
Uses Google Gemini 2.5 Flash to estimate calories from food images
"""
from typing import Dict, Any
import google.generativeai as genai
from PIL import Image
import io
from ..core.config import settings


class CalorieFinderService:
    """Service for estimating calories from food images using Gemini AI"""

    def __init__(self):
        """Initialize Gemini API with API key"""
        genai.configure(api_key=settings.GEMINI_API_KEY)

        # Configure the model for precise calorie estimation
        self.generation_config = {
            "temperature": 0.1,  # Low temperature for more consistent results
            "top_p": 0.95,
            "top_k": 40,
            "max_output_tokens": 256,  # We only need a number
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

        # Initialize model with Gemini 2.0 Flash
        self.model = genai.GenerativeModel(
            model_name="gemini-2.0-flash-exp",
            generation_config=self.generation_config,
            safety_settings=self.safety_settings
        )

    async def estimate_calories(
        self,
        image_data: bytes,
        serving_size: str
    ) -> Dict[str, Any]:
        """
        Estimate calories from a food image

        Args:
            image_data: Image file bytes
            serving_size: Serving size description (e.g., "2 pieces", "150 grams")

        Returns:
            Dict with calorie estimate and metadata
        """
        try:
            # Convert image bytes to PIL Image
            image = Image.open(io.BytesIO(image_data))

            # Create the prompt for calorie estimation
            prompt = f"""Analyze this food image and estimate the total calories for {serving_size}.

IMPORTANT INSTRUCTIONS:
- Only return the numeric calorie value (integer or decimal)
- Do NOT include any text, explanations, units, or additional information
- If you cannot identify the food or estimate calories, return "0"

Example responses:
- For a valid estimation: 250
- For another valid estimation: 187.5
- If uncertain or cannot identify: 0

Now estimate calories for {serving_size}:"""

            # Generate response with image
            response = self.model.generate_content([prompt, image])

            # Extract and parse the calorie value
            response_text = response.text.strip() if response.text else "0"

            # Clean the response to extract only the number
            calorie_value = self._parse_calorie_response(response_text)

            return {
                "calories": calorie_value,
                "serving_size": serving_size,
                "model_version": "gemini-2.0-flash-exp"
            }

        except Exception as e:
            raise ValueError(f"Failed to estimate calories: {str(e)}")

    def _parse_calorie_response(self, response_text: str) -> float:
        """
        Parse the calorie value from Gemini's response

        Args:
            response_text: Raw response from Gemini

        Returns:
            Calorie value as float
        """
        try:
            # Remove any non-numeric characters except decimal point and minus sign
            cleaned = ''.join(c for c in response_text if c.isdigit() or c in ['.', '-'])

            # Convert to float
            if cleaned:
                calorie_value = float(cleaned)
                # Ensure non-negative
                return max(0.0, calorie_value)
            else:
                return 0.0

        except (ValueError, TypeError):
            # If parsing fails, return 0
            return 0.0
