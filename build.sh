#!/usr/bin/env bash

if [ ! -f .env ]; then
	echo ".env file not found!"
	exit 1
fi

source .env

# build the project
nix build --impure --experimental-features 'nix-command flakes'