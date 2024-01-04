#!/usr/bin/env bash

# Check if the wifi-credentials.env file exists
if [ -f ./wifi-credentials.env ]; then
    # Load the WiFi credentials from the file
    export $(grep -v '^#' ./wifi-credentials.env | xargs)
fi

# Define arguments for Nix build command
buildArgs=()

# If WIFI_SSID and WIFI_PASSWORD are set, add them to build arguments
if [ -n "$WIFI_SSID" ] && [ -n "$WIFI_PASSWORD" ]; then
    buildArgs+=(--argstr wifiSSID "$WIFI_SSID")
    buildArgs+=(--argstr wifiPassword "$WIFI_PASSWORD")
fi

# Run the Nix build with the arguments
nix build .#defaultPackage.x86_64-linux "${buildArgs[@]}"
