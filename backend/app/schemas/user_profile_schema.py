"""
User Profile Schemas
Pydantic models for user profile request/response validation
"""
from pydantic import BaseModel, ConfigDict, Field
from typing import Optional
from ..models.user_profile_model import (
    GenderEnum,
    FitnessGoalEnum,
    ExperienceLevelEnum,
    NutritionGoalEnum
)


class UserProfileBase(BaseModel):
    """Base schema for user profile"""
    full_name: Optional[str] = None
    phone_number: Optional[str] = None
    gender: Optional[GenderEnum] = None
    weight_kg: Optional[float] = Field(None, gt=0, description="Weight in kilograms")
    height_cm: Optional[float] = Field(None, gt=0, description="Height in centimeters")
    fitness_goal: Optional[FitnessGoalEnum] = None
    experience_level: Optional[ExperienceLevelEnum] = None
    training_frequency: Optional[int] = Field(None, ge=1, le=7, description="Workouts per week (1-7)")
    nutrition_goal: Optional[NutritionGoalEnum] = None


class UserProfileCreate(UserProfileBase):
    """Schema for creating a user profile"""
    pass


class UserProfileUpdate(UserProfileBase):
    """Schema for updating a user profile - all fields optional"""
    pass


class UserProfileResponse(UserProfileBase):
    """Schema for user profile response"""
    model_config = ConfigDict(from_attributes=True)

    id: str
    user_id: str
    email: str  # Include email from user for convenience


class UserProfileWithEmail(UserProfileResponse):
    """Extended profile response with user email"""
    pass
