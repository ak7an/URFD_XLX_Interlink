#!/usr/bin/env bash
set -euo pipefail

echo "===== Installing Dashboard Configuration ====="

if [ "$EUID" -ne 0 ]; then
    echo "[FAIL] Please run as root"
    exit 1
fi

install -d -m 755 /etc/urfd-dashboard
install -d -m 755 /var/lib/urfd-dashboard
install -d -m 755 /var/lib/urfd

DEFAULT_TZ="$(timedatectl show -p Timezone --value 2>/dev/null || true)"
DEFAULT_TZ="${DEFAULT_TZ:-America/Denver}"

read -r -p "Dashboard timezone [$DEFAULT_TZ]: " DASHBOARD_TZ
DASHBOARD_TZ="${DASHBOARD_TZ:-$DEFAULT_TZ}"

if ! timedatectl list-timezones | grep -qx "$DASHBOARD_TZ" && [ ! -f "/usr/share/zoneinfo/$DASHBOARD_TZ" ]; then
    echo "[FAIL] Invalid timezone: $DASHBOARD_TZ"
    echo "Example: America/Denver"
    exit 1
fi

echo
read -r -p "Dashboard logo URL or local path [none]: " DASHBOARD_LOGO

echo
echo "===== Sysop Dashboard Authentication ====="
echo "The public dashboard remains open."
echo "The /sysop/ dashboard should be password protected."
echo

read -r -p "Sysop dashboard username [Admin1]: " SYSOP_AUTH_USER
SYSOP_AUTH_USER="${SYSOP_AUTH_USER:-Admin1}"

while true; do
    read -r -s -p "Sysop dashboard password: " SYSOP_AUTH_PASS
    echo
    read -r -s -p "Confirm sysop dashboard password: " SYSOP_AUTH_PASS_CONFIRM
    echo

    if [ -z "$SYSOP_AUTH_PASS" ]; then
        echo "[FAIL] Password cannot be blank"
        continue
    fi

    if [ "$SYSOP_AUTH_PASS" != "$SYSOP_AUTH_PASS_CONFIRM" ]; then
        echo "[FAIL] Passwords do not match"
        continue
    fi

    break
done

htpasswd -bc /etc/apache2/.htpasswd-urfd-sysop "$SYSOP_AUTH_USER" "$SYSOP_AUTH_PASS"
chmod 640 /etc/apache2/.htpasswd-urfd-sysop
chown root:www-data /etc/apache2/.htpasswd-urfd-sysop

cat > /etc/apache2/conf-available/urfd-sysop-auth.conf <<'EOF2'
<Location "/sysop/">
    AuthType Basic
    AuthName "URFD Sysop Dashboard"
    AuthUserFile /etc/apache2/.htpasswd-urfd-sysop
    Require valid-user
</Location>
EOF2

a2enconf urfd-sysop-auth >/dev/null


echo
echo "===== XLX Calling Home / Directory Publishing ====="
echo "Default is disabled."
echo "Enable only when ready for public XLX directory and host-file listing."
echo

read -r -p "Enable XLX Calling Home / directory publishing? [y/N]: " CHOICE
CHOICE="${CHOICE:-N}"

CALLING_HOME_ENABLED="false"
CALLING_HOME_DASHBOARD_URL=""
CALLING_HOME_API_URL="http://xlxapi.rlx.lu/api.php"
CALLING_HOME_COUNTRY=""
CALLING_HOME_COMMENT=""
CALLING_HOME_OVERRIDE_IP=""
CALLING_HOME_INTERLINK_FILE="/usr/local/etc/urfd.interlink"
CALLING_HOME_HASH_FILE="/var/lib/urfd/callinghome.hash"
CALLING_HOME_LAST_FILE="/var/lib/urfd/lastcallhome"

case "$CHOICE" in
    y|Y|yes|YES)
        CALLING_HOME_ENABLED="true"

        read -r -p "Public dashboard URL: " CALLING_HOME_DASHBOARD_URL
        read -r -p "Country code [US]: " CALLING_HOME_COUNTRY
        CALLING_HOME_COUNTRY="${CALLING_HOME_COUNTRY:-US}"

        read -r -p "Directory comment [URFD_XLX_Interlink Reflector]: " CALLING_HOME_COMMENT
        CALLING_HOME_COMMENT="${CALLING_HOME_COMMENT:-URFD_XLX_Interlink Reflector}"

        read -r -p "Override public IP address [blank for autodetect]: " CALLING_HOME_OVERRIDE_IP

        read -r -p "URFD interlink file [$CALLING_HOME_INTERLINK_FILE]: " TMP_INTERLINK
        CALLING_HOME_INTERLINK_FILE="${TMP_INTERLINK:-$CALLING_HOME_INTERLINK_FILE}"

        if [ -z "$CALLING_HOME_DASHBOARD_URL" ]; then
            echo "[FAIL] Public dashboard URL is required when Calling Home is enabled"
            exit 1
        fi

        if [ ! -f "$CALLING_HOME_HASH_FILE" ]; then
            LEGACY_HASH_FILE="/xlxd-ch/callinghome.php"

            if [ -r "$LEGACY_HASH_FILE" ]; then
                echo
                echo "Legacy XLXD Calling Home hash found:"
                echo "  $LEGACY_HASH_FILE"
                echo
                echo "Reuse this hash only when upgrading an existing listed XLXD reflector"
                echo "to URFD_XLX_Interlink. New reflectors should generate a new hash."
                echo

                read -r -p "Reuse existing legacy XLXD Calling Home hash? [y/N]: " REUSE_HASH
                REUSE_HASH="${REUSE_HASH:-N}"

                case "$REUSE_HASH" in
                    y|Y|yes|YES)
                        php -r '
                            include "/xlxd-ch/callinghome.php";
                            if (isset($Hash) && $Hash !== "") {
                                echo $Hash . PHP_EOL;
                            }
                        ' > "$CALLING_HOME_HASH_FILE"
                        ;;
                    *)
                        umask 077
                        tr -dc 'A-Za-z0-9' </dev/urandom | head -c 16 > "$CALLING_HOME_HASH_FILE"
                        echo >> "$CALLING_HOME_HASH_FILE"
                        ;;
                esac
            else
                umask 077
                tr -dc 'A-Za-z0-9' </dev/urandom | head -c 16 > "$CALLING_HOME_HASH_FILE"
                echo >> "$CALLING_HOME_HASH_FILE"
            fi
        fi

        chmod 600 "$CALLING_HOME_HASH_FILE"
        chown root:root "$CALLING_HOME_HASH_FILE" 2>/dev/null || true
        ;;
esac

cat > /etc/urfd-dashboard/dashboard.conf <<EOF2
# URFD Dashboard configuration
TIMEZONE=$DASHBOARD_TZ
DASHBOARD_LOGO=$DASHBOARD_LOGO

# XLX Calling Home / Directory Publishing
CALLING_HOME_ENABLED=$CALLING_HOME_ENABLED
CALLING_HOME_DASHBOARD_URL=$CALLING_HOME_DASHBOARD_URL
CALLING_HOME_API_URL=$CALLING_HOME_API_URL
CALLING_HOME_COUNTRY=$CALLING_HOME_COUNTRY
CALLING_HOME_COMMENT=$CALLING_HOME_COMMENT
CALLING_HOME_OVERRIDE_IP=$CALLING_HOME_OVERRIDE_IP
CALLING_HOME_INTERLINK_FILE=$CALLING_HOME_INTERLINK_FILE
CALLING_HOME_HASH_FILE=$CALLING_HOME_HASH_FILE
CALLING_HOME_LAST_FILE=$CALLING_HOME_LAST_FILE
EOF2

chmod 644 /etc/urfd-dashboard/dashboard.conf

echo
echo "[PASS] Dashboard timezone configured: $DASHBOARD_TZ"
echo "[PASS] XLX Calling Home enabled: $CALLING_HOME_ENABLED"
