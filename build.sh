#!/usr/bin/env bash

# copy the git ignored variables to the build environment
mv build.env.nix build.env.nix.tmp
mv env.nix build.env.nix

# build the project
nix build

# restore the git ignored variables
mv build.env.nix env.nix
mv build.env.nix.tmp build.env.nix