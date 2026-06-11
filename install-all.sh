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

"$ROOT/scripts/install-dashboard.sh"

"$ROOT/scripts/setup-radioid-db.sh"

"$ROOT/scripts/install-radioid-tools.sh"

"$ROOT/scripts/install-radioid-timer.sh"

"$ROOT/scripts/install-monit.sh"

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
