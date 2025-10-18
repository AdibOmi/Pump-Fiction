# User Profile Auto-Creation Setup Guide

## Problem
The `user_profiles` table was empty because profiles were not being automatically created when new users sign up, and existing users didn't have profiles.

## Solution Overview
This solution implements automatic profile creation through:
1. **Database Trigger**: Automatically creates a profile when a user is created
2. **Migration Script**: Creates profiles for all existing users
3. **Python Sync Script**: Alternative method to sync profiles programmatically

## Implementation Steps

### Step 1: Create Database Trigger (Recommended)

This trigger ensures every new user automatically gets a profile entry.

**Run this SQL in Supabase SQL Editor:**

```sql
-- File: backend/migrations/002_auto_create_user_profile.sql
```

1. Go to Supabase Dashboard
2. Navigate to **SQL Editor**
3. Click **New Query**
4. Copy and paste the contents of `002_auto_create_user_profile.sql`
5. Click **Run**

**What it does:**
- Creates a trigger function `create_user_profile()`
- Sets up a trigger that fires AFTER each user INSERT
- Automatically creates a corresponding `user_profiles` entry with:
  - `user_id` (from the new user)
  - `full_name` (from the new user)
  - `phone_number` (from the new user)

### Step 2: Migrate Existing Users

Create profiles for users who already exist but don't have profiles yet.

**Option A: Using SQL (Recommended)**

**Run this SQL in Supabase SQL Editor:**

```sql
-- File: backend/migrations/003_migrate_existing_users_to_profiles.sql
```

1. Go to Supabase Dashboard → SQL Editor
2. Copy and paste the contents of `003_migrate_existing_users_to_profiles.sql`
3. Click **Run**

This will:
- Find all users without profiles
- Create profile entries for them
- Show a summary of the migration

**Option B: Using Python Script**

```powershell
cd backend
python sync_user_profiles.py
```

This script:
- Connects to Supabase using your service key
- Finds users without profiles
- Creates missing profiles
- Verifies the sync

### Step 3: Verify the Setup

**Check in Supabase Dashboard:**

1. Go to **Table Editor** → `users` table
2. Note the count of users
3. Go to **Table Editor** → `user_profiles` table
4. Verify the count matches

**Or run this SQL:**

```sql
-- Check counts
SELECT 
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM user_profiles) as total_profiles;

-- Find any users without profiles (should be empty)
SELECT u.id, u.email, u.full_name
FROM users u
LEFT JOIN user_profiles up ON u.id = up.user_id
WHERE up.id IS NULL;
```

## How It Works Now

### When a New User Signs Up:

```
1. User submits signup form
   ↓
2. AuthService creates user in Supabase Auth
   ↓
3. User record inserted into 'users' table
   ↓
4. Database trigger 'trigger_create_user_profile' fires
   ↓
5. 'create_user_profile()' function executes
   ↓
6. Profile entry automatically created in 'user_profiles'
   ↓
7. User has both auth account and profile ✅
```

### Data Flow:

```
users table:
├── id (UUID)
├── email
├── full_name
├── phone_number
└── role

        ↓ (trigger)

user_profiles table:
├── id (UUID)
├── user_id (FK → users.id)
├── full_name (copied from users)
├── phone_number (copied from users)
├── gender (NULL initially)
├── weight_kg (NULL initially)
├── height_cm (NULL initially)
└── ... (other fitness fields)
```

## Testing the Setup

### Test 1: Create a New User

```python
# Using the test_auth.py script
cd backend
python test_auth.py
```

Then check if profile was created:

```sql
SELECT u.email, up.id as profile_id, up.full_name
FROM users u
JOIN user_profiles up ON u.id = up.user_id
WHERE u.email = 'testuser@example.com';
```

### Test 2: Test the API

```powershell
cd backend
python test_profile.py
```

Expected output:
```
✅ Profile retrieved successfully!
📊 Profile Data:
   • Email: testuser@example.com
   • Full Name: Test User
   • Phone: +1234567890
```

### Test 3: Frontend Integration

1. Start the backend:
   ```powershell
   cd backend
   python -m app.main
   ```

2. Run the Flutter app:
   ```powershell
   cd frontend
   flutter run
   ```

3. Login or create a new account
4. Navigate to the profile page
5. You should see:
   - Email field populated ✅
   - Name field populated if provided during signup ✅
   - Other fields ready for editing ✅

## Troubleshooting

### Issue: Trigger not working

**Check if trigger exists:**
```sql
SELECT * FROM pg_trigger WHERE tgname = 'trigger_create_user_profile';
```

**Re-create the trigger:**
```sql
-- Drop and recreate
DROP TRIGGER IF EXISTS trigger_create_user_profile ON users;
DROP FUNCTION IF EXISTS create_user_profile();

-- Then run the 002_auto_create_user_profile.sql again
```

### Issue: Existing users still have no profiles

**Run the sync script:**
```powershell
cd backend
python sync_user_profiles.py
```

Or run the SQL migration again:
```sql
-- Run 003_migrate_existing_users_to_profiles.sql
```

### Issue: Duplicate profiles error

This shouldn't happen due to the UNIQUE constraint on `user_id`, but if it does:

```sql
-- Find duplicates
SELECT user_id, COUNT(*)
FROM user_profiles
GROUP BY user_id
HAVING COUNT(*) > 1;

-- Keep only the first profile and delete duplicates
DELETE FROM user_profiles a
USING user_profiles b
WHERE a.id > b.id
  AND a.user_id = b.user_id;
```

### Issue: Permission errors

Make sure RLS (Row Level Security) policies allow profile creation:

```sql
-- Check RLS policies
SELECT * FROM pg_policies WHERE tablename = 'user_profiles';

-- The trigger runs with database privileges, so it should work
-- But if there are issues, temporarily disable RLS:
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;
-- Run sync, then re-enable:
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
```

## Environment Setup

### Required Environment Variables

Make sure your `.env` file has:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_anon_key
SUPABASE_SERVICE_KEY=your_supabase_service_role_key  # For sync script
```

### Python Dependencies

The sync script requires:
```bash
pip install supabase python-dotenv
```

## Maintenance

### Monitoring Profile Creation

You can add logging to track profile creation:

```sql
-- Optional: Add audit table
CREATE TABLE IF NOT EXISTS profile_creation_log (
    id SERIAL PRIMARY KEY,
    user_id UUID,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status TEXT
);

-- Modify the trigger function to log
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_profiles (user_id, full_name, phone_number)
    VALUES (NEW.id, NEW.full_name, NEW.phone_number);
    
    INSERT INTO profile_creation_log (user_id, status)
    VALUES (NEW.id, 'created');
    
    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
    INSERT INTO profile_creation_log (user_id, status)
    VALUES (NEW.id, 'failed: ' || SQLERRM);
    RAISE;
END;
$$ LANGUAGE plpgsql;
```

### Regular Checks

Run this query periodically to ensure sync:

```sql
-- Should return 0 rows
SELECT u.id, u.email
FROM users u
LEFT JOIN user_profiles up ON u.id = up.user_id
WHERE up.id IS NULL;
```

## Next Steps

After completing this setup:

1. ✅ All new users will automatically get profiles
2. ✅ Existing users have been migrated
3. ✅ Profile page will show user data
4. ✅ Users can update their profiles

You can now:
- Test the profile page in the Flutter app
- Remove debug logging from the frontend code
- Add more fields to the profile as needed
- Implement profile image upload
- Add profile completeness indicators

## Files Created/Modified

### New Files:
1. `backend/migrations/002_auto_create_user_profile.sql` - Trigger to auto-create profiles
2. `backend/migrations/003_migrate_existing_users_to_profiles.sql` - Migrate existing users
3. `backend/sync_user_profiles.py` - Python script to sync profiles
4. `PROFILE_AUTOCREATE_GUIDE.md` - This guide

### Existing Functionality:
- No changes needed to application code
- The trigger handles everything automatically
- Frontend code from previous fix still applies

## Summary

✅ **Problem Solved**: User profiles are now automatically created
✅ **Trigger Installed**: Every new user gets a profile
✅ **Existing Users Migrated**: All current users now have profiles
✅ **Frontend Ready**: Profile page will display user data
✅ **Maintainable**: Automatic process requires no manual intervention
