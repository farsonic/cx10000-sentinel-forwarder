#!/bin/bash
set -e

# Check if MAXMIND_ENABLED is truthy (e.g., "True", "true", or "1")
if [ "$MAXMIND_ENABLED" = "True" ] || [ "$MAXMIND_ENABLED" = "true" ] || [ "$MAXMIND_ENABLED" = "1" ]; then
    echo "[*] Creating /etc/GeoIP.conf..."
    cat <<EOF > /etc/GeoIP.conf
# GeoIP.conf file for \`geoipupdate\` program, for versions >= 3.1.1.
# Used to update GeoIP databases from https://www.maxmind.com.
# For more information about this config file, visit the docs at
# https://dev.maxmind.com/geoip/updating-databases.

AccountID ${MAXMIND_ACCOUNT_ID}
LicenseKey ${MAXMIND_LICENSE_KEY}
EditionIDs ${MAXMIND_EDITION_IDS}
EOF

    echo "[*] Running geoipupdate..."
    if ! geoipupdate; then
        echo "[!] geoipupdate failed, please check your GeoIP configuration."
    fi
else
    echo "[*] MAXMIND_ENABLED is false, skipping geoipupdate."
fi

echo "[*] Starting syslog forwarder..."
exec python3 syslog_forwarder.py
