# Pump-Fiction Backend - Role-Based Authentication with Supabase

## Overview

This backend implements role-based authentication using Supabase as the authentication provider. The system supports four user roles with different permission levels.

## User Roles

| Role | Description | Permissions |
|------|-------------|-------------|
| `normal_user` | Default role for new users | Basic app features, view content |
| `trainer` | Fitness trainers | Normal user + create/manage training programs |
| `seller` | Product sellers | Normal user + create/manage stores and products |
| `admin` | System administrators | Full control, approve role applications, manage users |

## Architecture

- **Authentication**: Supabase Auth (JWT tokens)
- **Role Management**: Backend SQLite database + Supabase metadata
- **Security**: Backend validates all requests using service key
- **Frontend**: Never holds secret keys, only uses access tokens

## Environment Setup

Create `.env` file in `backend/` folder:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_SERVICE_KEY=your_service_role_key
```

## Installation

```bash
cd backend
pip install -r requirements.txt

# Initialize database tables
python init_db.py

# Start server
python -m uvicorn app.main:app --reload --port 8000
```

## API Endpoints

### 🔓 Public Endpoints (No Authentication Required)

#### 1. Signup
```http
POST /auth/signup
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securepassword",
  "full_name": "John Doe"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGc...",
  "refresh_token": "eyJhbGc...",
  "token_type": "bearer",
  "expires_in": 3600,
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "full_name": "John Doe",
    "role": "normal_user"
  }
}
```

#### 2. Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securepassword"
}
```

**Response:** Same as signup

#### 3. Refresh Token
```http
POST /auth/refresh
Content-Type: application/json

{
  "refresh_token": "eyJhbGc..."
}
```

### 🔒 Protected Endpoints (Require Authentication)

**Add JWT token to all protected endpoints:**
```http
Authorization: Bearer <access_token>
```

#### 4. Get Current User Profile
```http
GET /auth/me
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "id": "uuid",
  "email": "user@example.com",
  "full_name": "John Doe",
  "role": "normal_user",
  "created_at": "2025-10-12T10:00:00Z"
}
```

#### 5. Logout
```http
POST /auth/logout
Authorization: Bearer <access_token>
```

#### 6. Update Profile
```http
PUT /auth/me
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "full_name": "Jane Doe"
}
```

### 👥 Role Application Endpoints

#### 7. Apply for Trainer/Seller Role
```http
POST /auth/apply-role
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "requested_role": "trainer",  // or "seller"
  "reason": "I am a certified personal trainer with 5 years of experience",
  "qualifications": "NASM CPT, ACE Certified"
}
```

**Response:**
```json
{
  "id": "application_uuid",
  "user_id": "user_uuid",
  "user_email": "user@example.com",
  "user_name": "John Doe",
  "requested_role": "trainer",
  "current_role": "normal_user",
  "status": "pending",
  "reason": "...",
  "qualifications": "...",
  "created_at": "2025-10-12T10:00:00Z"
}
```

**Rules:**
- Cannot apply for `admin` role
- Only one pending application at a time
- Cannot apply for role you already have

#### 8. View My Applications
```http
GET /auth/my-applications
Authorization: Bearer <access_token>
```

### 🛡️ Admin-Only Endpoints

#### 9. View Pending Applications
```http
GET /auth/admin/applications/pending
Authorization: Bearer <admin_access_token>
```

#### 10. View All Applications
```http
GET /auth/admin/applications
Authorization: Bearer <admin_access_token>
```

#### 11. Approve/Reject Application
```http
POST /auth/admin/applications/review
Authorization: Bearer <admin_access_token>
Content-Type: application/json

{
  "application_id": "application_uuid",
  "decision": "approved",  // or "rejected"
  "admin_notes": "Verified certifications, approved"
}
```

**What happens on approval:**
1. Application status updated to `approved`
2. User's role automatically upgraded
3. User gains new permissions immediately

### 🎯 Role-Protected Example Endpoints

#### Trainer Dashboard (Trainers + Admins only)
```http
GET /users/trainer/dashboard
Authorization: Bearer <trainer_or_admin_token>
```

#### Seller Dashboard (Sellers + Admins only)
```http
GET /users/seller/dashboard
Authorization: Bearer <seller_or_admin_token>
```

#### Admin Users List (Admins only)
```http
GET /users/admin/users
Authorization: Bearer <admin_token>
```

## Using Authentication in Your Endpoints

### Example 1: Require Any Authenticated User
```python
from fastapi import Depends
from app.core.dependencies import get_current_user

@router.get("/my-workouts")
async def get_workouts(current_user: dict = Depends(get_current_user)):
    return {"user": current_user["email"], "workouts": [...]}
```

### Example 2: Require Specific Role
```python
from app.core.dependencies import require_trainer

@router.post("/training-programs")
async def create_program(
    program_data: dict,
    trainer: dict = Depends(require_trainer)
):
    # Only trainers and admins can access
    return {"created_by": trainer["email"]}
```

### Example 3: Require Multiple Roles
```python
from app.core.dependencies import require_role
from app.schemas.auth_schema import UserRole

@router.get("/content-management")
async def manage_content(
    current_user: dict = Depends(require_role([UserRole.ADMIN, UserRole.TRAINER]))
):
    # Only admins and trainers can access
    return {"manager": current_user["role"]}
```

### Example 4: Optional Authentication
```python
from app.core.dependencies import get_optional_user

@router.get("/workouts")
async def list_workouts(user: dict = Depends(get_optional_user)):
    if user:
        # Authenticated user - show personalized content
        return {"personalized": True, "user": user["email"]}
    else:
        # Guest - show public content only
        return {"personalized": False, "public_workouts": [...]}
```

## Error Responses

### 401 Unauthorized (Invalid/Missing Token)
```json
{
  "detail": "Invalid authentication credentials"
}
```

### 403 Forbidden (Insufficient Permissions)
```json
{
  "detail": "Admin access required"
}
```

### 400 Bad Request
```json
{
  "detail": "You already have a pending application"
}
```

## Security Best Practices

1. **Never expose Supabase service key** in frontend
2. **Always validate tokens** on backend before processing requests
3. **Use HTTPS** in production
4. **Set appropriate token expiry** (default: 60 minutes)
5. **Refresh tokens** before they expire
6. **Logout users** when they're done

## Testing with Swagger UI

Visit `http://127.0.0.1:8000/docs` for interactive API documentation.

1. **Signup/Login** to get access token
2. Click **"Authorize"** button at top right
3. Enter: `Bearer <your_access_token>`
4. Now you can test all protected endpoints

## Supabase Setup Required

### 1. Create Tables in Supabase

Run this SQL in Supabase SQL Editor:

```sql
-- Users table (stores additional user info)
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'normal_user',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read their own data
CREATE POLICY "Users can view own data" ON users
  FOR SELECT USING (auth.uid() = id);

-- Policy: Service role can do everything
CREATE POLICY "Service role has full access" ON users
  FOR ALL USING (auth.role() = 'service_role');
```

### 2. Enable Email Auth in Supabase

1. Go to Authentication > Providers
2. Enable Email provider
3. Configure email templates (optional)

## Next Steps

- [ ] Add password reset functionality
- [ ] Implement email verification
- [ ] Add OAuth providers (Google, Apple, etc.)
- [ ] Create endpoints for trainers to manage programs
- [ ] Create endpoints for sellers to manage stores
- [ ] Add user profile photos
- [ ] Implement rate limiting

## Support

For questions or issues, contact the development team.
