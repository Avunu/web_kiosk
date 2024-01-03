{ ... }:

let
  system = "x86_64-linux";

  fetchNixpkgs = builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs.git";
    ref = "nixos-23.11";
  };
  pkgs = import fetchNixpkgs { inherit system; };

  mobile-nixos = builtins.fetchGit {
    url = "https://github.com/NixOS/mobile-nixos.git";
    ref = "development";
  };

  wifiCredentials = import ./wifi-credentials.nix;
  kioskConfig = import ./kiosk.nix { inherit pkgs system wifiCredentials; };
  disableConfig = import ./disable.nix;
  tmpfsConfig = import ./tmpfs.nix;

  kiosk-image = (import "${mobile-nixos}/lib/eval-with-configuration.nix" {
    inherit pkgs;
    device = "uefi-x86_64";
    configuration = [ kioskConfig disableConfig tmpfsConfig ];
  }).outputs.disk-image;

in
kiosk-image
