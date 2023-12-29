#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch-git

repo_url="https://github.com/NixOS/mobile-nixos.git"
json=$(nix-prefetch-git $repo_url)

rev=$(echo "$json" | jq -r '.rev')
sha256=$(echo "$json" | jq -r '.hash')

echo "Rev: $rev"
echo "Hash: $sha256"
