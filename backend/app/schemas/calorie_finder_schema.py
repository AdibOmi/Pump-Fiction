"""
Calorie Finder Schema
Request/Response models for calorie estimation from food images
"""
from pydantic import BaseModel, Field, ConfigDict
from typing import Optional


# ========== Request Schemas ==========

class CalorieFinderRequest(BaseModel):
    """Request to estimate calories from food image"""
    serving_size: str = Field(
        ...,
        description="Serving size with unit (e.g., '2 pieces', '150 grams', '1 cup')"
    )

    class Config:
        json_schema_extra = {
            "example": {
                "serving_size": "2 pieces"
            }
        }


# ========== Response Schemas ==========

class CalorieFinderResponse(BaseModel):
    """Response with estimated calories"""
    model_config = ConfigDict(
        protected_namespaces=(),
        json_schema_extra={
            "example": {
                "calories": 210.0,
                "serving_size": "2 pieces",
                "model_version": "gemini-2.0-flash-exp"
            }
        }
    )

    calories: float = Field(
        ...,
        description="Estimated calorie count for the given serving size"
    )
    serving_size: str = Field(
        ...,
        description="The serving size used for estimation"
    )
    model_version: Optional[str] = Field(
        default="gemini-2.0-flash-exp",
        description="The AI model version used"
    )
