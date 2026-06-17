#!/usr/bin/env bash
set -euo pipefail

echo "===== Installing TCD Transcoder ====="

if [ "$EUID" -ne 0 ]; then
    echo "[FAIL] Please run as root"
    exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PARENT="$(dirname "$ROOT")"
TCD_DIR="$PARENT/tcd"
TCD_REPO="https://github.com/nostar/tcd.git"

echo "URFD source: $ROOT"
echo "TCD source:  $TCD_DIR"

if ! ldconfig -p | grep -q 'libimbe_vocoder.so' && [[ ! -f /usr/local/lib/libimbe_vocoder.a ]]; then
    echo "[FAIL] Missing libimbe_vocoder library"
    echo "Install the IMBE vocoder library before building TCD."
    echo "Expected one of:"
    echo "  /usr/local/lib/libimbe_vocoder.so"
    echo "  /usr/local/lib/libimbe_vocoder.a"
    exit 1
fi

if ! ldconfig -p | grep -q 'libftd2xx.so'; then
    echo "[FAIL] Missing libftd2xx.so"
    echo "Install FTDI D2XX before building hardware-DVSI TCD."
    exit 1
fi

if [ ! -d "$TCD_DIR/.git" ]; then
    echo "[INFO] Cloning TCD from $TCD_REPO"
    git clone "$TCD_REPO" "$TCD_DIR"
else
    echo "[INFO] Existing TCD source found"
fi

if [ "$(readlink -f "$PARENT/urfd" 2>/dev/null || true)" != "$(readlink -f "$ROOT")" ]; then
    echo "[WARN] TCD expects sibling path ../urfd"
    echo "[WARN] Creating/refreshing symlink: $PARENT/urfd -> $ROOT"
    rm -f "$PARENT/urfd"
    ln -s "$ROOT" "$PARENT/urfd"
fi

if [ ! -f "$TCD_DIR/tcd.mk" ] && [ -f "$TCD_DIR/config/tcd.mk" ]; then
    echo "[INFO] Installing default TCD build config: tcd.mk"
    cp "$TCD_DIR/config/tcd.mk" "$TCD_DIR/tcd.mk"
fi

if [ ! -f "$TCD_DIR/tcd.ini" ] && [ -f "$TCD_DIR/config/tcd.ini" ]; then
    echo "[INFO] Installing default TCD runtime config: tcd.ini"
    cp "$TCD_DIR/config/tcd.ini" "$TCD_DIR/tcd.ini"
fi

if [ ! -f "$TCD_DIR/tcd.service" ] && [ -f "$TCD_DIR/config/tcd.service" ]; then
    echo "[INFO] Installing default TCD service template: tcd.service"
    cp "$TCD_DIR/config/tcd.service" "$TCD_DIR/tcd.service"
fi

make -C "$TCD_DIR" clean
make -C "$TCD_DIR"

install -m 755 "$TCD_DIR/tcd" /usr/local/bin/tcd

install -d -m 755 /usr/local/etc

if [ ! -f /usr/local/etc/tcd.ini ]; then
    if [ -f "$TCD_DIR/config/tcd.ini" ]; then
        install -m 644 "$TCD_DIR/config/tcd.ini" /usr/local/etc/tcd.ini
    elif [ -f "$TCD_DIR/tcd.ini" ]; then
        install -m 644 "$TCD_DIR/tcd.ini" /usr/local/etc/tcd.ini
    else
        cat > /usr/local/etc/tcd.ini <<'EOF2'
# Transcoder Ini file

Port = 10100
ServerAddress = 127.0.0.1
Modules = A

DStarGainIn   =  16
DStarGainOut  = -10
DmrYsfGainIn  =  -3
DmrYsfGainOut =   0
UsrpTxGain    =  12
UsrpRxGain    =  -6
EOF2
    fi
    echo "[PASS] Installed /usr/local/etc/tcd.ini"
else
    echo "[WARN] Existing /usr/local/etc/tcd.ini preserved"
fi

ldconfig

echo
echo "[PASS] TCD installed"
echo "Binary: /usr/local/bin/tcd"
echo "Config: /usr/local/etc/tcd.ini"
