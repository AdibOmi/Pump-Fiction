# Supabase Database Setup Guide

## Overview
This guide will help you migrate from SQLite to Supabase PostgreSQL for storing AI chat sessions and messages.

---

## Step 1: Get Your Database Connection String

1. **Go to your Supabase Dashboard:**
   - URL: https://supabase.com/dashboard/project/nuvjjkvcjldrmxsbkibp

2. **Navigate to Database Settings:**
   - Click on **Settings** (left sidebar)
   - Click on **Database**

3. **Get Connection String:**
   - Scroll down to **Connection String** section
   - Select the **URI** tab
   - Copy the connection string

4. **Your connection string looks like:**
   ```
   postgresql://postgres.nuvjjkvcjldrmxsbkibp:[YOUR-PASSWORD]@aws-0-us-east-1.pooler.supabase.com:6543/postgres
   ```

5. **Replace `[YOUR-PASSWORD]`** with your actual database password
   - If you don't know it, go to **Settings > Database > Reset Database Password**

---

## Step 2: Update Your .env File

Add this line to your `backend/.env` file:

```env
DATABASE_URL=postgresql+asyncpg://postgres.nuvjjkvcjldrmxsbkibp:[YOUR-PASSWORD]@aws-0-us-east-1.pooler.supabase.com:6543/postgres
```

**IMPORTANT:** Change `postgresql://` to `postgresql+asyncpg://` for async SQLAlchemy support!

### Example .env file:
```env
# Supabase info
SUPABASE_URL=https://nuvjjjkvcjldrmxsbkibp.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Database connection (NEW - ADD THIS)
DATABASE_URL=postgresql+asyncpg://postgres.nuvjjkvcjldrmxsbkibp:YOUR_PASSWORD_HERE@aws-0-us-east-1.pooler.supabase.com:6543/postgres

# Gemini AI
GEMINI_API_KEY=AIzaSyDqggm5EfuS_7paykWmcLcff9TZFOZKDuk
```

---

## Step 3: Create Tables in Supabase

You have **TWO OPTIONS**:

### Option A: Use Python Script (Recommended)

```bash
cd backend
python init_db.py
```

This will automatically create all tables in Supabase.

### Option B: Use Supabase SQL Editor

1. Go to **SQL Editor** in your Supabase Dashboard
2. Click **New Query**
3. Copy and paste the contents of `backend/supabase_migration.sql`
4. Click **Run**

This creates:
- `ai_chat_sessions` table
- `ai_chat_messages` table
- Indexes for performance
- Row Level Security (RLS) policies for data protection

---

## Step 4: Install Required Dependencies

Make sure you have the PostgreSQL drivers:

```bash
cd backend
pip install -r requirements.txt
```

**Note for Windows users:** `asyncpg` requires C++ build tools. If it fails to install, that's OK - `psycopg2-binary` is already installed as a fallback and will work fine.

---

## Step 5: Test the Connection

Run this test:

```bash
cd backend
python -c "from app.core.database import engine; import asyncio; asyncio.run(engine.connect())"
```

If successful, you should see no errors!

---

## Step 6: Start Your Server

```bash
cd backend
python -m uvicorn app.main:app --reload --port 8000
```

---

## What Tables Were Created?

### `ai_chat_sessions`
Stores chat conversation sessions for each user.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| user_id | UUID | Foreign key to Supabase auth.users |
| title | VARCHAR(255) | Session title |
| context_snapshot | JSONB | Additional context data |
| last_message_at | TIMESTAMP | Last activity timestamp |
| is_archived | BOOLEAN | Archive status |
| created_at | TIMESTAMP | Creation time |
| updated_at | TIMESTAMP | Last update time |

### `ai_chat_messages`
Stores individual messages within sessions.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| session_id | UUID | Foreign key to ai_chat_sessions |
| role | VARCHAR(20) | user/assistant/system |
| content | TEXT | Message text |
| citations | JSONB | Source citations (future use) |
| tokens_used | INTEGER | AI token usage |
| model_version | VARCHAR(50) | AI model used |
| safety_flag | BOOLEAN | Content safety flag |
| disclaimer_shown | BOOLEAN | Medical disclaimer shown |
| created_at | TIMESTAMP | Creation time |

---

## Security Features

- **Row Level Security (RLS)** enabled
- Users can only access their own chat sessions and messages
- Backend uses service role key to bypass RLS when needed
- All user data is isolated and secure

---

## Troubleshooting

### Connection Errors
- Check your database password is correct
- Ensure you changed `postgresql://` to `postgresql+asyncpg://`
- Verify your Supabase project is not paused

### Table Creation Errors
- Make sure you have the correct permissions
- Try using the SQL Editor method instead
- Check Supabase logs for detailed errors

### Import Errors
- Run `pip install asyncpg psycopg2-binary`
- Restart your terminal after installing

---

## Next Steps

Once everything is set up:

1. Test authentication: `POST /auth/login`
2. Create a chat session: `POST /ai-chat/sessions`
3. Send a message: `POST /ai-chat/sessions/{session_id}/messages`

All data will now be stored in Supabase PostgreSQL!
