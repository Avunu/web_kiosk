{ ... }:

let
  system = "x86_64-linux";
  fetchNixpkgs = builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs.git";
    ref = "nixos-23.11"; # Specify the desired branch
  };
  pkgs = import fetchNixpkgs { inherit system; };
in
{ ... }: {
  imports = [ ./kiosk.nix ];
}
