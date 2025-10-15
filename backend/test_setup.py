"""
Test script to verify the post functionality
Run this after setting up the database and storage
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.database import sync_engine, Base
from app.models import Post, PostPhoto, User


def create_tables():
    """Create all tables in the database"""
    try:
        Base.metadata.create_all(bind=sync_engine)
        print("✅ Tables created successfully!")
        
        # List created tables
        from sqlalchemy import inspect
        inspector = inspect(sync_engine)
        tables = inspector.get_table_names()
        print(f"📋 Created tables: {tables}")
        
    except Exception as e:
        print(f"❌ Error creating tables: {e}")


def test_database_connection():
    """Test database connection"""
    try:
        from app.core.database import SessionLocal
        db = SessionLocal()
        
        # Test query
        result = db.execute("SELECT 1")
        print("✅ Database connection successful!")
        
        db.close()
        
    except Exception as e:
        print(f"❌ Database connection failed: {e}")


if __name__ == "__main__":
    print("🧪 Testing post functionality setup...")
    print("\n1. Testing database connection...")
    test_database_connection()
    
    print("\n2. Creating tables...")
    create_tables()
    
    print("\n✅ Setup verification completed!")
    print("Next steps:")
    print("1. Run: python setup_storage.py")
    print("2. Apply database migration: migrations/add_posts_tables.sql")
    print("3. Start the FastAPI server")
    print("4. Test the API endpoints")