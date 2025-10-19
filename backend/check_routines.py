"""
Simple script to check if routines exist in the database
Run: python check_routines.py
"""
import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

# Get database URL from .env
db_url = os.getenv("DATABASE_URL")
if db_url:
    # Convert async URL to sync URL for psycopg2
    db_url = db_url.replace("postgresql+psycopg_async://", "postgresql://")

print("Connecting to database...")
print(f"URL: {db_url[:50]}...")

try:
    conn = psycopg2.connect(db_url)
    cursor = conn.cursor()

    print("\n" + "="*60)
    print("CHECKING ROUTINE HEADERS")
    print("="*60)

    cursor.execute("""
        SELECT id, user_id, title, day_selected, is_archived, created_at
        FROM routine_headers
        ORDER BY created_at DESC
        LIMIT 10
    """)

    routines = cursor.fetchall()
    print(f"\nFound {len(routines)} routines:\n")

    for routine in routines:
        routine_id, user_id, title, day_selected, is_archived, created_at = routine
        print(f"📋 Routine: {title}")
        print(f"   ID: {routine_id}")
        print(f"   User: {user_id}")
        print(f"   Days: {day_selected}")
        print(f"   Archived: {is_archived}")
        print(f"   Created: {created_at}")

        # Check exercises for this routine
        cursor.execute("""
            SELECT title, sets, min_reps, max_reps, day_label, position
            FROM routine_exercises
            WHERE routine_id = %s
            ORDER BY position
        """, (routine_id,))

        exercises = cursor.fetchall()
        print(f"   Exercises: {len(exercises)}")

        if exercises:
            for ex_title, sets, min_reps, max_reps, day_label, position in exercises:
                print(f"      • {ex_title}: {sets} sets, {min_reps}-{max_reps} reps (Day: {day_label})")
        else:
            print("      ⚠️ NO EXERCISES!")

        print()

    if not routines:
        print("⚠️ NO ROUTINES FOUND IN DATABASE!")
        print("\nThis is why the workout page shows 'no exercises'.")
        print("You need to create a routine first!")

    print("\n" + "="*60)
    print("CHECKING ROUTINE EXERCISES (ALL)")
    print("="*60)

    cursor.execute("""
        SELECT COUNT(*) FROM routine_exercises
    """)
    total_exercises = cursor.fetchone()[0]
    print(f"\nTotal routine exercises in database: {total_exercises}\n")

    cursor.close()
    conn.close()

    print("✅ Database check complete!")

except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()
