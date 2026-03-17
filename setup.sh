#!/usr/bin/env bash
set -euo pipefail

echo "=== Web Kiosk Setup ==="
echo

# Start page
current_start_page="${START_PAGE:-}"
read -rp "Start page URL [${current_start_page:-https://www.google.com}]: " input_start_page
start_page="${input_start_page:-${current_start_page:-https://www.google.com}}"

# Time zone
echo
echo "Available time zones can be listed with: timedatectl list-timezones"
current_tz="${TIME_ZONE:-}"
read -rp "Time zone [${current_tz:-America/New_York}]: " input_tz
tz="${input_tz:-${current_tz:-America/New_York}}"

# Wi-Fi (optional)
echo
read -rp "Configure Wi-Fi? (y/N): " wifi_choice
wifi_ssid=""
wifi_password=""
if [[ "${wifi_choice,,}" == "y" ]]; then
  current_ssid="${WIFI_SSID:-}"
  read -rp "Wi-Fi SSID [${current_ssid:-}]: " input_ssid
  wifi_ssid="${input_ssid:-${current_ssid:-}}"
  if [[ -n "$wifi_ssid" ]]; then
    read -rsp "Wi-Fi password: " wifi_password
    echo
  fi
fi

# Write .env
cat > .env <<EOF
START_PAGE=$start_page
TIME_ZONE=$tz
WIFI_SSID=$wifi_ssid
WIFI_PASSWORD=$wifi_password
EOF

echo
echo "Configuration saved to .env"
echo

# Offer to build
read -rp "Build the ISO image now? (y/N): " build_choice
if [[ "${build_choice,,}" == "y" ]]; then
  echo "Building..."
  direnv reload
  nix build --impure
  echo
  echo "Done! ISO image: result/iso/"
fi
