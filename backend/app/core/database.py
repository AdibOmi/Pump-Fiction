from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy import create_engine
from .config import settings
import re

# Async engine and session for async operations (for parts of the app that use async ORM)
async_engine = create_async_engine(settings.DATABASE_URL, echo=True)
AsyncSessionLocal = sessionmaker(async_engine, expire_on_commit=False, class_=AsyncSession)


def _make_sync_db_url(url: str) -> str:
    # Convert common async driver URLs to sync equivalents for use with Session (sync)
    # sqlite+aiosqlite:/// -> sqlite:/// 
    if url.startswith('sqlite+aiosqlite:'):
        return url.replace('sqlite+aiosqlite', 'sqlite', 1)
    # postgresql+asyncpg:// -> postgresql+psycopg://
    if url.startswith('postgresql+asyncpg:'):
        return url.replace('postgresql+asyncpg', 'postgresql+psycopg', 1)
    # psycopg3 async variant sometimes appears as postgresql+psycopg_async
    if 'psycopg_async' in url:
        return url.replace('psycopg_async', 'psycopg')
    return url

# Sync engine and session for sync operations used across most of the app
sync_database_url = _make_sync_db_url(settings.DATABASE_URL)
sync_engine = create_engine(sync_database_url, echo=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=sync_engine)

Base = declarative_base()

async def get_db():
    # Provide async session if needed elsewhere (not used by journal currently)
    async with AsyncSessionLocal() as session:
        yield session

def get_sync_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
