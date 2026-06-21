#!/usr/bin/env bash
set -euo pipefail

echo "===== Installing IMBE Vocoder Library ====="

if [ "$EUID" -ne 0 ]; then
    echo "[FAIL] Please run as root"
    exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PARENT="$(dirname "$ROOT")"
IMBE_DIR="$PARENT/imbe_vocoder"
IMBE_REPO="https://github.com/nostar/imbe_vocoder"

echo "IMBE source: $IMBE_DIR"

if [ ! -d "$IMBE_DIR/.git" ]; then
    echo "[INFO] Cloning IMBE vocoder from $IMBE_REPO"
    git clone "$IMBE_REPO" "$IMBE_DIR"
else
    echo "[INFO] Existing IMBE vocoder source found"
fi

make -C "$IMBE_DIR" clean
make -C "$IMBE_DIR"
make -C "$IMBE_DIR" install

ldconfig

if ldconfig -p | grep -q 'libimbe_vocoder.so' || [ -f /usr/local/lib/libimbe_vocoder.a ]; then
    echo "[PASS] libimbe_vocoder installed"
else
    echo "[FAIL] libimbe_vocoder not found after install"
    exit 1
fi
