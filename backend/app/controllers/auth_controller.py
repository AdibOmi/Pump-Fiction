from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from ..schemas.auth_schema import (
    SignupRequest, LoginRequest, TokenResponse, RefreshTokenRequest,
    UserProfile, UpdateProfileRequest, RoleApplicationRequest,
    RoleApplicationResponse, ApplicationDecisionRequest, UserRole,
    ApplicationStatus
)
from ..services.auth_service import AuthService
from ..repositories.role_application_repository import RoleApplicationRepository
from ..core.database import get_db
from ..core.dependencies import (
    get_current_user, require_admin, get_current_active_user
)
from ..models.role_application_model import UserRoleEnum, ApplicationStatusEnum

router = APIRouter(prefix='/auth', tags=['authentication'])


@router.post('/signup', response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def signup(signup_data: SignupRequest):
    """
    Register a new user account
    - Default role: normal_user
    - Returns access token and user info
    """
    auth_service = AuthService()
    
    try:
        result = await auth_service.signup(signup_data)
        return TokenResponse(**result)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )


@router.post('/login', response_model=TokenResponse)
async def login(login_data: LoginRequest):
    """
    Authenticate user and get access token
    - Returns JWT tokens and user info
    """
    auth_service = AuthService()
    
    try:
        result = await auth_service.login(login_data)
        return TokenResponse(**result)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e)
        )


@router.post('/refresh', response_model=TokenResponse)
async def refresh_token(refresh_data: RefreshTokenRequest):
    """
    Refresh access token using refresh token
    - Returns new access token and refresh token
    """
    auth_service = AuthService()
    
    try:
        result = await auth_service.refresh_token(refresh_data.refresh_token)
        return TokenResponse(**result)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e)
        )


@router.post('/logout')
async def logout(current_user: dict = Depends(get_current_user)):
    """
    Logout current user
    - Invalidates the session
    """
    auth_service = AuthService()
    
    try:
        await auth_service.logout(current_user.get("id"))
        return {"message": "Logged out successfully"}
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )


@router.get('/me', response_model=UserProfile)
async def get_current_user_profile(current_user: dict = Depends(get_current_active_user)):
    """
    Get current user's profile
    - Requires valid JWT token
    """
    return UserProfile(
        id=current_user["id"],
        email=current_user["email"],
        full_name=current_user["full_name"],
        phone_number=current_user.get("phone_number"),
        role=UserRole(current_user["role"]),
        created_at=current_user.get("created_at")
    )


@router.put('/me', response_model=UserProfile)
async def update_profile(
    update_data: UpdateProfileRequest,
    current_user: dict = Depends(get_current_active_user)
):
    """
    Update current user's profile
    - Can update: full_name, phone_number
    """
    auth_service = AuthService()
    
    try:
        updated_user = await auth_service.update_user_profile(
            user_id=current_user["id"],
            full_name=update_data.full_name,
            phone_number=update_data.phone_number
        )
        
        return UserProfile(
            id=updated_user["id"],
            email=updated_user["email"],
            full_name=updated_user["full_name"],
            phone_number=updated_user.get("phone_number"),
            role=UserRole(updated_user["role"]),
            created_at=updated_user.get("created_at")
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )


# ========== Role Application Endpoints ==========

@router.post('/apply-role', response_model=RoleApplicationResponse, status_code=status.HTTP_201_CREATED)
async def apply_for_role(
    application_data: RoleApplicationRequest,
    current_user: dict = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Apply for trainer or seller role
    - Users can apply to upgrade their role
    - Only one pending application allowed at a time
    - Cannot apply for admin role
    """
    # Validation
    if application_data.requested_role == UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot apply for admin role"
        )
    
    if application_data.requested_role.value == current_user["role"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You already have this role"
        )
    
    repo = RoleApplicationRepository(db)
    
    # Check for existing pending application
    existing = await repo.get_user_pending_application(current_user["id"])
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You already have a pending application"
        )
    
    # Create application
    application = await repo.create_application(
        user_id=current_user["id"],
        user_email=current_user["email"],
        user_name=current_user["full_name"],
        requested_role=UserRoleEnum(application_data.requested_role.value),
        current_role=UserRoleEnum(current_user["role"]),
        reason=application_data.reason,
        qualifications=application_data.qualifications
    )
    
    return RoleApplicationResponse(
        id=application.id,
        user_id=application.user_id,
        user_email=application.user_email,
        user_name=application.user_name,
        requested_role=UserRole(application.requested_role.value),
        current_role=UserRole(application.current_role.value),
        status=ApplicationStatus(application.status.value),
        reason=application.reason,
        qualifications=application.qualifications,
        admin_notes=application.admin_notes,
        created_at=application.created_at,
        updated_at=application.updated_at
    )


@router.get('/my-applications', response_model=list[RoleApplicationResponse])
async def get_my_applications(
    current_user: dict = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Get current user's role applications
    - Returns all applications (pending, approved, rejected)
    """
    repo = RoleApplicationRepository(db)
    applications = await repo.get_user_applications(current_user["id"])
    
    return [
        RoleApplicationResponse(
            id=app.id,
            user_id=app.user_id,
            user_email=app.user_email,
            user_name=app.user_name,
            requested_role=UserRole(app.requested_role.value),
            current_role=UserRole(app.current_role.value),
            status=ApplicationStatus(app.status.value),
            reason=app.reason,
            qualifications=app.qualifications,
            admin_notes=app.admin_notes,
            created_at=app.created_at,
            updated_at=app.updated_at
        )
        for app in applications
    ]


# ========== Admin-Only Endpoints ==========

@router.get('/admin/applications/pending', response_model=list[RoleApplicationResponse])
async def get_pending_applications(
    admin_user: dict = Depends(require_admin),
    db: AsyncSession = Depends(get_db)
):
    """
    Get all pending role applications (Admin only)
    - Returns applications awaiting approval
    """
    repo = RoleApplicationRepository(db)
    applications = await repo.get_all_pending_applications()
    
    return [
        RoleApplicationResponse(
            id=app.id,
            user_id=app.user_id,
            user_email=app.user_email,
            user_name=app.user_name,
            requested_role=UserRole(app.requested_role.value),
            current_role=UserRole(app.current_role.value),
            status=ApplicationStatus(app.status.value),
            reason=app.reason,
            qualifications=app.qualifications,
            admin_notes=app.admin_notes,
            created_at=app.created_at,
            updated_at=app.updated_at
        )
        for app in applications
    ]


@router.get('/admin/applications', response_model=list[RoleApplicationResponse])
async def get_all_applications(
    admin_user: dict = Depends(require_admin),
    db: AsyncSession = Depends(get_db)
):
    """
    Get all role applications (Admin only)
    - Returns all applications regardless of status
    """
    repo = RoleApplicationRepository(db)
    applications = await repo.get_all_applications()
    
    return [
        RoleApplicationResponse(
            id=app.id,
            user_id=app.user_id,
            user_email=app.user_email,
            user_name=app.user_name,
            requested_role=UserRole(app.requested_role.value),
            current_role=UserRole(app.current_role.value),
            status=ApplicationStatus(app.status.value),
            reason=app.reason,
            qualifications=app.qualifications,
            admin_notes=app.admin_notes,
            created_at=app.created_at,
            updated_at=app.updated_at
        )
        for app in applications
    ]


@router.post('/admin/applications/review')
async def review_application(
    decision_data: ApplicationDecisionRequest,
    admin_user: dict = Depends(require_admin),
    db: AsyncSession = Depends(get_db)
):
    """
    Approve or reject a role application (Admin only)
    - Updates application status
    - If approved, updates user's role
    """
    if decision_data.decision not in [ApplicationStatus.APPROVED, ApplicationStatus.REJECTED]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Decision must be 'approved' or 'rejected'"
        )
    
    repo = RoleApplicationRepository(db)
    
    # Get application
    application = await repo.get_application_by_id(decision_data.application_id)
    if not application:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Application not found"
        )
    
    if application.status != ApplicationStatusEnum.PENDING:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Application has already been reviewed"
        )
    
    # Update application status
    updated_app = await repo.update_application_status(
        application_id=decision_data.application_id,
        status=ApplicationStatusEnum(decision_data.decision.value),
        admin_notes=decision_data.admin_notes
    )
    
    # If approved, update user's role
    if decision_data.decision == ApplicationStatus.APPROVED:
        auth_service = AuthService()
        try:
            await auth_service.update_user_role(
                user_id=application.user_id,
                new_role=UserRole(application.requested_role.value)
            )
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to update user role: {str(e)}"
            )
    
    return {
        "message": f"Application {decision_data.decision.value}",
        "application_id": decision_data.application_id,
        "user_id": application.user_id,
        "new_role": application.requested_role.value if decision_data.decision == ApplicationStatus.APPROVED else None
    }
