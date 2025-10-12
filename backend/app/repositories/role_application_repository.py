from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import update
from typing import List, Optional
from ..models.role_application_model import RoleApplication, ApplicationStatusEnum, UserRoleEnum
import uuid


class RoleApplicationRepository:
    """Repository for role application operations"""
    
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def create_application(
        self, 
        user_id: str, 
        user_email: str,
        user_name: str,
        requested_role: UserRoleEnum,
        current_role: UserRoleEnum,
        reason: str,
        qualifications: Optional[str] = None
    ) -> RoleApplication:
        """Create a new role application"""
        application = RoleApplication(
            id=str(uuid.uuid4()),
            user_id=user_id,
            user_email=user_email,
            user_name=user_name,
            requested_role=requested_role,
            current_role=current_role,
            status=ApplicationStatusEnum.PENDING,
            reason=reason,
            qualifications=qualifications
        )
        self.db.add(application)
        await self.db.commit()
        await self.db.refresh(application)
        return application
    
    async def get_application_by_id(self, application_id: str) -> Optional[RoleApplication]:
        """Get application by ID"""
        q = select(RoleApplication).where(RoleApplication.id == application_id)
        result = await self.db.execute(q)
        return result.scalars().first()
    
    async def get_user_pending_application(self, user_id: str) -> Optional[RoleApplication]:
        """Check if user has a pending application"""
        q = select(RoleApplication).where(
            RoleApplication.user_id == user_id,
            RoleApplication.status == ApplicationStatusEnum.PENDING
        )
        result = await self.db.execute(q)
        return result.scalars().first()
    
    async def get_all_pending_applications(self) -> List[RoleApplication]:
        """Get all pending applications (for admin review)"""
        q = select(RoleApplication).where(
            RoleApplication.status == ApplicationStatusEnum.PENDING
        ).order_by(RoleApplication.created_at.desc())
        result = await self.db.execute(q)
        return result.scalars().all()
    
    async def get_all_applications(self) -> List[RoleApplication]:
        """Get all applications"""
        q = select(RoleApplication).order_by(RoleApplication.created_at.desc())
        result = await self.db.execute(q)
        return result.scalars().all()
    
    async def get_user_applications(self, user_id: str) -> List[RoleApplication]:
        """Get all applications for a specific user"""
        q = select(RoleApplication).where(
            RoleApplication.user_id == user_id
        ).order_by(RoleApplication.created_at.desc())
        result = await self.db.execute(q)
        return result.scalars().all()
    
    async def update_application_status(
        self,
        application_id: str,
        status: ApplicationStatusEnum,
        admin_notes: Optional[str] = None
    ) -> Optional[RoleApplication]:
        """Update application status (approve/reject)"""
        stmt = update(RoleApplication).where(
            RoleApplication.id == application_id
        ).values(
            status=status,
            admin_notes=admin_notes
        ).returning(RoleApplication)
        
        result = await self.db.execute(stmt)
        await self.db.commit()
        return result.scalars().first()
