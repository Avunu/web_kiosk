#!/usr/bin/env bash

# temporarily disable .gitignore so we can feed our env vars to nix
mv .gitignore .gitignore.disabled

# build the flake
nix build

# re-enable .gitignore
mv .gitignore.disabled .gitignore