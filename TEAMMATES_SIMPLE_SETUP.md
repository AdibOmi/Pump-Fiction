# ⚡ ULTRA SIMPLE - What Your Teammates Need

Since they're already in your Supabase project, they only need:

## 1️⃣ The `.env` File Contents

Send them this:

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

Tell them: **"Create a file called `.env` in the `backend/` folder and paste this in"**

---

## 2️⃣ Run SQL Script

Tell them:

**"Go to Supabase Dashboard → SQL Editor → Run the `backend/QUICK_DISABLE_RLS.sql` file"**

(They already have Supabase access, so this is easy!)

---

## 3️⃣ Start Backend

Tell them:

```bash
cd backend
pip install -r requirements.txt
python -m uvicorn app.main:app --reload --port 8000
```

---

## ✅ That's It!

They need:
1. ✅ `.env` file with credentials (from you)
2. ✅ Run SQL script in Supabase (they have access)
3. ✅ Start backend

**Total time: 5 minutes**

---

## 📨 Quick Copy-Paste Message:

```
Hey team! Quick setup to run the backend:

1. Create backend/.env file with these credentials:
[Paste the .env contents above]

2. Login to Supabase → SQL Editor → Run backend/QUICK_DISABLE_RLS.sql

3. Run backend:
cd backend
pip install -r requirements.txt
python -m uvicorn app.main:app --reload --port 8000

Test at: http://localhost:8000/docs

Any issues, let me know!
```

---

**That's literally all they need since they're already in your Supabase project!** 🎉
