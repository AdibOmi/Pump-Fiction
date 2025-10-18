from fastapi import APIRouter, Depends, HTTPException, status
from ..schemas.user_schema import UserCreate, UserRead
from ..repositories.user_repository import UserRepository
from ..services.user_service import UserService
from ..core.database import get_db
from ..core.dependencies import get_current_user, require_admin, require_trainer, require_seller
from sqlalchemy.ext.asyncio import AsyncSession

router = APIRouter(prefix='/users', tags=['users'])


async def _get_user_service(db: AsyncSession = Depends(get_db)):
    repo = UserRepository(db)
    return UserService(repo)





# ========== Protected Endpoints Examples ==========

# NOTE: /users/me/profile is handled by user_profile_controller.py
# This provides the full profile with fitness data

@router.get('/trainers')
async def list_trainers(current_user: dict = Depends(get_current_user)):
    """
    List all trainers (any authenticated user can view)
    - Requires authentication
    """
    # TODO: Implement actual trainer listing from database
    return {
        "message": "List of trainers",
        "requested_by": current_user["email"]
    }


@router.get('/trainer/dashboard')
async def trainer_dashboard(trainer: dict = Depends(require_trainer)):
    """
    Trainer dashboard - only accessible by trainers and admins
    - Requires trainer or admin role
    """
    return {
        "message": "Welcome to trainer dashboard",
        "trainer": trainer["full_name"],
        "role": trainer["role"]
    }


@router.get('/seller/dashboard')
async def seller_dashboard(seller: dict = Depends(require_seller)):
    """
    Seller dashboard - only accessible by sellers and admins
    - Requires seller or admin role
    """
    return {
        "message": "Welcome to seller dashboard",
        "seller": seller["full_name"],
        "role": seller["role"]
    }


@router.get('/admin/users')
async def list_all_users(admin: dict = Depends(require_admin)):
    """
    List all users (admin only)
    - Requires admin role
    """
    # TODO: Implement actual user listing from Supabase
    return {
        "message": "List of all users",
        "admin": admin["email"]
    }
