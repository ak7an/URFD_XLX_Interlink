#!/usr/bin/env bash
set -euo pipefail

echo "===== Installing XLX Calling Home Timer ====="

if [ "$EUID" -ne 0 ]; then
    echo "[FAIL] Please run as root"
    exit 1
fi

if [ ! -x /usr/local/bin/urfd-callinghome ]; then
    echo "[FAIL] /usr/local/bin/urfd-callinghome missing or not executable"
    echo "Run scripts/install-dashboard.sh first."
    exit 1
fi

cat >/etc/systemd/system/urfd-callinghome.service <<'SERVICE'
[Unit]
Description=URFD XLX Calling Home Publisher
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/urfd-callinghome
SERVICE

cat >/etc/systemd/system/urfd-callinghome.timer <<'TIMER'
[Unit]
Description=URFD XLX Calling Home periodic publisher

[Timer]
OnBootSec=2min
OnUnitActiveSec=10min
Unit=urfd-callinghome.service

[Install]
WantedBy=timers.target
TIMER

systemctl daemon-reload
systemctl enable --now urfd-callinghome.timer

echo
echo "[PASS] XLX Calling Home timer installed"
systemctl list-timers urfd-callinghome.timer --no-pager
