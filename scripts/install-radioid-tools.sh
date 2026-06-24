#!/usr/bin/env bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "[FAIL] Please run as root"
    exit 1
fi

install -m 755 dashboard/bin/urfd-radioid-import /usr/local/bin/urfd-radioid-import
install -m 755 dashboard/bin/urfd-radioid-update /usr/local/bin/urfd-radioid-update

install -d -m 755 /etc/urfd-dashboard

if [ ! -f /etc/urfd-dashboard/radioid.conf ]; then
    cat >/etc/urfd-dashboard/radioid.conf <<'CONF'
# URFD Dashboard RadioID download configuration
#
# Set these to the current CSV dump URLs used by your deployment.
# The updater skips blank URLs.
#
# Example:
# DMR_URL="https://example.com/dmr.csv"
# NXDN_URL="https://example.com/nxdn.csv"
# P25_URL="https://example.com/p25.csv"

DMR_URL=""
NXDN_URL=""
P25_URL=""
CONF
fi

echo "[PASS] RadioID tools installed"
echo "Edit /etc/urfd-dashboard/radioid.conf with download URLs"
