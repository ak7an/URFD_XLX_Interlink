#!/usr/bin/env bash
set -euo pipefail

echo "===== Installing FTDI D2XX Library ====="

if [ "$EUID" -ne 0 ]; then
    echo "[FAIL] Please run as root"
    exit 1
fi

ARCH="$(dpkg --print-architecture)"
MACHINE="$(uname -m)"

case "$ARCH:$MACHINE" in
    amd64:x86_64)
        ARCH_HINT="x86_64"
        ;;
    arm64:aarch64)
        ARCH_HINT="arm-v8"
        ;;
    armhf:armv7*|armhf:arm*)
        ARCH_HINT="arm-v7"
        ;;
    *)
        ARCH_HINT=""
        ;;
esac

if ldconfig -p | grep -q 'libftd2xx.so'; then
    echo "[PASS] libftd2xx already installed"
    exit 0
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PARENT="$(dirname "$ROOT")"

CANDIDATES=()

while IFS= read -r f; do
    CANDIDATES+=("$f")
done < <(
    find "$ROOT" "$PARENT" /tmp -maxdepth 3 -type f \
        \( -iname "libftd2xx*.tgz" -o -iname "libftd2xx*.tar.gz" \) \
        2>/dev/null | sort
)

if [ "${#CANDIDATES[@]}" -eq 0 ]; then
    echo "[FAIL] FTDI D2XX archive not found"
    echo
    echo "Download the Linux FTDI D2XX driver archive from FTDI:"
    echo "  https://ftdichip.com/drivers/d2xx-drivers/"
    echo
    echo "Place the archive beside this repository or in /tmp."
    echo "Example:"
    echo "  $PARENT/libftd2xx-linux-${ARCH_HINT}-<version>.tgz"
    echo
    echo "Then rerun:"
    echo "  sudo ./scripts/install-ftdi-d2xx.sh"
    exit 1
fi

ARCHIVE="${CANDIDATES[0]}"
echo "[INFO] Using archive: $ARCHIVE"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

if ! tar -tzf "$ARCHIVE" >/dev/null 2>&1; then
    echo "[FAIL] FTDI archive is not a valid gzip tar archive: $ARCHIVE"
    echo "       This may be an HTML error page saved as .tgz."
    exit 1
fi

tar -xzf "$ARCHIVE" -C "$WORK"

LIB="$(find "$WORK" -type f -name "libftd2xx.so.*" | sort -V | tail -1)"
if [ -z "$LIB" ]; then
    LIB="$(find "$WORK" -type f -name "libftd2xx.so" | head -1)"
fi
STATIC_LIB="$(find "$WORK" -type f -name "libftd2xx.a" | head -1 || true)"
HEADER="$(find "$WORK" -type f -path "*/ftd2xx.h" | grep -v "/examples/" | head -1)"
WINTYPES="$(find "$WORK" -type f -path "*/WinTypes.h" | grep -v "/examples/" | head -1)"

if [ -z "$LIB" ] || [ -z "$HEADER" ] || [ -z "$WINTYPES" ]; then
    echo "[FAIL] Archive does not contain expected FTDI D2XX files"
    exit 1
fi

install -m 755 "$LIB" /usr/local/lib/
if [ "$(basename "$LIB")" != "libftd2xx.so" ]; then
    ln -sf "/usr/local/lib/$(basename "$LIB")" /usr/local/lib/libftd2xx.so
fi

if [ -n "$STATIC_LIB" ]; then
    install -m 644 "$STATIC_LIB" /usr/local/lib/libftd2xx.a
fi

install -m 644 "$HEADER" /usr/local/include/ftd2xx.h
install -m 644 "$WINTYPES" /usr/local/include/WinTypes.h

TXT="$(find "$WORK" -type f -name "libftd2xx.txt" | head -1 || true)"
if [ -n "$TXT" ]; then
    install -m 644 "$TXT" /usr/local/lib/libftd2xx.txt
fi

ldconfig

if ldconfig -p | grep -q 'libftd2xx.so'; then
    echo "[PASS] libftd2xx installed"
else
    echo "[FAIL] libftd2xx not found after install"
    exit 1
fi
