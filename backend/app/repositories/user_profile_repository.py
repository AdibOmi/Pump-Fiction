"""
User Profile Repository
Data access layer for user profiles
"""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from ..models.user_profile_model import UserProfile
from ..models.user_model import User
from typing import Optional, Dict, Any
from uuid import UUID


class UserProfileRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_by_user_id(self, user_id: UUID | str) -> Optional[UserProfile]:
        """Get user profile by user ID"""
        if isinstance(user_id, str):
            user_id = UUID(user_id)
        query = select(UserProfile).where(UserProfile.user_id == user_id)
        result = await self.db.execute(query)
        return result.scalars().first()

    async def get_by_user_id_with_email(self, user_id: UUID | str) -> Optional[tuple]:
        """Get user profile with user email"""
        if isinstance(user_id, str):
            user_id = UUID(user_id)
        query = (
            select(UserProfile, User.email)
            .join(User, UserProfile.user_id == User.id)
            .where(UserProfile.user_id == user_id)
        )
        result = await self.db.execute(query)
        row = result.first()
        return row if row else None

    async def create(self, user_id: UUID | str, profile_data: Dict[str, Any]) -> UserProfile:
        """Create a new user profile"""
        if isinstance(user_id, str):
            user_id = UUID(user_id)
        profile = UserProfile(user_id=user_id, **profile_data)
        self.db.add(profile)
        await self.db.commit()
        await self.db.refresh(profile)
        return profile

    async def update(self, user_id: UUID | str, profile_data: Dict[str, Any]) -> Optional[UserProfile]:
        """Update existing user profile"""
        profile = await self.get_by_user_id(user_id)
        if not profile:
            return None

        # Update only provided fields
        for key, value in profile_data.items():
            if value is not None:  # Only update non-None values
                setattr(profile, key, value)

        await self.db.commit()
        await self.db.refresh(profile)
        return profile

    async def get_or_create(self, user_id: UUID | str, profile_data: Dict[str, Any] = None) -> UserProfile:
        """Get existing profile or create new one"""
        profile = await self.get_by_user_id(user_id)
        if profile:
            return profile

        return await self.create(user_id, profile_data or {})

    async def delete(self, user_id: UUID | str) -> bool:
        """Delete user profile"""
        profile = await self.get_by_user_id(user_id)
        if not profile:
            return False

        await self.db.delete(profile)
        await self.db.commit()
        return True
