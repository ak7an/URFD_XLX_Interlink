#!/usr/bin/env bash
set -euo pipefail

WEBROOT="/var/www/html/urf/urfd"

echo "===== Installing Dashboard ====="

install -d -m 755 /var/www/html/urf
install -d -m 755 "$WEBROOT"

cp -a dashboard/. "$WEBROOT/"

chown -R www-data:www-data "$WEBROOT"

find "$WEBROOT" -type d -exec chmod 755 {} \;
find "$WEBROOT" -type f -exec chmod 644 {} \;

if [ -f "$WEBROOT/bin/urfd-radioid-import" ]; then
    chmod 755 "$WEBROOT/bin/urfd-radioid-import"
fi

if [ -f "$WEBROOT/bin/urfd-radioid-update" ]; then
    chmod 755 "$WEBROOT/bin/urfd-radioid-update"
fi

echo
echo "[PASS] Dashboard installed"
echo "Location: $WEBROOT"
