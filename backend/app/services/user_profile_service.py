"""
User Profile Service
Business logic for user profiles
"""
from typing import Optional, Dict, Any
from uuid import UUID
from ..repositories.user_profile_repository import UserProfileRepository
from ..schemas.user_profile_schema import UserProfileResponse
from ..models.user_model import User


class UserProfileService:
    def __init__(self, repository: UserProfileRepository):
        self.repository = repository

    async def get_profile(self, user_id: UUID | str) -> Optional[Dict[str, Any]]:
        """
        Get user profile by user ID with email
        Returns profile data as dict or None if not found
        """
        result = await self.repository.get_by_user_id_with_email(user_id)
        if not result:
            return None

        profile, email = result
        # Convert to dict and add email
        profile_dict = {
            "id": str(profile.id),
            "user_id": str(profile.user_id),
            "email": email,
            "full_name": profile.full_name,
            "phone_number": profile.phone_number,
            "gender": profile.gender,
            "weight_kg": profile.weight_kg,
            "height_cm": profile.height_cm,
            "fitness_goal": profile.fitness_goal,
            "experience_level": profile.experience_level,
            "training_frequency": profile.training_frequency,
            "nutrition_goal": profile.nutrition_goal,
        }
        return profile_dict

    async def create_profile(self, user_id: UUID | str, profile_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new user profile"""
        profile = await self.repository.create(user_id, profile_data)
        # Fetch with email for response
        return await self.get_profile(user_id)

    async def update_profile(self, user_id: UUID | str, profile_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Update user profile, create if doesn't exist"""
        # Check if profile exists
        existing_profile = await self.repository.get_by_user_id(user_id)

        if existing_profile:
            # Update existing profile
            await self.repository.update(user_id, profile_data)
        else:
            # Create new profile if doesn't exist
            await self.repository.create(user_id, profile_data)

        # Return updated profile with email
        return await self.get_profile(user_id)

    async def delete_profile(self, user_id: UUID | str) -> bool:
        """Delete user profile"""
        return await self.repository.delete(user_id)
