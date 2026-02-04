#!/usr/bin/env bash
set -euo pipefail

# Web Kiosk Image Builder
# This script builds a bootable disk image with disko

# Check for .env file
if [ ! -f ".env" ]; then
    echo "Error: .env file not found."
    echo "Copy .env.example to .env and configure it:"
    echo "  cp .env.example .env"
    exit 1
fi

# Source the .env file (export all variables)
echo "Loading configuration from .env..."
set -a
source .env
set +a

# Validate required variables
if [ -z "${KIOSK_START_PAGE:-}" ]; then
    echo "Error: KIOSK_START_PAGE is not set in .env"
    exit 1
fi

if [ -z "${KIOSK_TIMEZONE:-}" ]; then
    echo "Error: KIOSK_TIMEZONE is not set in .env"
    exit 1
fi

echo "Configuration:"
echo "  Start Page: $KIOSK_START_PAGE"
echo "  Timezone:   $KIOSK_TIMEZONE"
echo "  WiFi SSID:  ${KIOSK_WIFI_SSID:-<disabled>}"
echo ""

# Build the disko image script (--impure needed for env vars)
echo "Building disk image script..."
nix build --impure --experimental-features 'nix-command flakes'

echo ""
echo "Build complete! To create the disk image, run:"
echo "  sudo ./result --build-memory 2048"
echo ""
echo "After the image is created, flash it to a USB drive:"
echo "  zstd -d web-kiosk.raw.zst -o - | sudo dd of=/dev/sdX bs=4M status=progress"
