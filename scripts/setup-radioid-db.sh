#!/usr/bin/env bash
set -euo pipefail

DASH_USER="${SUDO_USER:-$USER}"
DASH_GROUP="www-data"
DASH_DIR="/var/lib/urfd-dashboard"
DB="$DASH_DIR/radioid.sqlite"

apt-get update
apt-get install -y sqlite3 php-sqlite3 python3 curl apache2 php

install -d -m 775 -o "$DASH_USER" -g "$DASH_GROUP" "$DASH_DIR"

sqlite3 "$DB" < dashboard/sql/radioid_schema.sql

chown -R "$DASH_USER:$DASH_GROUP" "$DASH_DIR"
chmod -R 775 "$DASH_DIR"
chmod 664 "$DB"

echo "[PASS] RadioID SQLite database ready: $DB"
