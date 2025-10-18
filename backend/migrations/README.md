# Database Migrations

## Overview

This folder contains SQL migration files for setting up and maintaining the Pump-Fiction database.

## Migration Files

### 001_create_user_profiles_table.sql
Creates the `user_profiles` table with all fitness-related fields, ENUM types, indexes, and triggers.

### 002_auto_create_user_profile.sql ⭐ **NEW**
Sets up a database trigger to automatically create a profile entry whenever a new user is created.

### 003_migrate_existing_users_to_profiles.sql ⭐ **NEW**
Creates profile entries for all existing users who don't have profiles yet.

### add_phone_number_to_users.sql
Adds phone_number field to the users table.

### add_posts_tables.sql
Creates tables for the social media posts feature.

### create_trackers_tables.sql ⭐ **NEW**
Creates tables for the fitness progress trackers feature.

### rollback_trackers_tables.sql
Rollback script for tracker tables.

## Running Migrations (IN ORDER)

### Step 1: Run the user_profiles table migration

1. Go to your Supabase project dashboard
2. Navigate to the SQL Editor
3. Copy the contents of `001_create_user_profiles_table.sql`
4. Paste and run the SQL in the editor

This will create:
- The `user_profiles` table with all necessary fields
- ENUM types for gender, fitness_goal, experience_level, and nutrition_goal
- Indexes for performance
- Automatic timestamp updates

### Step 2: Set up auto-profile creation (IMPORTANT) ⭐

**Run in SQL Editor:**
```sql
-- Copy and paste contents of 002_auto_create_user_profile.sql
```

This creates a trigger that automatically creates a profile entry whenever a new user signs up.

### Step 3: Migrate existing users ⭐

**Run in SQL Editor:**
```sql
-- Copy and paste contents of 003_migrate_existing_users_to_profiles.sql
```

This creates profiles for all users who already exist but don't have profiles yet.

### Step 4: Verify the migration

Run this query to verify everything is set up correctly:

```sql
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
```

Expected result:
- trigger_create_user_profile should exist and be enabled
- total_users should equal total_profiles
- users_without_profiles should be 0

### Step 5: Test the system

1. **Test automatic profile creation:**
   ```python
   cd backend
   python test_auth.py  # Create a new test user
   ```

2. **Verify in database:**
   ```sql
   SELECT u.email, up.id as profile_id 
   FROM users u 
   JOIN user_profiles up ON u.id = up.user_id 
   WHERE u.email = 'testuser@example.com';
   ```

3. **Test the API:**
   ```python
   python test_profile.py
   ```

## Alternative: Python Sync Script

If you prefer to use Python instead of SQL for Step 3:

```powershell
cd backend
python sync_user_profiles.py
```

This script:
- Finds users without profiles
- Creates missing profiles
- Verifies the sync
- Shows detailed progress

## Backend Endpoints

After running migrations, these profile endpoints are available:

- `GET /profile/me` - Get current user's profile
- `PUT /profile/me` - Update current user's profile
- `POST /profile/me` - Create current user's profile (if doesn't exist)
- `DELETE /profile/me` - Delete current user's profile

All endpoints require authentication (Bearer token in Authorization header).

## Troubleshooting

### Issue: Users have no profiles

**Solution:** Run migrations 002 and 003 again.

### Issue: New users still don't get profiles

**Solution:** Check if trigger exists:
```sql
SELECT * FROM pg_trigger WHERE tgname = 'trigger_create_user_profile';
```

If missing, re-run migration 002.

### Issue: Duplicate key errors

**Solution:** The user_id column has a UNIQUE constraint. This means each user can only have one profile. If you get this error, a profile already exists.

## Tracker Tables Migration ⭐ **NEW**

### Running the Tracker Migration

**In Supabase SQL Editor:**
1. Copy contents of `create_trackers_tables.sql`
2. Paste and run

**Creates:**
- `trackers` table - fitness trackers (weight, blood pressure, etc.)
- `tracker_entries` table - data points for each tracker
- Row Level Security (RLS) policies
- Indexes and triggers
- Auto-updating timestamps

**Rollback:**
Run `rollback_trackers_tables.sql` if needed.

**See also:** `TRACKER_MIGRATION_SUMMARY.md` in project root for full documentation.

## Important Notes

### Why SQL Instead of Python for Supabase?

For **Supabase**, always use SQL migrations because:
- ✅ Full control over PostgreSQL features
- ✅ Creates proper Row Level Security (RLS) policies
- ✅ Better for triggers, functions, and constraints
- ✅ Version-controlled and trackable

Python scripts (like `create_tracker_tables.py`) are only for quick local development.

## Additional Resources

See `PROFILE_AUTOCREATE_GUIDE.md` in the project root for complete documentation on the automatic profile creation system.

See `TRACKER_MIGRATION_SUMMARY.md` in the project root for complete tracker implementation documentation.
