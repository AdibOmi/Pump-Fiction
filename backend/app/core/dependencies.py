from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import Optional, List
from ..services.auth_service import AuthService
from ..schemas.auth_schema import UserRole


security = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security)
) -> dict:
    """
    Dependency to get current authenticated user from JWT token
    Raises HTTPException if token is invalid
    """
    token = credentials.credentials
    auth_service = AuthService()
    
    user = await auth_service.get_user_from_token(token)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    return user


async def get_current_active_user(
    current_user: dict = Depends(get_current_user)
) -> dict:
    """Get current active user (can add additional checks here)"""
    return current_user


def require_role(allowed_roles: List[UserRole]):
    """
    Dependency factory to check if user has required role
    Usage: @router.get("/admin", dependencies=[Depends(require_role([UserRole.ADMIN]))])
    """
    async def role_checker(current_user: dict = Depends(get_current_user)) -> dict:
        user_role = current_user.get("role")
        
        if user_role not in [role.value for role in allowed_roles]:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied. Required roles: {[r.value for r in allowed_roles]}"
            )
        
        return current_user
    
    return role_checker


# Specific role dependencies for convenience
async def require_admin(current_user: dict = Depends(get_current_user)) -> dict:
    """Require admin role"""
    if current_user.get("role") != UserRole.ADMIN.value:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required"
        )
    return current_user


async def require_trainer(current_user: dict = Depends(get_current_user)) -> dict:
    """Require trainer role or higher (admin can also access)"""
    user_role = current_user.get("role")
    if user_role not in [UserRole.TRAINER.value, UserRole.ADMIN.value]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Trainer access required"
        )
    return current_user


async def require_seller(current_user: dict = Depends(get_current_user)) -> dict:
    """Require seller role or higher (admin can also access)"""
    user_role = current_user.get("role")
    if user_role not in [UserRole.SELLER.value, UserRole.ADMIN.value]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Seller access required"
        )
    return current_user


# Optional user (for endpoints that work with or without auth)
async def get_optional_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(HTTPBearer(auto_error=False))
) -> Optional[dict]:
    """Get current user if token is provided, otherwise return None"""
    if not credentials:
        return None
    
    token = credentials.credentials
    auth_service = AuthService()
    
    try:
        user = await auth_service.get_user_from_token(token)
        return user
    except:
        return None
