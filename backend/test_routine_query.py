"""
Quick diagnostic script to check what's in the database
Run from backend directory: python test_routine_query.py
"""
import asyncio
from sqlalchemy import create_engine, select
from sqlalchemy.orm import Session, joinedload
from app.models.routine_model import RoutineHeader, RoutineExercise
from app.core.config import settings

def test_routines():
    # Create engine
    engine = create_engine(str(settings.DATABASE_URL))

    with Session(engine) as session:
        print("=" * 60)
        print("TESTING ROUTINE QUERY")
        print("=" * 60)

        # Query all routines with exercises
        routines = (
            session.query(RoutineHeader)
            .options(joinedload(RoutineHeader.exercises))
            .all()
        )

        print(f"\n📊 Found {len(routines)} routines in database\n")

        for routine in routines:
            print(f"Routine: {routine.title}")
            print(f"  ID: {routine.id}")
            print(f"  User ID: {routine.user_id}")
            print(f"  Day Selected: {routine.day_selected}")
            print(f"  Is Archived: {routine.is_archived}")
            print(f"  Exercises loaded: {len(routine.exercises)}")

            if routine.exercises:
                for i, exercise in enumerate(routine.exercises):
                    print(f"    {i+1}. {exercise.title}")
                    print(f"       Sets: {exercise.sets}, Reps: {exercise.min_reps}-{exercise.max_reps}")
                    print(f"       Day Label: {exercise.day_label}, Position: {exercise.position}")
            else:
                print("    ⚠️  NO EXERCISES FOUND FOR THIS ROUTINE!")

                # Check if exercises exist separately
                exercises_separate = (
                    session.query(RoutineExercise)
                    .filter(RoutineExercise.routine_id == routine.id)
                    .all()
                )
                print(f"    Checking exercises table directly: {len(exercises_separate)} found")

            print()

        # Also query exercises table directly
        print("\n" + "=" * 60)
        print("EXERCISES TABLE DUMP")
        print("=" * 60)
        all_exercises = session.query(RoutineExercise).all()
        print(f"\nTotal exercises in database: {len(all_exercises)}\n")

        for ex in all_exercises:
            print(f"Exercise: {ex.title}")
            print(f"  Routine ID: {ex.routine_id}")
            print(f"  Day Label: {ex.day_label}")
            print(f"  Sets: {ex.sets}, Reps: {ex.min_reps}-{ex.max_reps}")
            print()

if __name__ == "__main__":
    test_routines()
