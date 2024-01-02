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

  kiosk-image = (import "${mobile-nixos}/lib/eval-with-configuration.nix" {
    inherit pkgs;
    device = "uefi-x86_64";
    configuration = [ kioskConfig ];
  }).outputs.disk-image;

in
kiosk-image
