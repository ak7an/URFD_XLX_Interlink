#!/usr/bin/env bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo
    echo "Please run as root:"
    echo
    echo "  sudo ./install-all.sh"
    echo
    exit 1
fi

ROOT="$(cd "$(dirname "$0")" && pwd)"

echo
echo "=========================================="
echo " URFD_XLX_Interlink Installer"
echo "=========================================="
echo

"$ROOT/scripts/install-deps.sh"

"$ROOT/scripts/install-urfd.sh"

"$ROOT/scripts/install-imbe-vocoder.sh"

if "$ROOT/scripts/install-ftdi-d2xx.sh"; then
    "$ROOT/scripts/install-tcd.sh"
    "$ROOT/scripts/install-urfd-tcd-service.sh"
else
    echo
    echo "[WARN] FTDI D2XX was not installed"
    echo "[WARN] Skipping TCD and URFD/TCD service installation"
    echo "[WARN] URFD, dashboard, RadioID, service controls, and Calling Home will continue"
fi

"$ROOT/scripts/install-dashboard-config.sh"

"$ROOT/scripts/install-dashboard.sh"

"$ROOT/scripts/setup-radioid-db.sh"

"$ROOT/scripts/install-radioid-tools.sh"

"$ROOT/scripts/install-radioid-timer.sh"

"$ROOT/scripts/install-service-controls.sh"

"$ROOT/scripts/install-callinghome-timer.sh"

echo
echo "===== Optional Reflector Configuration ====="
echo

"$ROOT/scripts/configure-reflector.sh"

echo
echo "===== Validation ====="
echo

"$ROOT/scripts/check-install.sh"

echo
echo "=========================================="
echo " Installation Complete"
echo "=========================================="
