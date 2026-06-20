#!/usr/bin/env bash
set -euo pipefail

SRC="config/urfd.ini"
OUT="config/urfd.ini.generated"

ask() {
    local prompt="$1"
    local default="$2"
    local value

    read -r -p "$prompt [$default]: " value
    echo "${value:-$default}"
}

echo "===== URFD_XLX_Interlink Guided Configurator ====="
echo
echo "This creates:"
echo "  $OUT"
echo
echo "It does NOT overwrite your live urfd.ini."
echo

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

python3 - "$SRC" "$OUT" <<PY
from pathlib import Path
import sys

src = Path(sys.argv[1])
out = Path(sys.argv[2])

values = {
    ("Names", "Callsign"): "${CALLSIGN}     # where ? is A-Z or 0-9. NO EXCEPTIONS!",
    ("Names", "SysopEmail"): "${SYSOP_EMAIL}",
    ("Names", "Country"): "${COUNTRY}",
    ("Names", "Sponsor"): "${SPONSOR}",
    ("Names", "DashboardUrl"): "${DASHBOARD_URL}",
    ("IP Addresses", "IPv4External"): "${EXTERNAL_IP}",
    ("Modules", "Modules"): "${MODULES}",
    ("Modules", "DescriptionA"): "All Modes",
    ("Transcoder", "Modules"): "${TRANSCODE_MODULES} # Transcoded modules one or three modules, depending on the hardware",
    ("NXDN", "ReflectorID"): "${NXDN_ID}",
    ("P25", "ReflectorID"): "${P25_ID}",
    ("YSF", "RegistrationID"): "${YSF_ID}",
    ("YSF", "RegistrationName"): "${YSF_NAME}",
}

section = None
new_lines = []

for line in src.read_text().splitlines():
    stripped = line.strip()

    if stripped.startswith("[") and stripped.endswith("]"):
        section = stripped[1:-1]
        new_lines.append(line)
        continue

    if "=" in line and section:
        key = line.split("=", 1)[0].strip()
        if (section, key) in values:
            prefix = line.split("=", 1)[0]
            line = f"{prefix}= {values[(section, key)]}"

    new_lines.append(line)

out.write_text("\\n".join(new_lines) + "\\n")
PY

echo
echo "[PASS] Generated: $OUT"
echo
echo "Review it with:"
echo "  diff -u $SRC $OUT"
echo
echo "To install later:"
echo "  sudo cp $OUT /usr/local/etc/urfd.ini"
