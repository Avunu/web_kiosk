{
  description = "Web Kiosk based on Mobile NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ ];
      };
      lib = pkgs.lib;
      mobile-nixos = builtins.fetchGit {
        url = "https://github.com/NixOS/mobile-nixos.git";
        rev = "ae159f5535d733169cfd92514c88684440caace9";
        narHash = "sha256-3EmjKFKBypRGluGEY1oUMkQRBRDO5rZdzUXwTlRbUiY=";
      };
      wifiCredentials = import ./wifi-credentials.nix;
      kioskConfig = import ./kiosk.nix { inherit pkgs wifiCredentials; };
      evalConfig = import "${pkgs.path}/nixos/lib/eval-config.nix";

      # Replicate logic from release-tools.nix
      mobileConfig = evalConfig {
        inherit system pkgs;
        baseModules = (import "${mobile-nixos}/modules/module-list.nix")
          ++ (import "${pkgs.path}/nixos/modules/module-list.nix");
        modules = [
          { imports = [ (mobile-nixos + "/devices/uefi-x86_64") ]; }
          kioskConfig
        ];
      };
    in
    {
      packages.x86_64-linux.kiosk-image = mobileConfig.config.system.build.toplevel;
    };
}
