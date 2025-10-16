# Supabase Configuration Fixes

## Issues Encountered

### 1. RLS (Row Level Security) Blocking Inserts
**Problem:** Service role key not bypassing RLS policies
**Error:** `new row violates row-level security policy for table "users"`

### 2. Email Confirmation Causing Null Tokens
**Problem:** Supabase email confirmation enabled by default, returns null session
**Error:** `access_token: Input should be a valid string [input_value=None]`

---

## Quick Fixes (Choose Your Approach)

### Fix 1: Disable RLS (For Development)

Run this in **Supabase SQL Editor**:

```sql
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
```

### Fix 2: Disable Email Confirmation (For Development)

1. Go to Supabase Dashboard
2. Navigate to: **Authentication → Providers**
3. Click on **Email** provider
4. Find **"Confirm email"** toggle
5. **Turn it OFF**
6. Click **Save**

---

## What Was Fixed in the Code

### 1. Updated `TokenResponse` Schema
Made tokens optional to handle email confirmation flow:

```python
class TokenResponse(BaseModel):
    access_token: Optional[str] = None  # Now optional
    refresh_token: Optional[str] = None  # Now optional
    token_type: str = "bearer"
    expires_in: int
    user: dict
    message: Optional[str] = None  # For confirmation messages
```

### 2. Updated `auth_service.signup()` Method
Now handles both scenarios:
- **Email confirmation disabled**: Returns tokens immediately
- **Email confirmation enabled**: Returns message asking user to check email

---

## Recommended Configuration for Development

1. **Disable RLS**: 
   ```sql
   ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
   ```

2. **Disable Email Confirmation**:
   - Dashboard → Authentication → Providers → Email
   - Turn OFF "Confirm email"

3. **Restart Backend**:
   ```bash
   # Stop uvicorn (Ctrl+C) and restart
   python -m uvicorn app.main:app --reload --port 8000
   ```

---

## Testing After Fixes

### Test Signup
```bash
curl -X 'POST' \
  'http://localhost:8000/auth/signup' \
  -H 'Content-Type: application/json' \
  -d '{
  "email": "test@example.com",
  "password": "securepassword123",
  "full_name": "Test User"
}'
```

**Expected Response:**
```json
{
  "access_token": "eyJhbGc...",
  "refresh_token": "...",
  "token_type": "bearer",
  "expires_in": 3600,
  "user": {
    "id": "uuid-here",
    "email": "test@example.com",
    "full_name": "Test User",
    "role": "normal_user"
  }
}
```

### Test Login
```bash
curl -X 'POST' \
  'http://localhost:8000/auth/login' \
  -H 'Content-Type: application/json' \
  -d '{
  "email": "test@example.com",
  "password": "securepassword123"
}'
```

### Test Protected Endpoint
```bash
curl -X 'GET' \
  'http://localhost:8000/auth/me' \
  -H 'Authorization: Bearer YOUR_ACCESS_TOKEN_HERE'
```

---

## For Production Setup

When you're ready to deploy:

1. **Re-enable RLS** with proper policies:
   ```sql
   ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
   
   CREATE POLICY "service_role_bypass" ON public.users
     FOR ALL
     USING (
       current_setting('request.jwt.claims', true)::json->>'role' = 'service_role'
       OR current_setting('request.jwt.claims', true) IS NULL
     );
   ```

2. **Re-enable Email Confirmation** and implement:
   - Email verification flow
   - Password reset flow
   - Email templates in Supabase

3. **Add Additional Security**:
   - Rate limiting
   - CORS configuration
   - Token refresh logic
   - Session management

---

## Diagnostic Tools

Run this to test your Supabase connection:
```bash
cd backend
python test_supabase_connection.py
```

This will verify:
- ✅ Service key is correct
- ✅ Can connect to Supabase
- ✅ Can read from users table
- ✅ Can insert into users table (checks RLS)

---

## Summary

**To get signup/login working NOW:**
1. Run: `ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;` in Supabase SQL Editor
2. Disable email confirmation in Supabase Dashboard (Auth → Providers → Email)
3. Restart your backend server
4. Try signup again - should work!

The code is now updated to handle both scenarios gracefully.
