# 🎯 COMPLETE CHECKLIST - What to Share with Teammates

## ✅ MUST SHARE (Required for Backend to Work)

### 1. `.env` File Contents ⭐ **MOST IMPORTANT**
```bash
Location: backend/.env

Share the ENTIRE file contents via:
- Slack DM
- Discord DM
- Email
- Password-protected document
```

**They need to create `backend/.env` on their machine with EXACT same values**

---

### 2. Supabase SQL Script (Already in Git) ✅
```
File: backend/QUICK_DISABLE_RLS.sql

Status: Already pushed to Git
Action: Tell them to run it in Supabase SQL Editor
```

**Instructions for teammates:**
1. Go to Supabase Dashboard: https://supabase.com
2. Select the project (they'll need login access - see #3)
3. Click SQL Editor → New Query
4. Copy contents of `backend/QUICK_DISABLE_RLS.sql`
5. Paste and Run

---

### 3. Supabase Dashboard Access 🔐
```
They need login credentials to:
https://supabase.com/dashboard

Options:
A) Share your Supabase account login (email + password)
B) Invite them as team members to the project
```

**To invite teammates to Supabase:**
1. Go to Supabase Dashboard
2. Click your project
3. Settings → Team Settings
4. Click "Invite"
5. Enter their email addresses
6. They'll get invitation email

**OR just share your Supabase login credentials directly**

---

### 4. Google Gemini API Key (Already in .env) ✅
```
Already included in the .env file
```

---

## 📋 OPTIONAL BUT HELPFUL

### 5. GitHub Repository Access
```
Repository: https://github.com/AdibOmi/Pump-Fiction
Branch: features/ruhan/tracker

If they don't have access:
- Add them as collaborators
- Settings → Collaborators → Add people
```

---

### 6. Installation Instructions
```
Already in repository:
- backend/README.md
- README.md

Make sure they read these for setup steps
```

---

## 🚀 COMPLETE SHARING TEMPLATE

Copy and send this to your teammates:

```
Hey team! Here's everything you need to run the backend:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 1. CREATE .env FILE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Create a file called `.env` in the `backend/` folder with these contents:

[PASTE YOUR ACTUAL .env CONTENTS HERE]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🗄️ 2. RUN SQL SCRIPT IN SUPABASE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Supabase Login:
Email: [YOUR SUPABASE EMAIL]
Password: [YOUR SUPABASE PASSWORD]

OR if you invited them:
→ Check your email for Supabase invitation

Steps:
1. Login to: https://supabase.com/dashboard
2. Select project: Pump-Fiction
3. SQL Editor → New Query
4. Open file: backend/QUICK_DISABLE_RLS.sql
5. Copy everything → Paste → Run

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 3. RUN BACKEND
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

cd backend
python -m uvicorn app.main:app --reload --port 8000

Test: http://localhost:8000/docs

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ VERIFY IT WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- Open browser: http://localhost:8000/docs
- Try any endpoint
- Should see 200 OK responses (not 500)

If issues, let me know!
```

---

## 📝 QUICK COPY-PASTE CHECKLIST

### What I Need to Share:
- [ ] `.env` file contents (via secure channel)
- [ ] Supabase dashboard login credentials OR invite them
- [ ] Instructions to run `QUICK_DISABLE_RLS.sql`
- [ ] GitHub repository access (if they don't have it)
- [ ] This message with complete setup steps

### What They Need to Do:
- [ ] Create `backend/.env` file
- [ ] Paste credentials into `.env`
- [ ] Login to Supabase
- [ ] Run SQL script in Supabase SQL Editor
- [ ] Pull latest code from Git
- [ ] Install Python dependencies: `pip install -r requirements.txt`
- [ ] Start backend: `uvicorn app.main:app --reload --port 8000`
- [ ] Test: http://localhost:8000/docs

---

## 🔍 VERIFY YOU'RE SHARING THE RIGHT THING

Before sharing, run this command to see your .env file:

```powershell
# Show your .env file contents
cd backend
Get-Content .env
```

Make sure it has:
✅ SUPABASE_URL=https://...
✅ SUPABASE_SERVICE_KEY=eyJhbGc...
✅ DATABASE_URL=postgresql+psycopg_async://...
✅ GEMINI_API_KEY=...

---

## 🎯 THAT'S IT!

They literally need:
1. **.env file contents** (from you)
2. **Supabase dashboard access** (login or invitation)
3. **Run QUICK_DISABLE_RLS.sql** (already in Git)

Everything else is already in the Git repository!
