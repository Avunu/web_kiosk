{
  description = "Web Kiosk based on Mobile NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      # Fetch Mobile NixOS as a git repository
      mobile-nixos = builtins.fetchGit {
        url = "https://github.com/NixOS/mobile-nixos.git";
        ref = "development";
      };
    in
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ ];
        };
        kioskConfig = import ./kiosk.nix { inherit pkgs; };
        mobileNixOSExpr = import "${mobile-nixos}/default.nix" {
          inherit system pkgs;
          configuration = kioskConfig;
          device = "uefi-x86_64";
        };
      in
      {
        packages.mobile-nixos-image = mobileNixOSExpr;
      }
    );
}
