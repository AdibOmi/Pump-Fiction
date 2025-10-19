# 📨 COPY THIS ENTIRE MESSAGE AND SEND TO YOUR TEAMMATES

---

Hey team! Here's everything you need to run the backend:

## 📦 STEP 1: CREATE .env FILE

1. Navigate to backend folder:
```powershell
cd backend
```

2. Create a file called `.env` (exactly this name, no .txt extension)

3. Paste these contents into the file:

```env
# Supabase info
SUPABASE_URL=https://nuvjjkvcjldrmxsbkibp.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im51dmpqa3Zjamxkcm14c2JraWJwIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDIxNjExNCwiZXhwIjoyMDc1NzkyMTE0fQ.WLg9efBhxtJx8wTv9Ytr9ovg3MfN3xdwz3H5aVZ55ww

# Database connection (PostgreSQL via Supabase)
# Using psycopg3 async driver
DATABASE_URL=postgresql+psycopg_async://postgres:SameenIsSexy69@db.nuvjjkvcjldrmxsbkibp.supabase.co:5432/postgres

# Gemini AI
GEMINI_API_KEY=AIzaSyDqggm5EfuS_7paykWmcLcff9TZFOZKDuk
```

4. Save the file

---

## 🗄️ STEP 2: RUN SQL SCRIPT IN SUPABASE

**You already have access to the Supabase project!**

**Steps:**
1. Login to Supabase Dashboard: https://supabase.com/dashboard
2. Select the **"Pump-Fiction"** project (nuvjjkvcjldrmxsbkibp)
3. Click **SQL Editor** (left sidebar)
4. Click **New Query**
5. In your code editor, open: `backend/QUICK_DISABLE_RLS.sql`
6. Copy the ENTIRE contents
7. Paste into Supabase SQL Editor
8. Click **RUN** button (or Ctrl+Enter)
9. Wait for success message ✅

**What this does:** Disables Row Level Security on all tables so the backend can access everything.

---

## 🚀 STEP 3: INSTALL DEPENDENCIES & RUN BACKEND

```powershell
# Navigate to backend folder
cd backend

# Install Python dependencies
pip install -r requirements.txt

# Run the backend server
python -m uvicorn app.main:app --reload --port 8000
```

---

## ✅ STEP 4: VERIFY IT WORKS

1. Open browser: http://localhost:8000/docs
2. You should see the Swagger API documentation
3. Try any endpoint (e.g., GET /trackers)
4. Should return 200 OK (not 500 error)

---

## 🆘 TROUBLESHOOTING

### Error: "relation does not exist"
→ Make sure you ran the SQL script in Supabase (Step 2)

### Error: 500 Internal Server Error
→ Check your `.env` file exists in `backend/` folder
→ Verify credentials are copied correctly (no extra spaces)

### Error: "Access denied"
→ Restart your backend server (Ctrl+C then run again)
→ Double-check Supabase credentials

### Can't access Supabase Dashboard
→ You should already have access as a team member
→ Check your email for Supabase invitations
→ Login at: https://supabase.com/dashboard

---

## 📚 SUMMARY

What you need:
✅ `.env` file in `backend/` folder (with credentials above)
✅ Run `QUICK_DISABLE_RLS.sql` in Supabase SQL Editor
✅ Install dependencies: `pip install -r requirements.txt`
✅ Start backend: `uvicorn app.main:app --reload --port 8000`

That's it! Let me know if you run into any issues.

---

**Branch:** `features/ruhan/tracker`
**Backend Port:** 8000
**API Docs:** http://localhost:8000/docs
