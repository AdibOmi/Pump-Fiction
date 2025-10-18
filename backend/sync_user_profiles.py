"""
Sync User Profiles Script
Ensures all users have corresponding profile entries in user_profiles table
Can be run manually or as part of deployment
"""
import os
from dotenv import load_dotenv
from supabase import create_client, Client
import sys

# Load environment variables
load_dotenv()

def get_supabase_client() -> Client:
    """Get Supabase client"""
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_SERVICE_KEY")  # Use service key for admin operations
    
    if not url or not key:
        raise ValueError("SUPABASE_URL and SUPABASE_SERVICE_KEY must be set")
    
    return create_client(url, key)


def sync_user_profiles():
    """Sync user profiles - create missing profiles for existing users"""
    print("🔄 Starting user profile sync...")
    print("=" * 60)
    
    supabase = get_supabase_client()
    
    try:
        # Get all users
        print("\n📊 Fetching all users...")
        users_response = supabase.table("users").select("id, email, full_name, phone_number").execute()
        users = users_response.data
        print(f"✓ Found {len(users)} users")
        
        # Get all existing profiles
        print("\n📊 Fetching existing profiles...")
        profiles_response = supabase.table("user_profiles").select("user_id").execute()
        existing_profile_user_ids = {profile['user_id'] for profile in profiles_response.data}
        print(f"✓ Found {len(existing_profile_user_ids)} existing profiles")
        
        # Find users without profiles
        users_without_profiles = [
            user for user in users 
            if user['id'] not in existing_profile_user_ids
        ]
        
        if not users_without_profiles:
            print("\n✅ All users already have profiles! Nothing to do.")
            return
        
        print(f"\n⚠️  Found {len(users_without_profiles)} users without profiles")
        print("\n📝 Creating missing profiles...")
        
        # Create profiles for users who don't have one
        created_count = 0
        failed_count = 0
        
        for user in users_without_profiles:
            try:
                profile_data = {
                    "user_id": user['id'],
                    "full_name": user.get('full_name'),
                    "phone_number": user.get('phone_number')
                }
                
                supabase.table("user_profiles").insert(profile_data).execute()
                created_count += 1
                print(f"  ✓ Created profile for: {user['email']}")
                
            except Exception as e:
                failed_count += 1
                print(f"  ✗ Failed to create profile for {user['email']}: {e}")
        
        # Summary
        print("\n" + "=" * 60)
        print("📊 Sync Summary:")
        print(f"   • Total users: {len(users)}")
        print(f"   • Existing profiles: {len(existing_profile_user_ids)}")
        print(f"   • Profiles created: {created_count}")
        if failed_count > 0:
            print(f"   • Failed: {failed_count}")
        print("=" * 60)
        
        if created_count > 0:
            print(f"\n✅ Successfully created {created_count} new profile(s)!")
        if failed_count > 0:
            print(f"\n⚠️  {failed_count} profile(s) failed to create")
            return 1
        
        return 0
        
    except Exception as e:
        print(f"\n❌ Error during sync: {e}")
        return 1


def verify_sync():
    """Verify that all users have profiles"""
    print("\n🔍 Verifying sync...")
    
    supabase = get_supabase_client()
    
    try:
        users_response = supabase.table("users").select("id").execute()
        profiles_response = supabase.table("user_profiles").select("user_id").execute()
        
        user_count = len(users_response.data)
        profile_count = len(profiles_response.data)
        
        print(f"   Users: {user_count}")
        print(f"   Profiles: {profile_count}")
        
        if user_count == profile_count:
            print("   ✅ All users have profiles!")
            return True
        else:
            print(f"   ⚠️  Mismatch: {user_count} users but {profile_count} profiles")
            return False
            
    except Exception as e:
        print(f"   ❌ Verification failed: {e}")
        return False


if __name__ == "__main__":
    try:
        exit_code = sync_user_profiles()
        verify_sync()
        sys.exit(exit_code)
    except KeyboardInterrupt:
        print("\n\n⚠️  Sync cancelled by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Fatal error: {e}")
        sys.exit(1)
