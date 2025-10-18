"""
Quick Setup Script for User Profile Auto-Creation
Runs all necessary steps to enable automatic profile creation
"""
import os
from pathlib import Path

def read_sql_file(filename):
    """Read SQL file content"""
    migrations_dir = Path(__file__).parent / "migrations"
    file_path = migrations_dir / filename
    
    if not file_path.exists():
        print(f"❌ File not found: {file_path}")
        return None
    
    with open(file_path, 'r', encoding='utf-8') as f:
        return f.read()

def print_instructions():
    """Print setup instructions"""
    print("""
╔═══════════════════════════════════════════════════════════════╗
║         User Profile Auto-Creation Setup                      ║
╚═══════════════════════════════════════════════════════════════╝

This script will guide you through setting up automatic profile 
creation for all users.

PREREQUISITE:
✓ Migration 001_create_user_profiles_table.sql must be run first
  (Creates the user_profiles table)

WHAT THIS DOES:
1. Creates a database trigger to auto-create profiles for new users
2. Migrates existing users to have profiles
3. Verifies the setup

═══════════════════════════════════════════════════════════════

INSTRUCTIONS:

""")

def main():
    print_instructions()
    
    print("📝 STEP 1: Create Auto-Profile Trigger")
    print("=" * 60)
    print("\n1. Open your Supabase Dashboard")
    print("2. Go to: SQL Editor")
    print("3. Click: New Query")
    print("4. Copy the SQL below and paste it in the editor")
    print("5. Click: Run")
    print("\n" + "-" * 60)
    
    sql_trigger = read_sql_file("002_auto_create_user_profile.sql")
    if sql_trigger:
        print("\n--- COPY THIS SQL (002_auto_create_user_profile.sql) ---\n")
        print(sql_trigger)
        print("\n--- END OF SQL ---\n")
    
    input("\n⏸️  Press ENTER after you've run the trigger SQL...")
    
    print("\n\n📝 STEP 2: Migrate Existing Users")
    print("=" * 60)
    print("\n1. In the same Supabase SQL Editor")
    print("2. Create a New Query")
    print("3. Copy the SQL below and paste it")
    print("4. Click: Run")
    print("\n" + "-" * 60)
    
    sql_migrate = read_sql_file("003_migrate_existing_users_to_profiles.sql")
    if sql_migrate:
        print("\n--- COPY THIS SQL (003_migrate_existing_users_to_profiles.sql) ---\n")
        print(sql_migrate)
        print("\n--- END OF SQL ---\n")
    
    input("\n⏸️  Press ENTER after you've run the migration SQL...")
    
    print("\n\n📝 STEP 3: Python Sync (Alternative)")
    print("=" * 60)
    print("\nIf you prefer, you can also run the Python sync script instead of Step 2:")
    print("\n  python sync_user_profiles.py")
    print("\nThis does the same thing as the SQL migration.")
    
    response = input("\n❓ Do you want to run the Python sync now? (y/n): ").lower()
    
    if response == 'y':
        print("\n🔄 Running Python sync...")
        try:
            import sync_user_profiles
            sync_user_profiles.sync_user_profiles()
            sync_user_profiles.verify_sync()
        except Exception as e:
            print(f"\n❌ Error: {e}")
            print("\nMake sure:")
            print("  1. You have installed dependencies: pip install supabase python-dotenv")
            print("  2. Your .env file has SUPABASE_URL and SUPABASE_SERVICE_KEY")
    
    print("\n\n📝 STEP 4: Verify Setup")
    print("=" * 60)
    print("\nRun this SQL to verify everything is working:")
    print("\n" + "-" * 60)
    print("""
-- Check if trigger exists
SELECT tgname, tgtype, tgenabled 
FROM pg_trigger 
WHERE tgname = 'trigger_create_user_profile';

-- Check that all users have profiles
SELECT 
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM user_profiles) as total_profiles,
    (SELECT COUNT(*) FROM users u 
     LEFT JOIN user_profiles up ON u.id = up.user_id 
     WHERE up.id IS NULL) as users_without_profiles;
""")
    print("-" * 60)
    
    print("\n\n✅ Setup Complete!")
    print("=" * 60)
    print("\nWhat happens now:")
    print("  1. ✓ Every new user signup automatically creates a profile")
    print("  2. ✓ Existing users now have profiles")
    print("  3. ✓ Profile page will show user data (name, email, etc.)")
    print("\nNext steps:")
    print("  • Test by creating a new user: python test_auth.py")
    print("  • Test the API: python test_profile.py")
    print("  • Run the Flutter app and check the profile page")
    print("\n📚 For more info, see: PROFILE_AUTOCREATE_GUIDE.md")
    print("=" * 60)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️  Setup cancelled by user")
    except Exception as e:
        print(f"\n❌ Error: {e}")
