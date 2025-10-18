# Tracker Backend Integration - Quick Start Guide

## ✅ Fixed: UUID Type Issue

The SQL migration has been updated to use `UUID` for `user_id` (matching your Supabase schema).

## 🚀 How to Deploy

### Step 1: Run SQL Migration in Supabase

1. **Open Supabase Dashboard**
   - Go to https://supabase.com/dashboard
   - Select your project

2. **Open SQL Editor**
   - Click "SQL Editor" in left sidebar
   - Click "New Query"

3. **Copy & Run Migration**
   - Open `backend/migrations/create_trackers_tables.sql`
   - Copy **ALL** the contents
   - Paste into Supabase SQL Editor
   - Click **"Run"** (or Ctrl+Enter)

4. **Verify Success**
   - You should see: ✅ "Success. No rows returned"
   - Go to **Table Editor** → confirm `trackers` and `tracker_entries` tables exist

### Step 2: Start Your Backend

```bash
cd backend
uvicorn app.main:app --reload
```

### Step 3: Test the App

```bash
cd frontend
flutter run
```

Navigate to: **Fitness → Progress → Your Trackers**

## 🔍 What Changed

### Fixed Issues
- ✅ Changed `user_id` from `INTEGER` to `UUID` in SQL migration
- ✅ Updated Python models to use `UUID` type
- ✅ Fixed RLS policies to compare UUIDs correctly

### Database Tables Created

**`trackers`**
- `id` - BIGSERIAL (auto-increment)
- `user_id` - UUID (links to users table)
- `name` - VARCHAR(255) - e.g., "Body Weight"
- `unit` - VARCHAR(50) - e.g., "kg", "bpm"
- `goal` - DOUBLE PRECISION (optional)
- `created_at`, `updated_at` - Timestamps

**`tracker_entries`**
- `id` - BIGSERIAL (auto-increment)
- `tracker_id` - BIGINT (links to trackers)
- `date` - TIMESTAMP WITH TIME ZONE
- `value` - DOUBLE PRECISION
- `created_at`, `updated_at` - Timestamps

**Security Features:**
- ✅ Row Level Security (RLS) enabled
- ✅ Users can only see/modify their own trackers
- ✅ Cascade delete (deleting tracker removes entries)
- ✅ Auto-updating timestamps

## 🎯 API Endpoints Available

All require authentication (`Authorization: Bearer <token>`)

**Trackers:**
- `GET /trackers` - List all user's trackers
- `POST /trackers` - Create tracker
- `GET /trackers/{id}` - Get specific tracker
- `PUT /trackers/{id}` - Update tracker
- `DELETE /trackers/{id}` - Delete tracker

**Entries:**
- `GET /trackers/{id}/entries` - List entries
- `POST /trackers/{id}/entries` - Add entry
- `PUT /trackers/{id}/entries/{entry_id}` - Update entry
- `DELETE /trackers/{id}/entries/{entry_id}` - Delete entry

## 🐛 Troubleshooting

### "relation already exists" Error
Tables already created. To recreate:
1. Run `backend/migrations/rollback_trackers_tables.sql` first
2. Then run the create script again

### "foreign key constraint cannot be implemented"
This error is **fixed** now. The migration uses UUID correctly.

### Backend Shows "User not found" Errors
Make sure you're logged in with a valid token in the Flutter app.

### Frontend Shows Empty List
- Check backend is running on correct port
- Verify API base URL in `frontend/lib/core/constants/api_constants.dart`
- Check Flutter console for error messages

## 📚 Full Documentation

See [TRACKER_MIGRATION_SUMMARY.md](TRACKER_MIGRATION_SUMMARY.md) for complete documentation.

---

**That's it!** Your tracker feature now has a complete backend with cloud storage. 🎉
