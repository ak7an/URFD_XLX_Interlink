PRAGMA journal_mode=WAL;

CREATE TABLE IF NOT EXISTS radioid (
    id INTEGER PRIMARY KEY,
    callsign TEXT NOT NULL,
    first_name TEXT,
    last_name TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    protocol TEXT,
    source TEXT,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_radioid_callsign ON radioid(callsign);
CREATE INDEX IF NOT EXISTS idx_radioid_protocol ON radioid(protocol);
CREATE INDEX IF NOT EXISTS idx_radioid_source ON radioid(source);
