#!/usr/bin/env bash

# Add env.nix to the Nix store
ENV_NIX_PATH=$(nix-store --add ./env.nix)

# Build the flake
nix build .#default --impure --expr "let
  envConfig = import \"${ENV_NIX_PATH}\";
in
(import ./. {}).packages.x86_64-linux.default { inherit envConfig; }"
