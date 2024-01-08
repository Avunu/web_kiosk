#!/usr/bin/env bash

# copy the git ignored variables to the build environment
cp build.env.nix build.env.nix.tmp
cp env.nix build.env.nix

# build the project
nix build --impure --extra-experimental-features 'nix-command flakes' 

# restore the git ignored variables
cp build.env.nix env.nix
cp build.env.nix.tmp build.env.nix
rm build.env.nix.tmp