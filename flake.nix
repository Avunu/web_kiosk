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
                image.baseName = "kiosk";
                isoImage = {
                  volumeID = "KIOSK";
                  squashfsCompression = "xz";
                  makeEfiBootable = true;
                  makeUsbBootable = true;
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
                      enableTpm2 = false;
                      network.wait-online.enable = true;
                    };
                  };
                  kernelPackages = pkgs.linuxKernel.packages.linux_zen;
                  swraid.enable = lib.mkForce false;
                };

                # Hardware
                hardware = {
                  enableRedistributableFirmware = true;
                  bluetooth.enable = false;
                  pulseaudio.enable = false;
                };

                # Networking
                networking = {
                  firewall.enable = false;
                  useNetworkd = true;
                  wireless = lib.optionalAttrs (envConfig.wifiSSID != "") {
                    enable = true;
                    networks."${envConfig.wifiSSID}".psk = envConfig.wifiPassword;
                  };
                };

                # Programs
                programs = {
                  firefox.enable = true;
                  light.enable = true;
                  nano.enable = false;
                };

                # Services
                services = {
                  cage = {
                    enable = true;
                    program = "${pkgs.firefox}/bin/firefox -kiosk ${envConfig.startPage}";
                    user = "kiosk";
                  };
                  getty.loginProgram = "${pkgs.coreutils}/bin/true";
                  logrotate.enable = lib.mkForce false;
                  lvm.enable = false;
                  openssh.enable = lib.mkForce false;
                  pipewire.enable = false;
                  rsyslogd.enable = false;
                  syslog-ng.enable = false;
                  udisks2.enable = false;
                  xserver.enable = false;
                  zfs.trim.enable = lib.mkForce false;
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

                # Overlays
                nixpkgs.overlays = [
                  (final: super: {
                    zfs = super.zfs.overrideAttrs (_: {
                      meta.platforms = [ ];
                    });
                  })
                ];

                # Security
                security = {
                  pam.services.su.forwardXAuth = lib.mkForce false;
                  sudo.enable = lib.mkForce false;
                  tpm2.applyUdevRules = false;
                };

                # System
                system = {
                  extraDependencies = lib.mkForce [ ];
                  nssModules = lib.mkForce [ ];
                  stateVersion = "24.11";
                  switch.enable = false;
                };

                # Systemd
                systemd = {
                  coredump.enable = false;
                  network.enable = true;
                  oomd.enable = false;
                  services.systemd-journal-flush.enable = false;
                  # Set screen brightness to maximum
                  user.services.brightness = {
                    enable = true;
                    description = "Set Maximum Screen Brightness";
                    serviceConfig = {
                      PassEnvironment = "DISPLAY";
                      ExecStart = "${pkgs.light}/bin/light -S 100";
                    };
                    wantedBy = [ "graphical.target" ];
                  };
                };

                # Time
                time.timeZone = envConfig.timeZone;

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
              dotenv.enable = true;
              scripts = {
                build-image = {
                  exec = ''
                    #!/usr/bin/env bash
                    nix build --impure 
                  '';
                  description = "Build the ISO image";
                };
              };
            };
      }
    });
}