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


# ========== DEPRECATED - Use /auth/signup and /auth/login instead ==========
# These endpoints are kept for backward compatibility but should not be used

@router.post('/register', response_model=UserRead, deprecated=True)
async def register(user_in: UserCreate, service: UserService = Depends(_get_user_service)):
    """DEPRECATED: Use /auth/signup instead"""
    existing = await service.repository.get_by_email(user_in.email)
    if existing:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Email already registered')
    user = await service.register(user_in)
    return user


@router.post('/login', deprecated=True)
async def login(user_in: UserCreate, service: UserService = Depends(_get_user_service)):
    """DEPRECATED: Use /auth/login instead"""
    token = await service.authenticate(user_in.email, user_in.password)
    if not token:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail='Invalid credentials')
    return token


# ========== Protected Endpoints Examples ==========

@router.get('/me/profile')
async def get_my_profile(current_user: dict = Depends(get_current_user)):
    """
    Get current user's profile
    - Requires authentication
    """
    return {
        "id": current_user["id"],
        "email": current_user["email"],
        "full_name": current_user["full_name"],
        "role": current_user["role"]
    }


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
