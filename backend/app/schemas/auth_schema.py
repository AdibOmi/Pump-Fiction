from pydantic import BaseModel, EmailStr, ConfigDict
from typing import Optional
from enum import Enum
from datetime import datetime


class UserRole(str, Enum):
    """User roles in the system"""
    ADMIN = "admin"
    NORMAL_USER = "normal_user"
    TRAINER = "trainer"
    SELLER = "seller"


class ApplicationStatus(str, Enum):
    """Status of role applications"""
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"


# ========== Authentication Schemas ==========

class SignupRequest(BaseModel):
    email: EmailStr
    password: str
    full_name: str


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: Optional[str] = None
    refresh_token: Optional[str] = None
    token_type: str = "bearer"
    expires_in: int
    user: dict
    message: Optional[str] = None  # For email confirmation messages


class RefreshTokenRequest(BaseModel):
    refresh_token: str


# ========== User Profile Schemas ==========

class UserProfile(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    
    id: str
    email: str
    full_name: str
    role: UserRole
    created_at: Optional[datetime] = None


class UpdateProfileRequest(BaseModel):
    full_name: Optional[str] = None


# ========== Role Application Schemas ==========

class RoleApplicationRequest(BaseModel):
    requested_role: UserRole
    reason: str  # Why they want this role
    qualifications: Optional[str] = None  # Certifications, experience, etc.


class RoleApplicationResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    
    id: str
    user_id: str
    user_email: str
    user_name: str
    requested_role: UserRole
    current_role: UserRole
    status: ApplicationStatus
    reason: str
    qualifications: Optional[str]
    admin_notes: Optional[str] = None
    created_at: datetime
    updated_at: Optional[datetime] = None


class ApplicationDecisionRequest(BaseModel):
    application_id: str
    decision: ApplicationStatus  # approved or rejected
    admin_notes: Optional[str] = None


# ========== Admin Schemas ==========

class UserManagementResponse(BaseModel):
    id: str
    email: str
    full_name: str
    role: UserRole
    created_at: datetime
    last_sign_in_at: Optional[datetime] = None


class UpdateUserRoleRequest(BaseModel):
    user_id: str
    new_role: UserRole
