"""
User Profile Controller
HTTP endpoints for user profile management
"""
from typing import Any, Dict, Optional

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from ..schemas.user_profile_schema import (
    UserProfileResponse,
    UserProfileCreate,
    UserProfileUpdate
)
from ..services.user_profile_service import UserProfileService
from ..repositories.user_profile_repository import UserProfileRepository
from ..core.database import get_db
from ..core.dependencies import get_current_user

router = APIRouter(prefix='/users', tags=['profile'])


def _ensure_profile_identity(
    profile: Optional[Dict[str, Any]],
    current_user: dict,
    user_id: str,
) -> Optional[Dict[str, Any]]:
    """Guarantee contract fields (user_id/email/name/phone) are present."""
    if profile is None:
        return None

    profile['user_id'] = profile.get('user_id') or str(user_id)
    profile['email'] = profile.get('email') or current_user.get('email')

    if not profile.get('full_name'):
        profile['full_name'] = current_user.get('full_name')
    if not profile.get('phone_number'):
        profile['phone_number'] = current_user.get('phone_number')

    return profile


@router.get('/me/profile', response_model=UserProfileResponse)
async def get_my_profile(
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Get current user's profile
    Creates empty profile if doesn't exist
    """
    user_id = current_user["id"]
    repository = UserProfileRepository(db)
    service = UserProfileService(repository)

    profile = await service.get_profile(user_id)

    if not profile:
        # Create empty profile if doesn't exist
        profile = await service.create_profile(user_id, {})

    profile = _ensure_profile_identity(profile, current_user, user_id)

    if not profile:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to load profile for current user"
        )

    return profile


async def _update_profile_impl(
    profile_data: UserProfileUpdate,
    current_user: dict,
    db: AsyncSession
) -> dict:
    """Shared implementation for PUT and PATCH"""
    user_id = current_user["id"]
    repository = UserProfileRepository(db)
    service = UserProfileService(repository)

    # Convert Pydantic model to dict, excluding None values
    update_data = profile_data.model_dump(exclude_none=True, exclude_unset=True)

    profile = await service.update_profile(user_id, update_data)

    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found"
        )

    return _ensure_profile_identity(profile, current_user, user_id)


@router.put('/me/profile', response_model=UserProfileResponse)
async def update_my_profile_put(
    profile_data: UserProfileUpdate,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Update current user's profile (PUT)
    Creates profile if doesn't exist
    """
    return await _update_profile_impl(profile_data, current_user, db)


@router.patch('/me/profile', response_model=UserProfileResponse)
async def update_my_profile_patch(
    profile_data: UserProfileUpdate,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Update current user's profile (PATCH)
    Creates profile if doesn't exist
    """
    return await _update_profile_impl(profile_data, current_user, db)


@router.post('/me/profile', response_model=UserProfileResponse, status_code=status.HTTP_201_CREATED)
async def create_my_profile(
    profile_data: UserProfileCreate,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Create current user's profile
    Only needed if profile doesn't exist
    """
    user_id = current_user["id"]
    repository = UserProfileRepository(db)
    service = UserProfileService(repository)

    # Check if profile already exists
    existing = await service.get_profile(user_id)
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Profile already exists. Use PUT /profile/me to update"
        )

    # Convert Pydantic model to dict, excluding None values
    create_data = profile_data.model_dump(exclude_none=True)

    profile = await service.create_profile(user_id, create_data)
    return _ensure_profile_identity(profile, current_user, user_id)


@router.delete('/me', status_code=status.HTTP_204_NO_CONTENT)
async def delete_my_profile(
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Delete current user's profile
    """
    user_id = current_user["id"]
    repository = UserProfileRepository(db)
    service = UserProfileService(repository)

    success = await service.delete_profile(user_id)

    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found"
        )
