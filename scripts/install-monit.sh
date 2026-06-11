#!/usr/bin/env bash
set -euo pipefail

echo "===== Installing Monit Maintenance Dashboard ====="

if [ "$EUID" -ne 0 ]; then
    echo "[FAIL] Please run as root"
    exit 1
fi

read -r -p "Enable Monit maintenance dashboard? [Y/n]: " ENABLE_MONIT
ENABLE_MONIT="${ENABLE_MONIT:-Y}"

case "$ENABLE_MONIT" in
    y|Y|yes|YES)
        ;;
    *)
        echo "[WARN] Monit setup skipped"
        exit 0
        ;;
esac

read -r -p "Monit admin username: " MONIT_USER

if [ -z "$MONIT_USER" ]; then
    echo "[FAIL] Username cannot be empty"
    exit 1
fi

while true; do
    read -r -s -p "Monit admin password: " MONIT_PASS
    echo
    read -r -s -p "Confirm password: " MONIT_PASS2
    echo

    if [ "$MONIT_PASS" = "$MONIT_PASS2" ] && [ -n "$MONIT_PASS" ]; then
        break
    fi

    echo "[FAIL] Passwords did not match or were empty. Try again."
done

apt-get install -y monit apache2-utils

a2enmod proxy proxy_http headers >/dev/null

install -d -m 755 /etc/monit/conf-enabled

cat > /etc/monit/conf-enabled/urfd-monit-webui <<EOF2
set httpd port 2812 and
    use address 127.0.0.1
    allow 127.0.0.1
    allow ${MONIT_USER}:${MONIT_PASS}
EOF2

cat > /etc/monit/conf-enabled/urfd-services <<'EOF2'
check process urfd matching "/home/ed/urfd/reflector/urfd"
    start program = "/bin/systemctl start urfd-tcd.service"
    stop program  = "/bin/systemctl stop urfd-tcd.service"

check process tcd matching "/usr/local/bin/tcd"
    start program = "/bin/systemctl start urfd-tcd.service"
    stop program  = "/bin/systemctl stop urfd-tcd.service"

check system server
    if loadavg (5min) > 8 then alert
    if memory usage > 90% then alert
    if cpu usage > 95% for 5 cycles then alert
EOF2

htpasswd -b -c /etc/apache2/.htpasswd-monit "$MONIT_USER" "$MONIT_PASS"

cat > /etc/apache2/conf-available/urfd-monit.conf <<'EOF2'
<Location "/monit/">
    AuthType Basic
    AuthName "URFD Monit"
    AuthUserFile /etc/apache2/.htpasswd-monit
    Require valid-user

    ProxyPass http://127.0.0.1:2812/
    ProxyPassReverse http://127.0.0.1:2812/
</Location>
EOF2

a2enconf urfd-monit >/dev/null

monit -t
apache2ctl configtest

systemctl enable monit
systemctl restart monit
systemctl reload apache2

echo
echo "[PASS] Monit maintenance dashboard installed"
echo "URL: /monit/"
echo "Username: $MONIT_USER"
