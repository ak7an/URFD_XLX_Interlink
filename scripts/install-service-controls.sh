#!/bin/sh
set -eu

echo "===== Installing Service Control Helper ====="

install -m 755 \
    dashboard/bin/urfd-service-control \
    /usr/local/bin/urfd-service-control

install -m 755 \
    dashboard/bin/urfd-service-config \
    /usr/local/bin/urfd-service-config

cat > /etc/sudoers.d/urfd-dashboard-service-control <<'EOF'
www-data ALL=(root) NOPASSWD: /usr/local/bin/urfd-service-control
www-data ALL=(root) NOPASSWD: /usr/local/bin/urfd-service-config
EOF

chmod 440 /etc/sudoers.d/urfd-dashboard-service-control

if command -v visudo >/dev/null 2>&1; then
    visudo -cf /etc/sudoers.d/urfd-dashboard-service-control
fi

touch /var/log/urfd-dashboard-actions.log
chown www-data:adm /var/log/urfd-dashboard-actions.log
chmod 640 /var/log/urfd-dashboard-actions.log

echo "Installed:"
echo "  /usr/local/bin/urfd-service-control"
echo "  /usr/local/bin/urfd-service-config"
echo "  /etc/sudoers.d/urfd-dashboard-service-control"
echo "  /var/log/urfd-dashboard-actions.log"
