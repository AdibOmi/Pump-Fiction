# Git Ignore Configuration

## Files Created

### 1. `backend/.gitignore`
Backend-specific gitignore file that prevents sensitive files from being committed.

### 2. `backend/.env.example`
Template file showing the required environment variables. Safe to commit to git.

---

## What's Being Ignored

### ✅ Sensitive Files (IMPORTANT!)
- `.env` - Contains API keys, passwords, and secrets
- `.env.local`, `.env.*.local` - Local environment overrides
- `*.db`, `*.sqlite`, `*.sqlite3` - Local database files
- `*.key`, `*.pem` - Private keys and certificates
- `secrets.json`, `credentials.json` - Credential files

### ✅ Python Build Files
- `__pycache__/` - Python bytecode cache
- `*.pyc`, `*.pyo`, `*.pyd` - Compiled Python files
- `*.egg-info/` - Package metadata
- `build/`, `dist/` - Distribution directories

### ✅ Virtual Environments
- `venv/`, `.venv/`, `env/`, `ENV/` - Virtual environment directories

### ✅ IDE and Editor Files
- `.vscode/` - VS Code settings
- `.idea/` - PyCharm/IntelliJ settings
- `*.swp`, `*.swo` - Vim swap files
- `.DS_Store` - macOS metadata

### ✅ Testing and Coverage
- `.pytest_cache/` - Pytest cache
- `.coverage`, `htmlcov/` - Coverage reports
- `.tox/` - Tox testing environments

### ✅ Logs and Temporary Files
- `*.log` - Log files
- `logs/` - Log directory
- `*.tmp`, `*.temp`, `*.bak` - Temporary files

---

## Important Security Notes

### 🚨 NEVER Commit These Files:
1. `.env` - Contains your database password, API keys
2. `*.db` files - May contain user data
3. Any file with "secret", "key", or "credential" in the name

### ✅ Safe to Commit:
1. `.env.example` - Template without actual secrets
2. `.gitignore` - The ignore rules themselves
3. All your source code files (`.py`)
4. `requirements.txt` - Dependency list

---

## How to Use

### For New Developers Setting Up the Project:

1. **Copy the example env file:**
   ```bash
   cp .env.example .env
   ```

2. **Fill in your actual values in `.env`:**
   - Get your Supabase credentials from the dashboard
   - Get your Gemini API key from Google AI Studio
   - Update the DATABASE_URL with your actual password

3. **Never commit `.env`:**
   - Git is already configured to ignore it
   - Double-check with: `git status` (`.env` should NOT appear)

---

## Verify Files Are Ignored

Check if sensitive files are properly ignored:

```bash
cd backend
git check-ignore .env test.db __pycache__
```

If these files are listed, they're properly ignored! ✅

---

## Check What Will Be Committed

Before committing, always check:

```bash
git status
```

**You should NOT see:**
- `.env`
- `__pycache__/`
- `*.db` files
- `venv/` or `.venv/`

**You SHOULD see:**
- `.env.example` ✅
- `.gitignore` ✅
- `.py` source files ✅
- `requirements.txt` ✅

---

## If You Accidentally Committed Secrets

If you already committed `.env` or other secrets:

### 1. Remove from git (keep local file):
```bash
git rm --cached backend/.env
git commit -m "Remove .env from git"
```

### 2. Rotate all secrets immediately:
- Generate new Supabase service role key
- Generate new Gemini API key
- Change database password

### 3. Update `.env` with new secrets

**Note:** Once secrets are committed to git history, they should be considered compromised even after removal.

---

## Project Structure

```
backend/
├── .env                 # ❌ Ignored - Your secrets here
├── .env.example         # ✅ Committed - Template
├── .gitignore          # ✅ Committed - Ignore rules
├── app/
│   ├── __pycache__/    # ❌ Ignored - Python cache
│   ├── main.py         # ✅ Committed - Source code
│   └── ...
├── venv/               # ❌ Ignored - Virtual env
├── test.db             # ❌ Ignored - Local database
├── requirements.txt    # ✅ Committed - Dependencies
└── README.md           # ✅ Committed - Documentation
```

---

## Additional Security Tips

1. **Use separate `.env` files for different environments:**
   - `.env.development` - Local development
   - `.env.staging` - Staging server
   - `.env.production` - Production server
   - All are ignored by git

2. **Use environment-specific passwords:**
   - Don't use the same password in dev and production
   - Rotate credentials regularly

3. **Review commits before pushing:**
   ```bash
   git diff --cached
   ```

4. **Use `.env.example` to document required variables:**
   - Keep it updated when adding new environment variables
   - Use fake/placeholder values

---

## Questions?

- **Q: I need to share API keys with my team**
  - A: Use a secure password manager (1Password, LastPass, etc.)
  - Never send keys via Slack, email, or commit to git

- **Q: Can I commit database connection strings?**
  - A: NO! They contain passwords. Use `.env` instead.

- **Q: What about Supabase anon key?**
  - A: The anon key is safe for client apps (Flutter), but service_role key must stay secret

---

**Remember: When in doubt, don't commit it!** 🔒
