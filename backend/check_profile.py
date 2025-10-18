"""
Check if user profile exists in database
"""
import asyncio
from sqlalchemy import text
from app.core.database import get_db

async def check_profile():
    async for db in get_db():
        # Check if profile exists for the logged-in user
        user_id = 'ec827cb5-bfcb-4b83-9d8d-d643b3a7fa04'
        
        print(f"🔍 Checking profile for user: {user_id}\n")
        
        # Check user table
        result = await db.execute(
            text("SELECT id, email, full_name, phone_number FROM users WHERE id = :user_id"),
            {"user_id": user_id}
        )
        user = result.first()
        
        if user:
            print("✅ User found in users table:")
            print(f"   ID: {user.id}")
            print(f"   Email: {user.email}")
            print(f"   Name: {user.full_name}")
            print(f"   Phone: {user.phone_number}\n")
        else:
            print("❌ User NOT found in users table\n")
        
        # Check user_profiles table
        result = await db.execute(
            text("SELECT * FROM user_profiles WHERE user_id = :user_id"),
            {"user_id": user_id}
        )
        profile = result.first()
        
        if profile:
            print("✅ Profile found in user_profiles table:")
            print(f"   Profile ID: {profile.id}")
            print(f"   User ID: {profile.user_id}")
            print(f"   Full Name: {profile.full_name}")
            print(f"   Phone: {profile.phone_number}")
            print(f"   Gender: {profile.gender}")
            print(f"   Weight: {profile.weight_kg}")
            print(f"   Height: {profile.height_cm}")
            print(f"   Fitness Goal: {profile.fitness_goal}")
            print(f"   Experience: {profile.experience_level}")
            print(f"   Training Frequency: {profile.training_frequency}")
            print(f"   Nutrition Goal: {profile.nutrition_goal}\n")
        else:
            print("❌ Profile NOT found in user_profiles table")
            print("   → The backend will auto-create it when you call GET /users/me/profile\n")
        
        break

if __name__ == "__main__":
    asyncio.run(check_profile())
