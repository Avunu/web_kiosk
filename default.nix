{ ... }:

let
  system = "x86_64-linux";
  fetchNixpkgs = builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs.git";
    ref = "nixos-23.11";
  };
  pkgs = import fetchNixpkgs { inherit system; };

  wifiCredentialsPath = ./wifi-credentials.nix;
  wifiConfig = if builtins.pathExists wifiCredentialsPath then import wifiCredentialsPath else { };
  kioskConfig = import ./kiosk.nix { inherit pkgs system wifiConfig; };
  disableConfig = import ./disable.nix;

in
pkgs.nixos {
  configuration = {
    imports = [
      kioskConfig
      disableConfig
      "${pkgs.path}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    ];
  };
}.config.system.build.isoImage
