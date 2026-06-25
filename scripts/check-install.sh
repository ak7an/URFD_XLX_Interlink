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

check_file_warn() {
    local label="$1"
    local path="$2"

    if [ -e "$path" ]; then
        check_pass "$label: $path"
    else
        check_warn "$label missing: $path"
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

check_executable() {
    local label="$1"
    local path="$2"

    if [ -x "$path" ]; then
        check_pass "$label executable: $path"
    elif [ -e "$path" ]; then
        check_fail "$label not executable: $path"
    else
        check_fail "$label missing: $path"
    fi
}

check_executable_warn() {
    local label="$1"
    local path="$2"

    if [ -x "$path" ]; then
        check_pass "$label executable: $path"
    elif [ -e "$path" ]; then
        check_warn "$label not executable: $path"
    else
        check_warn "$label missing: $path"
    fi
}

check_php_lint() {
    local label="$1"
    local path="$2"

    if [ ! -f "$path" ]; then
        check_fail "$label missing: $path"
        return
    fi

    if php -l "$path" >/dev/null 2>&1; then
        check_pass "$label PHP syntax valid"
    else
        check_fail "$label PHP syntax invalid: $path"
    fi
}

check_php_lint_if_exists() {
    local label="$1"
    local path="$2"

    if [ ! -f "$path" ]; then
        check_warn "$label missing; PHP syntax check skipped: $path"
        return
    fi

    if php -l "$path" >/dev/null 2>&1; then
        check_pass "$label PHP syntax valid"
    else
        check_fail "$label PHP syntax invalid: $path"
    fi
}

conf_value() {
    local key="$1"
    local file="$2"

    grep -E "^${key}=" "$file" 2>/dev/null | tail -n 1 | cut -d= -f2- || true
}

check_conf_key() {
    local label="$1"
    local key="$2"
    local file="$3"

    if grep -Eq "^${key}=" "$file" 2>/dev/null; then
        check_pass "$label configured: $key"
    else
        check_warn "$label missing: $key"
    fi
}

check_unit_file_contains() {
    local label="$1"
    local unit_file="$2"
    local pattern="$3"

    if [ ! -r "$unit_file" ]; then
        check_warn "$label skipped; unit file unreadable: $unit_file"
        return
    fi

    if grep -Eq "$pattern" "$unit_file"; then
        check_pass "$label"
    else
        check_warn "$label not found in $unit_file"
    fi
}

echo "===== URFD_XLX_Interlink Install Check ====="
echo

check_file "URFD binary" "/usr/local/bin/urfd"

TCD_AVAILABLE=false
if [ -x /usr/local/bin/tcd ]; then
    TCD_AVAILABLE=true
    check_pass "TCD binary: /usr/local/bin/tcd"
else
    check_warn "TCD binary missing; TCD stack may have been skipped"
fi

if [ -x /usr/local/bin/start-urfd-tcd.sh ]; then
    check_pass "URFD/TCD launcher: /usr/local/bin/start-urfd-tcd.sh"
else
    check_warn "URFD/TCD launcher missing; TCD stack may have been skipped"
fi

echo
echo "===== Services ====="

if systemctl list-unit-files | grep -q '^urfd-tcd.service'; then
    check_pass "urfd-tcd.service installed"
else
    check_warn "urfd-tcd.service not installed; TCD stack may have been skipped"
fi

if systemctl is-active --quiet urfd-tcd.service; then
    check_pass "urfd-tcd.service active"
else
    check_warn "urfd-tcd.service not active; reflector may not be started yet"
fi

if systemctl is-active --quiet apache2; then
    check_pass "Apache2 active"
else
    check_fail "Apache2 not active"
fi

echo
echo "===== Dependencies ====="

check_cmd "URFD" "urfd"
if command -v tcd >/dev/null 2>&1; then
    check_pass "TCD installed: $(command -v tcd)"
else
    check_warn "TCD missing; optional when FTDI D2XX is unavailable"
fi
check_cmd "Apache2" "apache2"
check_cmd "make" "make"
check_cmd "g++" "g++"
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
echo "===== Reflector Core Stack ====="

check_file "URFD config" "/usr/local/etc/urfd.ini"
check_file "URFD interlink config" "/usr/local/etc/urfd.interlink"
if [ -e /usr/local/etc/tcd.ini ]; then
    check_pass "TCD config: /usr/local/etc/tcd.ini"
else
    check_warn "TCD config missing; TCD stack may have been skipped"
fi

if [ -e /usr/local/bin/start-urfd-tcd.sh ]; then
    check_pass "Combined URFD/TCD launcher: /usr/local/bin/start-urfd-tcd.sh"
else
    check_warn "Combined URFD/TCD launcher missing; TCD stack may have been skipped"
fi

if [ -e /etc/systemd/system/urfd-tcd.service ]; then
    check_pass "Combined URFD/TCD service: /etc/systemd/system/urfd-tcd.service"
else
    check_warn "Combined URFD/TCD service missing; TCD stack may have been skipped"
fi

if ldconfig -p | grep -q 'libimbe_vocoder.so' || [ -f /usr/local/lib/libimbe_vocoder.a ]; then
    check_pass "IMBE vocoder library available"
else
    check_fail "IMBE vocoder library missing"
fi

if ldconfig -p | grep -q 'libftd2xx.so'; then
    check_pass "FTDI D2XX library available"
else
    check_warn "FTDI D2XX library missing; TCD stack may have been skipped"
fi

if [ -f /usr/local/include/ftd2xx.h ]; then
    check_pass "FTDI D2XX header present"
else
    check_warn "FTDI D2XX header missing; TCD stack may have been skipped"
fi

if [ -x /usr/local/bin/tcd ]; then
    if ldd /usr/local/bin/tcd 2>/dev/null | grep -q 'not found'; then
        check_fail "TCD has unresolved shared libraries"
    else
        check_pass "TCD shared libraries resolved"
    fi
else
    check_warn "TCD shared library check skipped; TCD not installed"
fi

if lsusb 2>/dev/null | grep -qi '0403:6015'; then
    check_pass "DVSI/FTDI USB device detected"
else
    check_warn "No DVSI/FTDI USB device currently detected"
fi


echo
echo "===== Dashboard ====="

check_file_warn "Public dashboard" "/var/www/html/urf/urfd/index.php"
check_file_warn "Sysop dashboard" "/var/www/html/urf/urfd/sysop/index.php"
check_php_lint_if_exists "Public dashboard" "/var/www/html/urf/urfd/index.php"
check_php_lint_if_exists "Sysop dashboard" "/var/www/html/urf/urfd/sysop/index.php"
check_php_lint_if_exists "Sysop health helper" "/var/www/html/urf/urfd/sysop/health.php"
check_php_lint_if_exists "Sysop service control endpoint" "/var/www/html/urf/urfd/sysop/service-control.php"
check_php_lint_if_exists "Sysop service config endpoint" "/var/www/html/urf/urfd/sysop/service-config.php"
check_php_lint_if_exists "Sysop service discovery endpoint" "/var/www/html/urf/urfd/sysop/service-discovery.php"

if [ -d /var/lib/urfd-dashboard ]; then
    check_pass "Dashboard state directory present: /var/lib/urfd-dashboard"
else
    check_fail "Dashboard state directory missing: /var/lib/urfd-dashboard"
fi

if command -v sudo >/dev/null 2>&1 && sudo -n -u www-data test -w /var/lib/urfd-dashboard 2>/dev/null; then
    check_pass "Dashboard state directory writable by dashboard"
else
    check_warn "Dashboard state directory may not be writable by dashboard"
fi

if [ -e /var/log/xlxd.xml ]; then
    check_pass "Live XML status: /var/log/xlxd.xml"
else
    check_warn "Live XML status missing; reflector may not have started yet"
fi
check_file "RadioID SQLite DB" "/var/lib/urfd-dashboard/radioid.sqlite"
check_file "RadioID importer" "/usr/local/bin/urfd-radioid-import"
check_file "RadioID updater" "/usr/local/bin/urfd-radioid-update"
check_file "Native health engine" "/usr/local/bin/urfd-health"
check_executable "RadioID importer" "/usr/local/bin/urfd-radioid-import"
check_executable "RadioID updater" "/usr/local/bin/urfd-radioid-update"
check_executable "Native health engine" "/usr/local/bin/urfd-health"
check_file "RadioID config" "/etc/urfd-dashboard/radioid.conf"
check_file "Dashboard config" "/etc/urfd-dashboard/dashboard.conf"

if [ -x /usr/local/bin/urfd-health ]; then
    if python3 -m py_compile /usr/local/bin/urfd-health >/dev/null 2>&1; then
        check_pass "Native health engine Python syntax valid"
    else
        check_fail "Native health engine Python syntax invalid"
    fi

    if /usr/local/bin/urfd-health --pretty >/dev/null 2>&1; then
        check_pass "Native health engine reports PASS"
    else
        HEALTH_RC="$?"
        if [ "$HEALTH_RC" = "1" ] || [ "$HEALTH_RC" = "2" ]; then
            check_warn "Native health engine reports degraded health"
        else
            check_fail "Native health engine failed to run"
        fi
    fi
fi

if [ -r /etc/urfd-dashboard/radioid.conf ]; then
    check_conf_key "RadioID DMR URL" "DMR_URL" "/etc/urfd-dashboard/radioid.conf"
    check_conf_key "RadioID NXDN URL" "NXDN_URL" "/etc/urfd-dashboard/radioid.conf"
    check_conf_key "RadioID P25 URL" "P25_URL" "/etc/urfd-dashboard/radioid.conf"
fi

if [ -r /etc/urfd-dashboard/dashboard.conf ]; then
    check_pass "Dashboard config readable"
    check_conf_key "Dashboard timezone" "TIMEZONE" "/etc/urfd-dashboard/dashboard.conf"
    check_conf_key "Dashboard logo" "DASHBOARD_LOGO" "/etc/urfd-dashboard/dashboard.conf"

    DASHBOARD_TZ="$(conf_value "TIMEZONE" "/etc/urfd-dashboard/dashboard.conf")"
    if [ -n "$DASHBOARD_TZ" ]; then
        if timedatectl list-timezones 2>/dev/null | grep -qx "$DASHBOARD_TZ" || [ -f "/usr/share/zoneinfo/$DASHBOARD_TZ" ]; then
            check_pass "Dashboard timezone valid: $DASHBOARD_TZ"
        else
            check_warn "Dashboard timezone may be invalid: $DASHBOARD_TZ"
        fi
    fi

    CH_ENABLED="$(conf_value "CALLING_HOME_ENABLED" "/etc/urfd-dashboard/dashboard.conf")"

    if [ "$CH_ENABLED" = "true" ]; then
        echo
        echo "===== XLX Calling Home / Directory Publishing ====="

        CH_DASH="$(conf_value "CALLING_HOME_DASHBOARD_URL" "/etc/urfd-dashboard/dashboard.conf")"
        CH_API="$(conf_value "CALLING_HOME_API_URL" "/etc/urfd-dashboard/dashboard.conf")"
        CH_HASH="$(conf_value "CALLING_HOME_HASH_FILE" "/etc/urfd-dashboard/dashboard.conf")"
        CH_INTERLINK="$(conf_value "CALLING_HOME_INTERLINK_FILE" "/etc/urfd-dashboard/dashboard.conf")"
        CH_LAST="$(conf_value "CALLING_HOME_LAST_FILE" "/etc/urfd-dashboard/dashboard.conf")"

        [ -n "$CH_DASH" ] && check_pass "Calling Home dashboard URL configured" || check_fail "Calling Home dashboard URL missing"
        [ -n "$CH_API" ] && check_pass "Calling Home API URL configured" || check_fail "Calling Home API URL missing"
        check_conf_key "Calling Home country" "CALLING_HOME_COUNTRY" "/etc/urfd-dashboard/dashboard.conf"
        check_conf_key "Calling Home comment" "CALLING_HOME_COMMENT" "/etc/urfd-dashboard/dashboard.conf"
        check_conf_key "Calling Home override IP" "CALLING_HOME_OVERRIDE_IP" "/etc/urfd-dashboard/dashboard.conf"
        check_conf_key "Calling Home last file" "CALLING_HOME_LAST_FILE" "/etc/urfd-dashboard/dashboard.conf"

        if [ -n "$CH_HASH" ] && [ -r "$CH_HASH" ]; then
            check_pass "Calling Home hash file readable: $CH_HASH"
            HASH_MODE="$(stat -c '%a' "$CH_HASH" 2>/dev/null || true)"
            HASH_OWNER="$(stat -c '%U:%G' "$CH_HASH" 2>/dev/null || true)"
            if [ "$HASH_MODE" = "600" ] && [ "$HASH_OWNER" = "root:root" ]; then
                check_pass "Calling Home hash file permissions root:root 600"
            else
                check_warn "Calling Home hash file permissions expected root:root 600; got ${HASH_OWNER:-unknown} ${HASH_MODE:-unknown}"
            fi
        else
            check_fail "Calling Home hash file missing or unreadable: ${CH_HASH:-unset}"
        fi

        if [ -n "$CH_INTERLINK" ] && [ -r "$CH_INTERLINK" ]; then
            check_pass "Calling Home interlink file readable: $CH_INTERLINK"
        else
            check_warn "Calling Home interlink file missing or unreadable: ${CH_INTERLINK:-unset}"
        fi

        if [ -n "$CH_LAST" ]; then
            CH_LAST_DIR="$(dirname "$CH_LAST")"
            if [ -d "$CH_LAST_DIR" ] && [ -w "$CH_LAST_DIR" ]; then
                check_pass "Calling Home last-file directory writable: $CH_LAST_DIR"
            elif [ -d "$CH_LAST_DIR" ]; then
                check_warn "Calling Home last-file directory may not be writable: $CH_LAST_DIR"
            else
                check_warn "Calling Home last-file directory missing: $CH_LAST_DIR"
            fi
        fi
    else
        check_pass "XLX Calling Home disabled by default"
    fi
fi

if [ -r /var/log/xlxd.xml ]; then
    check_pass "XML status readable"
    XML_AGE="$(( $(date +%s) - $(stat -c %Y /var/log/xlxd.xml 2>/dev/null || echo 0) ))"
    if [ "$XML_AGE" -le 90 ]; then
        check_pass "XML status fresh: ${XML_AGE}s old"
    else
        check_warn "XML status may be stale: ${XML_AGE}s old"
    fi
else
    check_warn "XML status not readable; reflector may not have started yet"
fi

DASH_CODE="$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost/urf/urfd/ 2>/dev/null || true)"
if echo "$DASH_CODE" | grep -q '^200$'; then
    check_pass "Public dashboard responds over HTTPS"
else
    check_warn "Public dashboard HTTPS check did not return 200 on https://localhost/urf/urfd/; got ${DASH_CODE:-no response}"
fi

if [ -r /var/lib/urfd-dashboard/radioid.sqlite ]; then
    INTEGRITY="$(sqlite3 /var/lib/urfd-dashboard/radioid.sqlite 'PRAGMA integrity_check;' 2>/dev/null || true)"
    if [ "$INTEGRITY" = "ok" ]; then
        check_pass "RadioID database integrity check passed"
    else
        check_fail "RadioID database integrity check failed: ${INTEGRITY:-no response}"
    fi

    if sqlite3 /var/lib/urfd-dashboard/radioid.sqlite "SELECT radioid, callsign, name, city, state, country, protocol, source FROM radioid LIMIT 1;" >/dev/null 2>&1; then
        check_pass "RadioID schema contains expected dashboard columns"
    else
        check_warn "RadioID schema missing expected dashboard columns"
    fi

    COUNT="$(sqlite3 /var/lib/urfd-dashboard/radioid.sqlite 'SELECT COUNT(*) FROM radioid;' 2>/dev/null || echo 0)"
    if [ "$COUNT" -gt 0 ]; then
        check_pass "RadioID records loaded: $COUNT"
    else
        check_warn "RadioID database exists but has no records"
    fi
else
    check_fail "RadioID database not readable"
fi

if [ -d /var/lib/urfd-dashboard/downloads ]; then
    check_pass "RadioID download directory present: /var/lib/urfd-dashboard/downloads"
else
    check_warn "RadioID download directory not present yet; created by updater when needed"
fi

echo
echo "===== Apache HTTPS ====="

if apache2ctl -S 2>/dev/null | grep -q ':443'; then
    check_pass "Apache HTTPS virtual host present"
else
    check_warn "Apache HTTPS virtual host not detected"
fi


echo
echo "===== Sysop Service Controls ====="

check_file "Service control helper" "/usr/local/bin/urfd-service-control"
check_file "Service config helper" "/usr/local/bin/urfd-service-config"
check_file "Sysop user helper" "/usr/local/bin/urfd-sysop-user"
check_file "Service control sudo policy" "/etc/sudoers.d/urfd-dashboard-service-control"
check_file "Service control action log" "/var/log/urfd-dashboard-actions.log"
check_file_warn "Sysop service control endpoint" "/var/www/html/urf/urfd/sysop/service-control.php"
check_file_warn "Sysop service config endpoint" "/var/www/html/urf/urfd/sysop/service-config.php"
check_file_warn "Sysop service discovery endpoint" "/var/www/html/urf/urfd/sysop/service-discovery.php"
check_file_warn "Sysop auth config" "/etc/apache2/conf-enabled/urfd-sysop-auth.conf"
check_file "Sysop auth password file" "/etc/apache2/.htpasswd-urfd-sysop"

if apache2ctl -S 2>/dev/null | grep -q 'urfd-sysop-auth'; then
    check_pass "Sysop auth Apache config loaded"
elif [ -e /etc/apache2/conf-enabled/urfd-sysop-auth.conf ]; then
    check_pass "Sysop auth Apache config enabled"
else
    check_warn "Sysop auth Apache config not enabled"
fi

AUTH_CODE="$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost/urf/urfd/sysop/ 2>/dev/null || true)"
if echo "$AUTH_CODE" | grep -q '^401$'; then
    check_pass "Sysop dashboard requires authentication"
else
    check_warn "Sysop dashboard authentication check did not return 401 on https://localhost/urf/urfd/sysop/; got ${AUTH_CODE:-no response}"
fi

AUTH_CODE_ROOT="$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost/sysop/ 2>/dev/null || true)"
if echo "$AUTH_CODE_ROOT" | grep -q '^401$'; then
    check_pass "Sysop dashboard root mapping requires authentication"
else
    check_warn "Sysop dashboard root mapping authentication check did not return 401 on https://localhost/sysop/; got ${AUTH_CODE_ROOT:-no response}"
fi

check_executable "Service control helper" "/usr/local/bin/urfd-service-control"
check_executable "Service config helper" "/usr/local/bin/urfd-service-config"
check_executable "Sysop user helper" "/usr/local/bin/urfd-sysop-user"

if command -v visudo >/dev/null 2>&1 && visudo -cf /etc/sudoers.d/urfd-dashboard-service-control >/dev/null 2>&1; then
    check_pass "Service control sudo policy valid"
else
    check_fail "Service control sudo policy invalid"
fi

if grep -Eq '^www-data .*NOPASSWD: /usr/local/bin/urfd-service-control$' /etc/sudoers.d/urfd-dashboard-service-control 2>/dev/null; then
    check_pass "Sudo policy allows service-control helper"
else
    check_warn "Sudo policy missing exact service-control helper entry"
fi

if grep -Eq '^www-data .*NOPASSWD: /usr/local/bin/urfd-service-config$' /etc/sudoers.d/urfd-dashboard-service-control 2>/dev/null; then
    check_pass "Sudo policy allows service-config helper"
else
    check_warn "Sudo policy missing exact service-config helper entry"
fi

if command -v sudo >/dev/null 2>&1 && sudo -n -u www-data test -w /var/log/urfd-dashboard-actions.log 2>/dev/null; then
    check_pass "Service control log writable by dashboard"
else
    check_warn "Service control log may not be writable by dashboard"
fi

if [ -e /var/log/urfd-dashboard-actions.log ]; then
    LOG_MODE="$(stat -c '%a' /var/log/urfd-dashboard-actions.log 2>/dev/null || true)"
    LOG_OWNER="$(stat -c '%U:%G' /var/log/urfd-dashboard-actions.log 2>/dev/null || true)"
    if [ "$LOG_MODE" = "640" ] && [ "$LOG_OWNER" = "www-data:adm" ]; then
        check_pass "Service control log permissions www-data:adm 640"
    else
        check_warn "Service control log permissions expected www-data:adm 640; got ${LOG_OWNER:-unknown} ${LOG_MODE:-unknown}"
    fi
fi

if [ -e /etc/apache2/.htpasswd-urfd-sysop ]; then
    HTPASSWD_MODE="$(stat -c '%a' /etc/apache2/.htpasswd-urfd-sysop 2>/dev/null || true)"
    HTPASSWD_OWNER="$(stat -c '%U:%G' /etc/apache2/.htpasswd-urfd-sysop 2>/dev/null || true)"
    if [ "$HTPASSWD_MODE" = "640" ] && [ "$HTPASSWD_OWNER" = "root:www-data" ]; then
        check_pass "Sysop auth password file permissions root:www-data 640"
    else
        check_warn "Sysop auth password file permissions expected root:www-data 640; got ${HTPASSWD_OWNER:-unknown} ${HTPASSWD_MODE:-unknown}"
    fi
fi

if [ -r /etc/urfd-dashboard/service-controls.conf ]; then
    check_pass "Custom service controls config present"
    if grep -Eq '^[^#[:space:]][^=]*=.*\.service([[:space:]]|$)' /etc/urfd-dashboard/service-controls.conf; then
        check_pass "Custom service controls config contains service entries"
    else
        check_warn "Custom service controls config has no service entries"
    fi
else
    check_warn "Custom service controls config not present"
fi

echo
echo "===== XLX Calling Home Timer ====="

if [ -d /var/lib/urfd ]; then
    check_pass "Calling Home state directory present: /var/lib/urfd"
else
    check_warn "Calling Home state directory missing: /var/lib/urfd"
fi

if systemctl list-unit-files | grep -q '^urfd-callinghome.service'; then
    check_pass "XLX Calling Home service installed"
else
    check_warn "XLX Calling Home service not installed"
fi

if systemctl list-unit-files | grep -q '^urfd-callinghome.timer'; then
    check_pass "XLX Calling Home timer installed"
else
    check_warn "XLX Calling Home timer not installed"
fi

if systemctl is-enabled --quiet urfd-callinghome.timer 2>/dev/null; then
    check_pass "XLX Calling Home timer enabled"
else
    check_warn "XLX Calling Home timer not enabled"
fi

if [ "$CH_ENABLED" = "true" ]; then
    check_file "XLX Calling Home publisher" "/usr/local/bin/urfd-callinghome"
    check_file "XLX Calling Home publisher source" "/var/www/html/urf/urfd/bin/urfd-callinghome"
    check_executable "XLX Calling Home publisher" "/usr/local/bin/urfd-callinghome"
    check_executable "XLX Calling Home publisher source" "/var/www/html/urf/urfd/bin/urfd-callinghome"
    check_php_lint "XLX Calling Home publisher source" "/var/www/html/urf/urfd/bin/urfd-callinghome"
else
    check_file_warn "XLX Calling Home publisher" "/usr/local/bin/urfd-callinghome"
    check_file_warn "XLX Calling Home publisher source" "/var/www/html/urf/urfd/bin/urfd-callinghome"
    check_executable_warn "XLX Calling Home publisher" "/usr/local/bin/urfd-callinghome"
    check_executable_warn "XLX Calling Home publisher source" "/var/www/html/urf/urfd/bin/urfd-callinghome"
    check_php_lint_if_exists "XLX Calling Home publisher source" "/var/www/html/urf/urfd/bin/urfd-callinghome"
fi

check_unit_file_contains "XLX Calling Home service ExecStart correct" "/etc/systemd/system/urfd-callinghome.service" '^ExecStart=/usr/local/bin/urfd-callinghome$'
check_unit_file_contains "XLX Calling Home service type oneshot" "/etc/systemd/system/urfd-callinghome.service" '^Type=oneshot$'
check_unit_file_contains "XLX Calling Home timer boot delay configured" "/etc/systemd/system/urfd-callinghome.timer" '^OnBootSec=2min$'
check_unit_file_contains "XLX Calling Home timer interval configured" "/etc/systemd/system/urfd-callinghome.timer" '^OnUnitActiveSec=10min$'
check_unit_file_contains "XLX Calling Home timer targets service" "/etc/systemd/system/urfd-callinghome.timer" '^Unit=urfd-callinghome.service$'

echo
echo "===== RadioID Timer ====="

if systemctl list-unit-files | grep -q '^urfd-radioid-update.service'; then
    check_pass "RadioID update service installed"
else
    check_warn "RadioID update service not installed"
fi

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

check_unit_file_contains "RadioID update service ExecStart correct" "/etc/systemd/system/urfd-radioid-update.service" '^ExecStart=/usr/local/bin/urfd-radioid-update$'
check_unit_file_contains "RadioID update service runs as root" "/etc/systemd/system/urfd-radioid-update.service" '^User=root$'
check_unit_file_contains "RadioID update timer schedule configured" "/etc/systemd/system/urfd-radioid-update.timer" '^OnCalendar=\*-\*-\* 02:15:00$'
check_unit_file_contains "RadioID update timer persistent" "/etc/systemd/system/urfd-radioid-update.timer" '^Persistent=true$'

echo
echo "===== Summary ====="
echo "PASS: $PASS"
echo "WARN: $WARN"
echo "FAIL: $FAIL"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi

exit 0
