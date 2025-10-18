from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy import create_engine
from .config import settings

# Async engine and session for async operations
async_engine = create_async_engine(settings.DATABASE_URL, echo=True)
AsyncSessionLocal = sessionmaker(async_engine, expire_on_commit=False, class_=AsyncSession)

# Sync engine and session for sync operations
# Convert async driver to sync driver
sync_database_url = settings.DATABASE_URL.replace('postgresql+psycopg_async', 'postgresql+psycopg')
sync_database_url = sync_database_url.replace('+aiosqlite', '')  # For SQLite compatibility
sync_engine = create_engine(sync_database_url, echo=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=sync_engine)

Base = declarative_base()

async def get_db():
    async with AsyncSessionLocal() as session:
        yield session

def get_sync_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
