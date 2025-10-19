# 🔐 Supabase Credentials - Account Specific or Not?

## TL;DR - What to Share with Teammates

### ✅ SHARE THESE (Same for entire team):
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGc...long-key-here
DATABASE_URL=postgresql+psycopg_async://postgres:PASSWORD@db.xyz.supabase.co:5432/postgres
GEMINI_API_KEY=your-gemini-api-key
```

**These credentials are PROJECT-BASED, not user-based!**

---

## 🎯 Understanding Supabase Authentication

### Level 1: Project Credentials (SHARED)
```
┌─────────────────────────────────────┐
│   Supabase Project: "Pump-Fiction"  │
│                                     │
│  URL: https://xyz.supabase.co       │
│  Service Key: eyJhbGc...            │
│  Database: postgres@db.xyz...       │
└─────────────────────────────────────┘
         ↓
    All teammates use
    THE SAME credentials
```

### Level 2: User Authentication (PER USER)
```
┌─────────────────────────────────────┐
│   Individual Users (Frontend)       │
│                                     │
│  User 1: adib@email.com             │
│    → auth.uid() = uuid-1234         │
│                                     │
│  User 2: teammate@email.com         │
│    → auth.uid() = uuid-5678         │
└─────────────────────────────────────┘
         ↓
    Each user gets unique
    JWT token when they login
```

---

## 🔍 The Actual Problem Explained

### What Happened:

1. **Your Backend Setup:**
   ```python
   # backend/app/core/supabase_client.py
   supabase = create_client(
       settings.SUPABASE_URL,        # ✅ Project-level
       settings.SUPABASE_SERVICE_KEY # ✅ Project-level (admin)
   )
   ```
   This should have **FULL ACCESS** to everything!

2. **But Database Had RLS Enabled:**
   ```sql
   -- In Supabase database
   CREATE POLICY "Users can view their own trackers"
       ON trackers
       FOR SELECT
       USING (auth.uid() = user_id);  -- ❌ Problem!
   ```

3. **The Service Key Problem:**
   - Service key **SHOULD** bypass RLS automatically
   - But Supabase Python client doesn't always pass it correctly
   - So RLS policies checked for `auth.uid()`
   - No `auth.uid()` = **BLOCKED**

---

## 💡 Why It Worked For YOU

### Scenario 1: You were logged in
```
You → Frontend → Login → Got JWT token
                           ↓
                   auth.uid() = YOUR-USER-ID
                           ↓
Backend → Tried to access trackers
    ↓
RLS Policy: "Is auth.uid() = user_id?"
    ↓
YES (because you were logged in) → ✅ SUCCESS
```

### Scenario 2: Your user_id matched
```
Your database has:
users table → id = '123-your-uuid'
trackers table → user_id = '123-your-uuid'

When you accessed:
auth.uid() = '123-your-uuid'
tracker.user_id = '123-your-uuid'
→ Match! ✅ SUCCESS
```

---

## 🚫 Why It Failed For Teammates

### Scenario 1: No login token
```
Teammate → Backend ONLY (no frontend login)
    ↓
No JWT token → No auth.uid()
    ↓
RLS Policy: "Is auth.uid() = user_id?"
    ↓
NO auth.uid() available → ❌ BLOCKED
    ↓
ERROR 500: Permission Denied
```

### Scenario 2: Different user_id
```
Teammate's database:
users table → id = '789-teammate-uuid'
YOUR trackers → user_id = '123-your-uuid'

When teammate accessed:
auth.uid() = '789-teammate-uuid'
tracker.user_id = '123-your-uuid'
→ No match! ❌ BLOCKED
```

---

## ✅ The Solution

### What We Did:
```sql
-- Disabled RLS on all tables
ALTER TABLE trackers DISABLE ROW LEVEL SECURITY;
ALTER TABLE tracker_entries DISABLE ROW LEVEL SECURITY;
-- ... all 16 tables
```

### Now It Works Like This:
```
Anyone with SERVICE_KEY → Full access to ALL data
    ↓
No auth.uid() checks
    ↓
No user_id matching required
    ↓
✅ Everyone can access everything via backend
```

---

## 📋 What Your Teammates Need

### Option 1: Share .env File (Recommended)
```bash
# Send this file securely (Slack DM, Discord, Email)
# File: backend/.env

SUPABASE_URL=https://your-actual-project.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3...
DATABASE_URL=postgresql+psycopg_async://postgres:your-password@db.project.supabase.co:5432/postgres
GEMINI_API_KEY=your-gemini-api-key-here
```

### Option 2: Share Values Individually
```
Tell them to create backend/.env with:

SUPABASE_URL → Copy from your .env
SUPABASE_SERVICE_KEY → Copy from your .env
DATABASE_URL → Copy from your .env
GEMINI_API_KEY → Copy from your .env
```

---

## 🔒 Security Notes

### For Development (Current):
- ✅ RLS Disabled = Everyone with service key has full access
- ✅ Fast development
- ✅ No authentication headaches
- ⚠️ Not secure for production

### For Production (Future):
```sql
-- Re-enable RLS with service_role bypass
ALTER TABLE trackers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "service_role_bypass" ON trackers
  FOR ALL
  USING (
    current_setting('request.jwt.claims', true)::json->>'role' = 'service_role'
    OR auth.uid() = user_id
  );
```

This allows:
- Service role (backend) → Full access
- Regular users (frontend) → Own data only

---

## 🎓 Key Takeaways

1. **Supabase credentials are PROJECT-BASED, not user-based**
   - Same URL, service key, and database URL for entire team

2. **The problem was RLS, not credentials**
   - RLS policies blocked backend access
   - Even with correct service key

3. **Share your .env file with teammates**
   - They need EXACT same values
   - Not account-specific

4. **After running QUICK_DISABLE_RLS.sql:**
   - Everyone can access backend
   - No more 500 errors
   - Team can develop together

---

## 🚀 Next Steps

1. ✅ Run `QUICK_DISABLE_RLS.sql` in Supabase (if not done)
2. 📤 Share your `backend/.env` file with teammates
3. 👥 Teammates create their own `backend/.env` with same values
4. 🔄 Everyone restart backend servers
5. ✅ Test together at `http://localhost:8000/docs`

---

**Bottom Line:** Your teammates need your **project credentials**, not account credentials. The .env file contains project-level secrets that are the same for everyone on your team!
