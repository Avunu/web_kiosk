{
  description = "A NixOS live image for a Firefox web kiosk";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs =
    {
      self,
      nixpkgs,
      devenv,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } ({
      imports = [
        inputs.devenv.flakeModule
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        {
          config,
          pkgs,
          system,
          lib,
          ...
        }:
        let
          startPage = builtins.getEnv "START_PAGE";
          timeZone = builtins.getEnv "TIME_ZONE";
          wifiSSID = builtins.getEnv "WIFI_SSID";
          wifiPassword = builtins.getEnv "WIFI_PASSWORD";
        in
        {
          packages.default =
            (nixpkgs.lib.nixosSystem {
              inherit system;
              modules = [
                "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
                ./modules/kiosk.nix
                (
                  { lib, pkgs, ... }:
                  {
                    disabledModules = [
                      "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"
                      "${nixpkgs}/nixos/modules/profiles/base.nix"
                    ];

                    # Kiosk options
                    kiosk = {
                      startPage = if startPage != "" then startPage else "https://www.google.com";
                      timeZone = if timeZone != "" then timeZone else "America/New_York";
                    };

                    # ISO image
                    image.baseName = lib.mkForce "kiosk";
                    isoImage = {
                      compressImage = false;
                      makeEfiBootable = true;
                      makeUsbBootable = true;
                      squashfsCompression = "xz";
                      volumeID = "KIOSK";
                    };

                    # Boot
                    boot = {
                      initrd = {
                        kernelModules = [
                          # Device mapper (for squashfs overlay)
                          "dm-mod"
                          # Filesystems
                          "squashfs"
                          "iso9660"
                          "overlay"
                          # USB host controllers (+ PCI bindings)
                          "xhci_hcd"
                          "xhci_pci"
                          "ehci_hcd"
                          "ehci_pci"
                          "ohci_hcd"
                          "ohci_pci"
                          # USB storage
                          "uas"
                          "usb-storage"
                          # SATA/AHCI
                          "ahci"
                        ];
                        includeDefaultModules = false;
                        services.lvm.enable = false;
                        systemd = {
                          tpm2.enable = false;
                          network.wait-online.enable = true;
                        };
                      };
                      kernelPackages = pkgs.linuxPackages_latest;
                      supportedFilesystems = {
                        btrfs = lib.mkForce false;
                        cifs = lib.mkForce false;
                        ext3 = lib.mkForce false;
                        f2fs = lib.mkForce false;
                        ntfs3 = lib.mkForce false;
                        xfs = lib.mkForce false;
                        zfs = lib.mkForce false;
                      };
                      swraid.enable = lib.mkForce false;
                    };

                    # Hardware
                    hardware = {
                      enableRedistributableFirmware = true;
                      bluetooth.enable = false;
                    };

                    # Networking
                    networking = {
                      firewall.enable = false;
                      useNetworkd = true;
                      wireless = lib.optionalAttrs (wifiSSID != "") {
                        enable = true;
                        networks."${wifiSSID}".psk = wifiPassword;
                      };
                    };

                    # Documentation
                    documentation = {
                      doc.enable = false;
                      info.enable = false;
                      man.enable = false;
                      nixos.enable = false;
                    };

                    # Environment
                    environment = {
                      defaultPackages = [ ];
                      systemPackages = [ ];
                    };

                    # Fonts
                    fonts.fontconfig.enable = false;

                    # System
                    system = {
                      extraDependencies = lib.mkForce [ ];
                      nssModules = lib.mkForce [ ];
                      switch.enable = false;
                    };

                    # Systemd
                    systemd = {
                      network.enable = true;
                    };
                  }
                )
              ];
            }).config.system.build.isoImage;

          checks = lib.optionalAttrs pkgs.stdenv.isLinux {
            kiosk = import ./tests/kiosk.nix {
              inherit pkgs;
              kioskModule = ./modules/kiosk.nix;
              startPage = if startPage != "" then startPage else "https://www.google.com";
              timeZone = if timeZone != "" then timeZone else "America/New_York";
            };
          };

          devenv.shells.default =
            { config, pkgs, ... }:
            {
              scripts = {
                build = {
                  exec = ''
                    #!/usr/bin/env bash
                    nix build --impure
                  '';
                  description = "Build the ISO image";
                };
                setup = {
                  exec = builtins.readFile ./setup.sh;
                  description = "Interactive setup wizard for the kiosk";
                };
              };
            };
        };
    });
}
