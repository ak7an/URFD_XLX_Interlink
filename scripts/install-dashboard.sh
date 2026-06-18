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

if [ -f "$WEBROOT/bin/urfd-callinghome" ]; then
    chmod 755 "$WEBROOT/bin/urfd-callinghome"
    install -m 755 "$WEBROOT/bin/urfd-callinghome" /usr/local/bin/urfd-callinghome
fi

if [ -f "$WEBROOT/bin/urfd-service-control" ]; then
    chmod 755 "$WEBROOT/bin/urfd-service-control"
fi

if [ -f "$WEBROOT/bin/urfd-service-config" ]; then
    chmod 755 "$WEBROOT/bin/urfd-service-config"
fi

echo
echo "[PASS] Dashboard installed"
echo "Location: $WEBROOT"
