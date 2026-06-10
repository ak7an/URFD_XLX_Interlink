#!/usr/bin/env bash
set -euo pipefail

SRC="reflector/urfd.ini"
OUT="reflector/urfd.ini.generated"

ask() {
    local prompt="$1"
    local default="$2"
    local value

    read -r -p "$prompt [$default]: " value
    echo "${value:-$default}"
}

replace_key() {
    local key="$1"
    local value="$2"
    perl -0pi -e "s/^(${key}\s*=\s*).*\$/\${1}${value}/m" "$OUT"
}

echo "===== URFD_XLX_Interlink Guided Configurator ====="
echo
echo "This creates:"
echo "  $OUT"
echo
echo "It does NOT overwrite your live urfd.ini."
echo

cp "$SRC" "$OUT"

REF_NUM="$(ask "Reflector number" "277")"
CALLSIGN="$(ask "Reflector callsign" "URF${REF_NUM}")"
SYSOP_EMAIL="$(ask "Sysop email" "sysop@example.com")"
COUNTRY="$(ask "Country code" "US")"
SPONSOR="$(ask "Sponsor / organization" "My Reflector")"
DASHBOARD_URL="$(ask "Dashboard URL" "https://xlx${REF_NUM}.example.com")"
EXTERNAL_IP="$(ask "External IPv4 address" "0.0.0.0")"
MODULES="$(ask "Enabled modules" "A")"
TRANSCODE_MODULES="$(ask "Transcoded module(s)" "A")"

NXDN_ID="$(ask "NXDN Reflector ID / TG" "21277")"
P25_ID="$(ask "P25 Reflector ID / TG" "21277")"
YSF_ID="$(ask "YSF Registration ID" "21277")"
YSF_NAME="$(ask "YSF Registration Name" "US URF${REF_NUM}")"

echo
echo "Writing generated config..."

replace_key "Callsign" "$CALLSIGN     # where ? is A-Z or 0-9. NO EXCEPTIONS!"
replace_key "SysopEmail" "$SYSOP_EMAIL"
replace_key "Country" "$COUNTRY"
replace_key "Sponsor" "$SPONSOR"
replace_key "DashboardUrl" "$DASHBOARD_URL"
replace_key "IPv4External" "$EXTERNAL_IP"
replace_key "Modules" "$MODULES"
replace_key "DescriptionA" "All Modes"

# Transcoder section Modules is the second Modules key, so handle by section.
perl -0pi -e "s/(\[Transcoder\].*?Modules\s*=\s*).*/\${1}${TRANSCODE_MODULES} # Transcoded modules one or three modules, depending on the hardware/s" "$OUT"

perl -0pi -e "s/(\[NXDN\].*?ReflectorID\s*=\s*).*/\${1}${NXDN_ID}/s" "$OUT"
perl -0pi -e "s/(\[P25\].*?ReflectorID\s*=\s*).*/\${1}${P25_ID}/s" "$OUT"
perl -0pi -e "s/(\[YSF\].*?RegistrationID\s*=\s*).*/\${1}${YSF_ID}/s" "$OUT"
perl -0pi -e "s/(\[YSF\].*?RegistrationName\s*=\s*).*/\${1}${YSF_NAME}/s" "$OUT"

echo
echo "[PASS] Generated: $OUT"
echo
echo "Review it with:"
echo "  diff -u $SRC $OUT"
echo
echo "To install later:"
echo "  sudo cp $OUT $SRC"
