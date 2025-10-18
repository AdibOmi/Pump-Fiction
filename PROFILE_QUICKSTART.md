# 🎯 User Profile Auto-Creation - Quick Start Guide

## Problem Summary
- ✗ `user_profiles` table was empty
- ✗ New users weren't getting profiles automatically
- ✗ Profile page couldn't display user data

## Solution Summary
✅ **Database trigger** that auto-creates profiles when users sign up  
✅ **Migration script** to create profiles for existing users  
✅ **Python utility** for easy syncing and verification  

---

## 🚀 Quick Setup (3 Steps)

### Option A: Interactive Setup (Recommended for First Time)

```powershell
cd backend
python setup_profile_autocreate.py
```

This will guide you through each step with instructions.

### Option B: Manual Setup

#### Step 1️⃣: Create the Trigger

1. Open **Supabase Dashboard** → **SQL Editor**
2. Copy and paste: `backend/migrations/002_auto_create_user_profile.sql`
3. Click **Run**

#### Step 2️⃣: Migrate Existing Users

**Choose one:**

**SQL Method:**
- In **SQL Editor**, run: `backend/migrations/003_migrate_existing_users_to_profiles.sql`

**Python Method:**
```powershell
cd backend
python sync_user_profiles.py
```

#### Step 3️⃣: Verify

**In SQL Editor, run:**
```sql
SELECT 
    (SELECT COUNT(*) FROM users) as users,
    (SELECT COUNT(*) FROM user_profiles) as profiles;
```

Both numbers should match! ✓

---

## 🧪 Testing

### Test 1: Create a New User
```powershell
cd backend
python test_auth.py
```
✅ Should automatically create a profile

### Test 2: Check Profile API
```powershell
python test_profile.py
```
✅ Should see email, name, and other user data

### Test 3: Flutter App
```powershell
cd frontend
flutter run
```
✅ Profile page should show existing user data

---

## 📁 Files Created

| File | Purpose |
|------|---------|
| `migrations/002_auto_create_user_profile.sql` | Trigger to auto-create profiles |
| `migrations/003_migrate_existing_users_to_profiles.sql` | Migrate existing users |
| `sync_user_profiles.py` | Python script to sync profiles |
| `setup_profile_autocreate.py` | Interactive setup wizard |
| `PROFILE_AUTOCREATE_GUIDE.md` | Complete documentation |

---

## 🔧 How It Works

```
┌─────────────────┐
│  User Signs Up  │
└────────┬────────┘
         │
         ▼
┌─────────────────────┐
│  Record in 'users'  │
│  table is created   │
└────────┬────────────┘
         │
         │ ◄─── Database Trigger Fires
         │
         ▼
┌──────────────────────────┐
│  create_user_profile()   │
│  function executes       │
└────────┬─────────────────┘
         │
         ▼
┌────────────────────────────┐
│  Profile created in        │
│  'user_profiles' table     │
└────────────────────────────┘
```

**Result:** Every user automatically has a profile! ✨

---

## ⚠️ Troubleshooting

### "No profiles showing in Flutter app"

**Check:**
1. Backend is running: `python -m app.main`
2. User is logged in
3. Run sync script: `python sync_user_profiles.py`

### "Trigger not working for new users"

**Re-run the trigger SQL:**
```sql
-- In Supabase SQL Editor
-- Copy/paste: 002_auto_create_user_profile.sql
```

### "Existing users still have no profiles"

**Run the migration:**
```powershell
python sync_user_profiles.py
```

Or run SQL: `003_migrate_existing_users_to_profiles.sql`

---

## 📊 Verification Queries

### Check trigger exists:
```sql
SELECT tgname FROM pg_trigger 
WHERE tgname = 'trigger_create_user_profile';
```

### Find users without profiles:
```sql
SELECT u.email FROM users u
LEFT JOIN user_profiles up ON u.id = up.user_id
WHERE up.id IS NULL;
```
*(Should return 0 rows)*

### Count comparison:
```sql
SELECT 
    (SELECT COUNT(*) FROM users) as users,
    (SELECT COUNT(*) FROM user_profiles) as profiles;
```
*(Should be equal)*

---

## ✅ Success Checklist

- [ ] Ran `002_auto_create_user_profile.sql`
- [ ] Ran `003_migrate_existing_users_to_profiles.sql` OR `sync_user_profiles.py`
- [ ] Verified trigger exists in database
- [ ] Verified all users have profiles
- [ ] Tested creating a new user
- [ ] Tested profile API endpoints
- [ ] Tested Flutter profile page

---

## 🎓 What's Next?

Now that profiles are working:

1. **Frontend is ready** - Profile page will show user data
2. **Auto-creation enabled** - New users get profiles automatically
3. **No manual work** - Everything happens automatically

You can now focus on:
- Adding more profile fields
- Implementing profile image upload
- Adding profile completion indicators
- Building personalized features

---

## 📚 Documentation

- **Complete Guide**: `PROFILE_AUTOCREATE_GUIDE.md`
- **Frontend Fix**: `PROFILE_FIX_GUIDE.md`
- **Migrations**: `backend/migrations/README.md`

---

## 🆘 Need Help?

1. Check `PROFILE_AUTOCREATE_GUIDE.md` for detailed troubleshooting
2. Run verification queries to diagnose issues
3. Check backend logs when testing
4. Verify environment variables are set correctly

---

**Last Updated**: October 19, 2025  
**Status**: ✅ Ready for Production
