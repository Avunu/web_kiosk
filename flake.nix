{
  description = "A NixOS live image for kiosk";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
      wifiCredentials = import ./wifi-credentials.nix;
      kioskConfig = import ./kiosk.nix { inherit pkgs system wifiCredentials; };
      disableConfig = import ./disable.nix;
    in
    {
      defaultPackage.x86_64-linux = pkgs.nixos {
        configuration = { config, pkgs, ... }: {
          imports = [
            "${pkgs.path}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            kioskConfig
            disableConfig
          ];
        };
      }.config.system.build.isoImage;
    };
}
