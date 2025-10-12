from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from ..models.user_model import User


class UserRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_by_email(self, email: str):
        q = select(User).where(User.email == email)
        result = await self.db.execute(q)
        return result.scalars().first()

    async def create(self, email: str, hashed_password: str):
        user = User(email=email, hashed_password=hashed_password)
        self.db.add(user)
        await self.db.commit()
        await self.db.refresh(user)
        return user
