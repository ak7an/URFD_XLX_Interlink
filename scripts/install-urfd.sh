#!/usr/bin/env bash
set -euo pipefail

echo "===== Installing URFD Reflector ====="

if [ "$EUID" -ne 0 ]; then
    echo "[FAIL] Please run as root"
    exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REFLECTOR_DIR="$ROOT/reflector"

if [ ! -f "$REFLECTOR_DIR/Makefile" ]; then
    echo "[FAIL] Missing reflector Makefile: $REFLECTOR_DIR/Makefile"
    exit 1
fi

make -C "$REFLECTOR_DIR" clean
make -C "$REFLECTOR_DIR"

install -m 755 "$REFLECTOR_DIR/urfd" /usr/local/bin/urfd

install -d -m 755 /usr/local/etc

if [ ! -f /usr/local/etc/urfd.ini ]; then
    install -m 644 "$REFLECTOR_DIR/urfd.ini" /usr/local/etc/urfd.ini
    echo "[PASS] Installed default /usr/local/etc/urfd.ini"
else
    echo "[WARN] Existing /usr/local/etc/urfd.ini preserved"
fi

if [ ! -f /usr/local/etc/urfd.interlink ]; then
    install -m 644 "$REFLECTOR_DIR/urfd.interlink" /usr/local/etc/urfd.interlink
    echo "[PASS] Installed default /usr/local/etc/urfd.interlink"
else
    echo "[WARN] Existing /usr/local/etc/urfd.interlink preserved"
fi

if [ -f "$REFLECTOR_DIR/urfd.blacklist" ] && [ ! -f /usr/local/etc/urfd.blacklist ]; then
    install -m 644 "$REFLECTOR_DIR/urfd.blacklist" /usr/local/etc/urfd.blacklist
fi

if [ -f "$REFLECTOR_DIR/urfd.whitelist" ] && [ ! -f /usr/local/etc/urfd.whitelist ]; then
    install -m 644 "$REFLECTOR_DIR/urfd.whitelist" /usr/local/etc/urfd.whitelist
fi

echo
echo "[PASS] URFD installed"
echo "Binary: /usr/local/bin/urfd"
echo "Config: /usr/local/etc/urfd.ini"
