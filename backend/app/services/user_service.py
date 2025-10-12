from ..repositories.user_repository import UserRepository
from ..core.security import get_password_hash, verify_password, create_access_token
from ..schemas.user_schema import UserCreate


class UserService:
    def __init__(self, repository: UserRepository):
        self.repository = repository

    async def register(self, user_in: UserCreate):
        hashed = get_password_hash(user_in.password)
        user = await self.repository.create(user_in.email, hashed)
        return user

    async def authenticate(self, email: str, password: str):
        user = await self.repository.get_by_email(email)
        if not user:
            return None
        if not verify_password(password, user.hashed_password):
            return None
        token = create_access_token(str(user.id))
        return {'access_token': token}
