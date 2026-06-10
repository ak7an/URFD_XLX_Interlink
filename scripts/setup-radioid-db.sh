#!/usr/bin/env bash
set -euo pipefail

DASH_USER="${SUDO_USER:-www-data}"
DASH_GROUP="www-data"

DASH_DIR="/var/lib/urfd-dashboard"
DB="$DASH_DIR/radioid.sqlite"

install -d -m 775 -o "$DASH_USER" -g "$DASH_GROUP" "$DASH_DIR"

sqlite3 "$DB" < dashboard/sql/radioid_schema.sql

chown -R "$DASH_USER:$DASH_GROUP" "$DASH_DIR"

chmod 775 "$DASH_DIR"
chmod 664 "$DB"

echo "[PASS] RadioID SQLite database ready: $DB"
