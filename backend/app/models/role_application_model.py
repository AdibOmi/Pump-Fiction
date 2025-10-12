from sqlalchemy import Column, String, DateTime, Enum as SQLEnum, Text
from datetime import datetime
import enum
from ..core.database import Base


class UserRoleEnum(str, enum.Enum):
    """User roles enum for database"""
    ADMIN = "admin"
    NORMAL_USER = "normal_user"
    TRAINER = "trainer"
    SELLER = "seller"


class ApplicationStatusEnum(str, enum.Enum):
    """Application status enum for database"""
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"


class RoleApplication(Base):
    """Model for storing role application requests"""
    __tablename__ = 'role_applications'
    
    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, nullable=False, index=True)  # Supabase user ID
    user_email = Column(String, nullable=False)
    user_name = Column(String, nullable=False)
    requested_role = Column(SQLEnum(UserRoleEnum), nullable=False)
    current_role = Column(SQLEnum(UserRoleEnum), nullable=False)
    status = Column(SQLEnum(ApplicationStatusEnum), default=ApplicationStatusEnum.PENDING, nullable=False)
    reason = Column(Text, nullable=False)
    qualifications = Column(Text, nullable=True)
    admin_notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, onupdate=datetime.utcnow, nullable=True)
