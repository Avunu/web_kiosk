{
  description = "A NixOS live image for a Firefox web kiosk";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;

      envConfig = import ./build.env.nix;
      kioskConfig = import ./kiosk.nix { inherit lib pkgs envConfig; };
      disableConfig = import ./disable.nix;
      isoImage = import ./iso-image.nix { inherit pkgs; };

      nixosConfig = {
        imports = [
          kioskConfig
          disableConfig
          isoImage
        ];
        disabledModules =
          [
            <nixpkgs/nixos/modules/profiles/all-hardware.nix>
            <nixpkgs/nixos/modules/profiles/base.nix>
          ];
      };

      kioskIso = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ nixosConfig ];
      };

    in
    {
      packages.x86_64-linux.default = kioskIso.config.system.build.isoImage;
    };
}
