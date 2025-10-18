-- Create journal tables
CREATE TABLE IF NOT EXISTS journal_sessions (
    id INTEGER PRIMARY KEY,
    user_id UUID NOT NULL,
    name TEXT NOT NULL,
    cover_image_url TEXT,
    cover_image_path TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS journal_entries (
    id INTEGER PRIMARY KEY,
    session_id INTEGER NOT NULL,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    image_url TEXT NOT NULL,
    image_path TEXT NOT NULL,
    weight REAL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES journal_sessions(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_journal_sessions_user_id ON journal_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_journal_entries_session_id ON journal_entries(session_id);
