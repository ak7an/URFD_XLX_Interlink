#!/usr/bin/env bash
set -euo pipefail

echo "===== Installing URFD/TCD Combined Service ====="

if [ "$EUID" -ne 0 ]; then
    echo "[FAIL] Please run as root"
    exit 1
fi

if [ ! -x /usr/local/bin/urfd ]; then
    echo "[FAIL] Missing /usr/local/bin/urfd"
    exit 1
fi

if [ ! -x /usr/local/bin/tcd ]; then
    echo "[WARN] Missing /usr/local/bin/tcd"
    echo "[WARN] TCD must be installed before urfd-tcd.service can run fully"
fi

install -d -m 755 /usr/local/etc

if [ ! -f /usr/local/etc/tcd.ini ]; then
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
    echo "[PASS] Generated default /usr/local/etc/tcd.ini"
else
    echo "[WARN] Existing /usr/local/etc/tcd.ini preserved"
fi

cat > /usr/local/bin/start-urfd-tcd.sh <<'EOF2'
#!/usr/bin/env bash
set -euo pipefail

URFD_BIN="/usr/local/bin/urfd"
URFD_INI="/usr/local/etc/urfd.ini"
TCD_BIN="/usr/local/bin/tcd"
TCD_INI="/usr/local/etc/tcd.ini"

echo "Starting URFD..."
"$URFD_BIN" "$URFD_INI" &
URFD_PID=$!

sleep 3

echo "Starting TCD..."
/sbin/rmmod ftdi_sio 2>/dev/null || true
"$TCD_BIN" "$TCD_INI" &
TCD_PID=$!

cleanup() {
    echo "Stopping URFD/TCD..."
    kill "$TCD_PID" "$URFD_PID" 2>/dev/null || true
    wait "$TCD_PID" "$URFD_PID" 2>/dev/null || true
}
trap cleanup INT TERM EXIT

while true; do
    if ! kill -0 "$URFD_PID" 2>/dev/null; then
        echo "URFD exited; stopping TCD."
        exit 1
    fi

    if ! kill -0 "$TCD_PID" 2>/dev/null; then
        echo "TCD exited; stopping URFD."
        exit 1
    fi

    sleep 2
done
EOF2

chmod 755 /usr/local/bin/start-urfd-tcd.sh

cat > /etc/systemd/system/urfd-tcd.service <<'EOF2'
[Unit]
Description=URFD Reflector with TCD Transcoder
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/start-urfd-tcd.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF2

systemctl daemon-reload
systemctl enable urfd-tcd.service

echo
echo "[PASS] urfd-tcd.service installed"
