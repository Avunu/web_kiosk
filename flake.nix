{
  description = "A NixOS disk image for a Firefox web kiosk";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;

      # Read environment variables (requires --impure flag)
      # These are set by sourcing .env before building
      envConfig = {
        startPage = builtins.getEnv "KIOSK_START_PAGE";
        timeZone = builtins.getEnv "KIOSK_TIMEZONE";
        wifiSSID = builtins.getEnv "KIOSK_WIFI_SSID";
        wifiPassword = builtins.getEnv "KIOSK_WIFI_PASSWORD";
      };

      # Validate required settings
      validateConfig = config:
        if config.startPage == "" then
          throw "KIOSK_START_PAGE environment variable is required. Source your .env file first."
        else if config.timeZone == "" then
          throw "KIOSK_TIMEZONE environment variable is required. Source your .env file first."
        else
          config;

      validatedConfig = validateConfig envConfig;

    in {
      nixosConfigurations.web-kiosk = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { envConfig = validatedConfig; };
        modules = [
          # Disko for disk partitioning
          disko.nixosModules.disko
          ./disko-config.nix

          # Kiosk configuration
          ./kiosk.nix

          # Minimal system - disable unnecessary services
          ./disable.nix

          # Disko image builder settings
          ({ config, pkgs, lib, ... }: {
            # Use GRUB for both BIOS and UEFI boot
            boot.loader.grub = {
              enable = true;
              efiSupport = true;
              efiInstallAsRemovable = true;
              device = "nodev"; # For GPT disks, disko handles this
            };
            boot.loader.efi.canTouchEfiVariables = false;

            # Disko image builder configuration
            disko.imageBuilder = {
              extraDependencies = [ pkgs.f2fs-tools ];
              # Compress the output image
              extraPostVM = ''
                ${pkgs.zstd}/bin/zstd --compress $out/*.raw
                rm $out/*.raw
              '';
            };

            # Basic system settings
            system.stateVersion = "24.11";
            networking.hostName = "web-kiosk";
          })
        ];
      };

      packages.${system} = {
        # Build script that creates the disk image
        # Usage: source .env && nix build --impure && sudo ./result --build-memory 2048
        default = self.nixosConfigurations.web-kiosk.config.system.build.diskoImagesScript;
        
        # Alternative: build image in nix sandbox (slower, no secrets)
        diskoImages = self.nixosConfigurations.web-kiosk.config.system.build.diskoImages;
      };

      # Development shell with useful tools
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          zstd
          qemu
        ];
        shellHook = ''
          if [ -f .env ]; then
            set -a
            source .env
            set +a
            echo "Loaded .env file"
          else
            echo "Warning: .env file not found. Copy .env.example to .env and configure it."
          fi
          echo ""
          echo "Web Kiosk Development Environment"
          echo ""
          echo "Build commands:"
          echo "  nix build --impure  - Build the disk image script"
          echo "  sudo ./result       - Run the script to create the image"
          echo ""
          echo "Flash to USB:"
          echo "  zstd -d web-kiosk.raw.zst | sudo dd of=/dev/sdX bs=4M status=progress"
        '';
      };
    };
}
