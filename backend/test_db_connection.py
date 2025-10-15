"""Test Supabase database connection"""
import asyncio
from app.core.database import engine
from sqlalchemy import text

# Fix for Windows event loop
asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

async def test_connection():
    try:
        print("Testing connection to Supabase PostgreSQL...")
        async with engine.connect() as conn:
            result = await conn.execute(text('SELECT version()'))
            version = result.scalar()
            print("[SUCCESS] Connected to Supabase!")
            print(f"[INFO] PostgreSQL version: {version[:60]}...")
            return True
    except Exception as e:
        print(f"[ERROR] Connection failed: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = asyncio.run(test_connection())
    if success:
        print("\n[SUCCESS] Database connection is working correctly!")
    else:
        print("\n[ERROR] Database connection failed. Check your .env file.")
