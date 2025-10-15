"""
Database initialization script
Run this to create tables in Supabase PostgreSQL
"""
import asyncio
from sqlalchemy.ext.asyncio import create_async_engine
from app.core.config import settings
from app.core.database import Base
from app.models.role_application_model import RoleApplication
from app.models.user_model import User
from app.models.ai_chat_model import AIChatSession, AIChatMessage

# Fix for Windows event loop with psycopg async
asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())


async def init_db():
    """Create all database tables"""
    engine = create_async_engine(settings.DATABASE_URL, echo=True)
    
    async with engine.begin() as conn:
        # Drop all tables (use with caution in production!)
        # await conn.run_sync(Base.metadata.drop_all)
        
        # Create all tables
        await conn.run_sync(Base.metadata.create_all)
    
    await engine.dispose()
    print("Database tables created successfully!")


if __name__ == "__main__":
    asyncio.run(init_db())
