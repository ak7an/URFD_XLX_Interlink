#!/usr/bin/env bash

PASS=0
FAIL=0
WARN=0

check_pass() {
    echo "[PASS] $1"
    PASS=$((PASS+1))
}

check_fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL+1))
}

check_warn() {
    echo "[WARN] $1"
    WARN=$((WARN+1))
}

check_file() {
    local label="$1"
    local path="$2"

    if [ -e "$path" ]; then
        check_pass "$label: $path"
    else
        check_fail "$label missing: $path"
    fi
}

check_cmd() {
    local label="$1"
    local cmd="$2"

    if command -v "$cmd" >/dev/null 2>&1; then
        check_pass "$label installed: $(command -v "$cmd")"
    else
        check_fail "$label missing: $cmd"
    fi
}

echo "===== URFD_XLX_Interlink Install Check ====="
echo

check_file "URFD binary" "/usr/local/bin/urfd"
check_file "TCD binary" "/usr/local/bin/tcd"
check_file "URFD/TCD launcher" "/usr/local/bin/start-urfd-tcd.sh"

echo
echo "===== Services ====="

if systemctl list-unit-files | grep -q '^urfd-tcd.service'; then
    check_pass "urfd-tcd.service installed"
else
    check_fail "urfd-tcd.service not installed"
fi

if systemctl is-active --quiet urfd-tcd.service; then
    check_pass "urfd-tcd.service active"
else
    check_fail "urfd-tcd.service not active"
fi

if systemctl is-active --quiet apache2; then
    check_pass "Apache2 active"
else
    check_fail "Apache2 not active"
fi

echo
echo "===== Dependencies ====="

check_cmd "URFD" "urfd"
check_cmd "TCD" "tcd"
check_cmd "Apache2" "apache2"
check_cmd "Monit" "monit"
check_cmd "htpasswd" "htpasswd"
check_cmd "PHP" "php"
check_cmd "SQLite3" "sqlite3"
check_cmd "Python3" "python3"
check_cmd "curl" "curl"

if php -m | grep -q '^sqlite3$'; then
    check_pass "PHP sqlite3 module loaded"
else
    check_fail "PHP sqlite3 module missing"
fi

if php -m | grep -q '^pdo_sqlite$'; then
    check_pass "PHP pdo_sqlite module loaded"
else
    check_fail "PHP pdo_sqlite module missing"
fi

echo
echo "===== Dashboard ====="

check_file "Public dashboard" "/var/www/html/urf/urfd/index.php"
check_file "Sysop dashboard" "/var/www/html/urf/urfd/sysop/index.php"
check_file "Live XML status" "/var/log/xlxd.xml"
check_file "RadioID SQLite DB" "/var/lib/urfd-dashboard/radioid.sqlite"
check_file "RadioID importer" "/usr/local/bin/urfd-radioid-import"
check_file "RadioID updater" "/usr/local/bin/urfd-radioid-update"
check_file "RadioID config" "/etc/urfd-dashboard/radioid.conf"

if [ -r /var/log/xlxd.xml ]; then
    check_pass "XML status readable"
else
    check_fail "XML status not readable"
fi

if [ -r /var/lib/urfd-dashboard/radioid.sqlite ]; then
    COUNT="$(sqlite3 /var/lib/urfd-dashboard/radioid.sqlite 'SELECT COUNT(*) FROM radioid;' 2>/dev/null || echo 0)"
    if [ "$COUNT" -gt 0 ]; then
        check_pass "RadioID records loaded: $COUNT"
    else
        check_warn "RadioID database exists but has no records"
    fi
else
    check_fail "RadioID database not readable"
fi

echo
echo "===== Apache HTTPS ====="

if apache2ctl -S 2>/dev/null | grep -q ':443'; then
    check_pass "Apache HTTPS virtual host present"
else
    check_warn "Apache HTTPS virtual host not detected"
fi


echo
echo "===== Monit Maintenance ====="

if systemctl list-unit-files | grep -q '^monit.service'; then
    check_pass "Monit service installed"
else
    check_fail "Monit service not installed"
fi

if systemctl is-active --quiet monit; then
    check_pass "Monit active"
else
    check_fail "Monit not active"
fi

check_file "Monit web UI config" "/etc/monit/conf-enabled/urfd-monit-webui"
check_file "Monit URFD service config" "/etc/monit/conf-enabled/urfd-services"
check_file "Monit Apache proxy config" "/etc/apache2/conf-available/urfd-monit.conf"
check_file "Monit Apache auth file" "/etc/apache2/.htpasswd-monit"

if apache2ctl -S 2>/dev/null | grep -q 'urfd-monit'; then
    check_pass "Monit Apache config loaded"
else
    check_warn "Monit Apache config not detected in apache2ctl output"
fi

if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:2812/ | grep -qE '200|401'; then
    check_pass "Monit localhost web UI responding"
else
    check_warn "Monit localhost web UI not responding"
fi

echo
echo "===== RadioID Timer ====="

if systemctl list-unit-files | grep -q '^urfd-radioid-update.timer'; then
    check_pass "RadioID update timer installed"
else
    check_warn "RadioID update timer not installed"
fi

if systemctl is-enabled --quiet urfd-radioid-update.timer 2>/dev/null; then
    check_pass "RadioID update timer enabled"
else
    check_warn "RadioID update timer not enabled"
fi

echo
echo "===== Summary ====="
echo "PASS: $PASS"
echo "WARN: $WARN"
echo "FAIL: $FAIL"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi

exit 0
