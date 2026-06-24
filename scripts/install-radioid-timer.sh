#!/usr/bin/env bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "[FAIL] Please run as root"
    exit 1
fi

cat >/etc/systemd/system/urfd-radioid-update.service <<'SERVICE'
[Unit]
Description=Update URFD Dashboard RadioID SQLite Database
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/urfd-radioid-update
User=root
SERVICE

cat >/etc/systemd/system/urfd-radioid-update.timer <<'TIMER'
[Unit]
Description=Nightly URFD RadioID database update

[Timer]
OnCalendar=*-*-* 02:15:00
Persistent=true

[Install]
WantedBy=timers.target
TIMER

systemctl daemon-reload
systemctl enable --now urfd-radioid-update.timer

echo "[PASS] Nightly RadioID update timer installed"
systemctl list-timers urfd-radioid-update.timer --no-pager
