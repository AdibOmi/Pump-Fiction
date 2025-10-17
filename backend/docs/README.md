# Backend (FastAPI)

Run locally:

1. Create virtualenv and activate it.
2. Install dependencies:

   ```bash
   pip install -r requirements.txt
   ```

3. Configure environment variables:
   - Copy `.env.example` to `.env` (or create `.env` file)
   - Add your Supabase and Gemini API credentials

4. Start server (IMPORTANT - must run from backend directory):

   ```bash
   cd backend
   python -m uvicorn app.main:app --reload --port 8000
   ```

   Or if already in backend directory:

   ```bash
   python -m uvicorn app.main:app --reload --port 8000
   ```

5. Access the API:
   - API: http://127.0.0.1:8000
   - Interactive docs: http://127.0.0.1:8000/docs
