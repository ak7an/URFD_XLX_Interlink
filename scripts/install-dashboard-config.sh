#!/usr/bin/env bash
set -euo pipefail

echo "===== Installing Dashboard Configuration ====="

if [ "$EUID" -ne 0 ]; then
    echo "[FAIL] Please run as root"
    exit 1
fi

install -d -m 755 /etc/urfd-dashboard

DEFAULT_TZ="$(timedatectl show -p Timezone --value 2>/dev/null || true)"
DEFAULT_TZ="${DEFAULT_TZ:-America/Denver}"

read -r -p "Dashboard timezone [$DEFAULT_TZ]: " DASHBOARD_TZ
DASHBOARD_TZ="${DASHBOARD_TZ:-$DEFAULT_TZ}"

if ! timedatectl list-timezones | grep -qx "$DASHBOARD_TZ"; then
    echo "[FAIL] Invalid timezone: $DASHBOARD_TZ"
    echo "Example: America/Denver"
    exit 1
fi

cat > /etc/urfd-dashboard/dashboard.conf <<EOF2
# URFD Dashboard configuration
TIMEZONE=$DASHBOARD_TZ
EOF2

chmod 644 /etc/urfd-dashboard/dashboard.conf

echo
echo "[PASS] Dashboard timezone configured: $DASHBOARD_TZ"
