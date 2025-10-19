"""
Migration script to create tracker tables in Supabase database
"""
from app.core.database import engine, Base
from app.models.user_model import User
from app.models.tracker_model import Tracker, TrackerEntry


def create_tracker_tables():
    """Create tracker and tracker_entry tables"""
    print("Creating tracker tables...")

    try:
        # Import all models to ensure they're registered with Base
        Base.metadata.create_all(bind=engine, tables=[
            Tracker.__table__,
            TrackerEntry.__table__
        ])
        print("✓ Tracker tables created successfully!")
        print("  - trackers")
        print("  - tracker_entries")

    except Exception as e:
        print(f"✗ Error creating tracker tables: {e}")
        raise


if __name__ == "__main__":
    create_tracker_tables()
