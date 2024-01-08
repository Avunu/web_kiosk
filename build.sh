#!/usr/bin/env bash

# Check if the .env file exists
if [ -f ./.env ]; then
    # Load the environment variables from the .env file
    export $(cat .env | sed 's/#.*//g' | xargs)
else
    # Print an error message and exit
    echo "Error: copy .env.sample to .env and edit it to match your environment"
    exit 1
fi

# Specify the output filename
outputFilename="kiosk.iso"

# Run the Nix build with the arguments
nix-build ./default.nix -A config.system.build.isoImage -I nixos-config=./kiosk.nix -o ${outputFilename}
# nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=./nixpkgs.nix -I nixos-config=./kiosk.nix -o ${outputFilename}
