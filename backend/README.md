# Pump Fiction Backend (FastAPI)

FastAPI backend for Pump Fiction fitness tracking app with AI chatbot integration.

## Quick Start

### 1. Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 2. Configure Environment

Copy the example environment file and fill in your credentials:

```bash
cp .env.example .env
```

Edit `.env` with your actual values:
- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_SERVICE_KEY` - Your Supabase service role key
- `DATABASE_URL` - Your Supabase PostgreSQL connection string
- `GEMINI_API_KEY` - Your Google Gemini API key

### 3. Start Server

**IMPORTANT:** Must run from the `backend` directory:

```bash
cd backend
python -m uvicorn app.main:app --reload --port 8000
```

### 4. Access API

- **API:** http://127.0.0.1:8000
- **Interactive Docs (Swagger):** http://127.0.0.1:8000/docs
- **Alternative Docs (ReDoc):** http://127.0.0.1:8000/redoc

---

## Features

- ✅ **User Authentication** - Supabase Auth integration
- ✅ **AI Chatbot** - Google Gemini-powered fitness coach
- ✅ **Session Management** - Persistent chat conversations
- ✅ **Supabase PostgreSQL** - Cloud database storage
- ✅ **Role-based Access** - User roles and permissions
- ✅ **RESTful API** - FastAPI with automatic docs

---

## API Endpoints

### Authentication
- `POST /auth/signup` - Register new user
- `POST /auth/login` - Login user
- `POST /auth/refresh` - Refresh access token
- `POST /auth/logout` - Logout user

### AI Chat
- `POST /ai-chat/sessions` - Create chat session
- `GET /ai-chat/sessions` - List user sessions
- `GET /ai-chat/sessions/{id}` - Get session with messages
- `POST /ai-chat/sessions/{id}/messages` - Send message to AI
- `POST /ai-chat/sessions/{id}/archive` - Archive session
- `DELETE /ai-chat/sessions/{id}` - Delete session

### Users
- `GET /users` - List users
- `GET /users/me` - Get current user profile
- `PUT /users/{id}` - Update user

---

## Documentation

Complete documentation is available in the [`docs/`](docs/) folder:

### Getting Started
- **[Setup Guide](docs/SUPABASE_SETUP.md)** - Complete Supabase setup instructions
- **[Migration Guide](docs/MIGRATION_COMPLETE.md)** - Database migration summary
- **[Git Configuration](docs/GITIGNORE_INFO.md)** - Git ignore and security best practices

### API Documentation
- **[API Testing Guide](docs/API_TESTING_GUIDE.md)** - How to test all API endpoints
- **[Authentication](docs/AUTH_README.md)** - Authentication system documentation
- **[Posts API](docs/POSTS_API.md)** - Posts and social features

### Integration
- **[Frontend Integration](docs/FRONTEND_INTEGRATION.md)** - How to connect Flutter app
- **[Implementation Summary](docs/IMPLEMENTATION_SUMMARY.md)** - Technical implementation details

### Troubleshooting
- **[Supabase Fixes](docs/SUPABASE_FIXES.md)** - Common Supabase issues and solutions

---

## Project Structure

```
backend/
├── app/
│   ├── controllers/       # API route handlers
│   ├── core/             # Core configuration
│   ├── models/           # Database models
│   ├── repositories/     # Data access layer
│   ├── schemas/          # Pydantic schemas
│   ├── services/         # Business logic
│   ├── main.py           # FastAPI application
│   └── routers.py        # Route configuration
├── docs/                 # Documentation
├── .env.example          # Environment template
├── .gitignore           # Git ignore rules
├── requirements.txt      # Python dependencies
└── README.md            # This file
```

---

## Tech Stack

- **FastAPI** - Modern web framework
- **SQLAlchemy** - ORM for database
- **Pydantic** - Data validation
- **Supabase** - PostgreSQL database + Auth
- **Google Gemini** - AI chat integration
- **Uvicorn** - ASGI server

---

## Development

### Running Tests
```bash
pytest
```

### Database Migrations
```bash
python init_db.py
```

### Code Quality
```bash
# Format code
black .

# Lint code
flake8 .

# Type checking
mypy .
```

---

## Environment Variables

Required environment variables (see `.env.example`):

| Variable | Description |
|----------|-------------|
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_SERVICE_KEY` | Supabase service role key |
| `DATABASE_URL` | PostgreSQL connection string |
| `GEMINI_API_KEY` | Google Gemini API key |

---

## Security Notes

⚠️ **NEVER commit the following:**
- `.env` file (contains secrets)
- Database files (`*.db`)
- API keys or passwords

✅ **Safe to commit:**
- `.env.example` (template)
- Source code (`.py` files)
- Documentation

See [Git Configuration Guide](docs/GITIGNORE_INFO.md) for more details.

---

## Troubleshooting

### Server won't start
- Make sure you're in the `backend` directory
- Check `.env` file exists and has correct values
- Install dependencies: `pip install -r requirements.txt`

### Database connection errors
- Verify `DATABASE_URL` in `.env` is correct
- Check Supabase project is not paused
- Test connection: `python test_db_connection.py`

### AI responses not working
- Verify `GEMINI_API_KEY` is valid
- Check Gemini API quota/limits
- Try model: `gemini-2.0-flash-exp`

---

## Support

- **Documentation:** [`docs/`](docs/) folder
- **API Docs:** http://localhost:8000/docs (when server is running)
- **Issues:** Check the troubleshooting guides in `docs/`

---

## License

MIT License - See LICENSE file for details
