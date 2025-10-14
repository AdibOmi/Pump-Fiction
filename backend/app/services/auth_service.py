from typing import Optional, Dict, Any
from ..core.supabase_client import get_supabase_client
from ..schemas.auth_schema import (
    SignupRequest, LoginRequest, UserRole, 
    RoleApplicationRequest, ApplicationStatus
)
from gotrue.errors import AuthApiError
import uuid


class AuthService:
    """Service for handling authentication with Supabase"""
    
    def __init__(self):
        self.supabase = get_supabase_client()
    
    async def signup(self, signup_data: SignupRequest) -> Dict[str, Any]:
        """
        Register a new user with Supabase Auth
        Default role is normal_user
        """
        try:
            # Create user in Supabase Auth
            auth_response = self.supabase.auth.sign_up({
                "email": signup_data.email,
                "password": signup_data.password,
                "options": {
                    "data": {
                        "full_name": signup_data.full_name,
                        "role": UserRole.NORMAL_USER.value
                    }
                }
            })
            
            if not auth_response.user:
                raise ValueError("User creation failed")
            
            # Store additional user metadata in public.users table
            user_data = {
                "id": auth_response.user.id,
                "email": signup_data.email,
                "full_name": signup_data.full_name,
                "role": UserRole.NORMAL_USER.value,
            }
            
            self.supabase.table("users").insert(user_data).execute()
            
            # Check if session exists (email confirmation disabled) or not (email confirmation required)
            if auth_response.session:
                # User is immediately logged in
                return {
                    "access_token": auth_response.session.access_token,
                    "refresh_token": auth_response.session.refresh_token,
                    "token_type": "bearer",
                    "expires_in": auth_response.session.expires_in,
                    "user": {
                        "id": auth_response.user.id,
                        "email": auth_response.user.email,
                        "full_name": signup_data.full_name,
                        "role": UserRole.NORMAL_USER.value
                    }
                }
            else:
                # Email confirmation required
                return {
                    "access_token": None,
                    "refresh_token": None,
                    "token_type": "bearer",
                    "expires_in": 0,
                    "user": {
                        "id": auth_response.user.id,
                        "email": auth_response.user.email,
                        "full_name": signup_data.full_name,
                        "role": UserRole.NORMAL_USER.value
                    },
                    "message": "Please check your email to confirm your account before logging in."
                }
        except AuthApiError as e:
            raise ValueError(f"Signup failed: {e.message}")
        except Exception as e:
            raise ValueError(f"Signup failed: {str(e)}")
    
    async def login(self, login_data: LoginRequest) -> Dict[str, Any]:
        """Authenticate user and return tokens"""
        try:
            auth_response = self.supabase.auth.sign_in_with_password({
                "email": login_data.email,
                "password": login_data.password
            })
            
            if not auth_response.session:
                raise ValueError("Login failed")
            
            # Get user role from database
            user_record = self.supabase.table("users").select("*").eq("id", auth_response.user.id).single().execute()
            
            return {
                "access_token": auth_response.session.access_token,
                "refresh_token": auth_response.session.refresh_token,
                "token_type": "bearer",
                "expires_in": auth_response.session.expires_in,
                "user": {
                    "id": auth_response.user.id,
                    "email": auth_response.user.email,
                    "full_name": user_record.data.get("full_name"),
                    "role": user_record.data.get("role", UserRole.NORMAL_USER.value)
                }
            }
        except AuthApiError as e:
            raise ValueError(f"Login failed: {e.message}")
        except Exception as e:
            raise ValueError(f"Login failed: {str(e)}")
    
    async def refresh_token(self, refresh_token: str) -> Dict[str, Any]:
        """Refresh access token"""
        try:
            auth_response = self.supabase.auth.refresh_session(refresh_token)
            
            if not auth_response.session:
                raise ValueError("Token refresh failed")
            
            # Get user role from database
            user_record = self.supabase.table("users").select("*").eq("id", auth_response.user.id).single().execute()
            
            return {
                "access_token": auth_response.session.access_token,
                "refresh_token": auth_response.session.refresh_token,
                "token_type": "bearer",
                "expires_in": auth_response.session.expires_in,
                "user": {
                    "id": auth_response.user.id,
                    "email": auth_response.user.email,
                    "full_name": user_record.data.get("full_name"),
                    "role": user_record.data.get("role", UserRole.NORMAL_USER.value)
                }
            }
        except Exception as e:
            raise ValueError(f"Token refresh failed: {str(e)}")
    
    async def logout(self, access_token: str) -> bool:
        """Logout user (invalidate session)"""
        try:
            self.supabase.auth.sign_out()
            return True
        except Exception as e:
            raise ValueError(f"Logout failed: {str(e)}")
    
    async def get_user_from_token(self, access_token: str) -> Optional[Dict[str, Any]]:
        """Get user details from access token"""
        try:
            user = self.supabase.auth.get_user(access_token)
            
            if not user or not user.user:
                return None
            
            # Get full user data from database
            user_record = self.supabase.table("users").select("*").eq("id", user.user.id).single().execute()
            
            return {
                "id": user.user.id,
                "email": user.user.email,
                "full_name": user_record.data.get("full_name"),
                "role": user_record.data.get("role", UserRole.NORMAL_USER.value),
                "created_at": user_record.data.get("created_at")
            }
        except Exception as e:
            return None
    
    async def update_user_role(self, user_id: str, new_role: UserRole) -> bool:
        """Update user's role (admin only operation)"""
        try:
            self.supabase.table("users").update({"role": new_role.value}).eq("id", user_id).execute()
            
            # Also update in auth metadata
            self.supabase.auth.admin.update_user_by_id(
                user_id,
                {"user_metadata": {"role": new_role.value}}
            )
            return True
        except Exception as e:
            raise ValueError(f"Failed to update user role: {str(e)}")
