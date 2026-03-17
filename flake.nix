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
                (
                  { lib, pkgs, ... }:
                  {
                    disabledModules = [
                      "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"
                      "${nixpkgs}/nixos/modules/profiles/base.nix"
                    ];

                    # ISO image
                    image.baseName = lib.mkForce "kiosk";
                    isoImage = {
                      compressImage = true;
                      makeEfiBootable = true;
                      makeUsbBootable = true;
                      squashfsCompression = "xz";
                      volumeID = "KIOSK";
                    };

                    # Boot
                    boot = {
                      initrd = {
                        kernelModules = [
                          "squashfs"
                          "iso9660"
                          "uas"
                          "overlay"
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
                      graphics.enable = true;
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

                    # Programs
                    programs = {
                      firefox.enable = true;
                      nano.enable = false;
                    };

                    # Services
                    services = {
                      cage = {
                        enable = true;
                        program = "${pkgs.firefox}/bin/firefox -kiosk ${startPage}";
                        user = "kiosk";
                      };
                      getty.loginProgram = "${pkgs.coreutils}/bin/true";
                      logrotate.enable = lib.mkForce false;
                      lvm.enable = false;
                      openssh.enable = lib.mkForce false;
                      pipewire.enable = false;
                      pulseaudio.enable = false;
                      rsyslogd.enable = false;
                      syslog-ng.enable = false;
                      udisks2.enable = false;
                      xserver.enable = false;
                    };

                    # Users
                    users.users.kiosk.isNormalUser = true;

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

                    # Security
                    security = {
                      pam.services.su.forwardXAuth = lib.mkForce false;
                      sudo.enable = lib.mkForce false;
                      tpm2.enable = false;
                    };

                    # System
                    system = {
                      extraDependencies = lib.mkForce [ ];
                      nssModules = lib.mkForce [ ];
                      stateVersion = "25.11";
                      switch.enable = false;
                    };

                    # Systemd
                    systemd = {
                      coredump.enable = false;
                      network.enable = true;
                      oomd.enable = false;
                      services.systemd-journal-flush.enable = false;
                      tpm2.enable = false;
                      # Set screen brightness to maximum
                      user.services.brightness = {
                        enable = true;
                        description = "Set Maximum Screen Brightness";
                        serviceConfig = {
                          PassEnvironment = "DISPLAY";
                          ExecStart = "${pkgs.brightnessctl}/bin/brightnessctl set 100%";
                        };
                        wantedBy = [ "graphical.target" ];
                      };
                    };

                    # Time
                    time.timeZone = timeZone;

                    # XDG
                    xdg = {
                      autostart.enable = false;
                      icons.enable = false;
                      menus.enable = false;
                      mime.enable = false;
                      portal.enable = false;
                      sounds.enable = false;
                    };

                    # Swap
                    zramSwap.enable = true;
                  }
                )
              ];
            }).config.system.build.isoImage;

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
