{
  description = "A NixOS live image for a Firefox web kiosk";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
    in
    {
      packages.${system}.default =
        (nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (
              {
                config,
                lib,
                pkgs,
                ...
              }:
              {
                # Core system configuration
                appstream.enable = false;

                boot = {
                  initrd = {
                    availableKernelModules = [
                      "isofs"
                      "squashfs"
                      "overlay"
                    ];
                    services.lvm.enable = false;
                    systemd.enableTpm2 = false;
                    includeDefaultModules = false;
                  };
                  kernelPackages = pkgs.linuxPackages_latest;
                  loader.grub = {
                    enable = true;
                    efiSupport = true;
                    device = "nodev";
                  };
                  swraid.enable = lib.mkForce false;
                };

                documentation = {
                  doc.enable = false;
                  info.enable = false;
                  man.enable = false;
                  nixos.enable = false;
                };

                environment = {
                  defaultPackages = [ ];
                  systemPackages = [ ];
                };

                fileSystems."/" = {
                  device = "none";
                  fsType = "tmpfs";
                  options = [
                    "defaults"
                    "mode=755"
                  ];
                };

                fonts.fontconfig.enable = false;

                hardware = {
                  bluetooth.enable = false;
                  enableRedistributableFirmware = true;
                  pulseaudio.enable = false;
                };

                networking = {
                  useNetworkd = true;
                  wireless =
                    let
                      ssid = builtins.getEnv "wifiSSID";
                      password = builtins.getEnv "wifiPassword";
                    in
                    lib.optionalAttrs (ssid != "" && password != "") {
                      enable = true;
                      networks.${ssid}.psk = password;
                    };
                };

                nixpkgs = {
                  hostPlatform = system;
                  overlays = [
                    (final: super: {
                      zfs = super.zfs.overrideAttrs (_: {
                        meta.platforms = [ ];
                      });
                    })
                  ];
                };

                programs = {
                  firefox.enable = true;
                  light.enable = true;
                  nano.enable = false;
                };

                security = {
                  pam.services.su.forwardXAuth = lib.mkForce false;
                  sudo.enable = lib.mkForce false;
                  tpm2.applyUdevRules = false;
                };

                services = {
                  cage = {
                    enable = true;
                    program = "${pkgs.firefox}/bin/firefox -kiosk " + builtins.getEnv "startPage";
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
                };

                system = {
                  extraDependencies = lib.mkForce [ ];
                  nssModules = lib.mkForce [ ];
                  stateVersion = "24.11";
                  switch.enable = false;
                  # ISO image build configuration
                  build.isoImage = pkgs.callPackage "${pkgs.path}/nixos/lib/make-iso9660-image.nix" {
                    contents = [
                      {
                        source = "${config.boot.kernelPackages.kernel}/bzImage";
                        target = "/boot/bzImage";
                      }
                      {
                        source = "${config.system.build.initialRamdisk}/initrd";
                        target = "/boot/initrd";
                      }
                      {
                        source = "${pkgs.syslinux}/share/syslinux/isolinux.bin";
                        target = "/boot/isolinux.bin";
                      }
                      {
                        source = "${pkgs.syslinux}/share/syslinux/isohdpfx.bin";
                        target = "/boot/isohdpfx.bin";
                      }
                    ];
                    storeContents = [
                      {
                        object = config.boot.kernelPackages.kernel;
                        symlink = "/kernel";
                      }
                      {
                        object = config.system.build.initialRamdisk;
                        symlink = "/initrd";
                      }
                      {
                        object = config.system.build.toplevel;
                        symlink = "/system";
                      }
                    ];
                    isoName = "kiosk.iso";
                    volumeID = "KIOSK";
                    squashfsCompression = "xz";
                    bootable = true;
                    bootImage = "/boot/isolinux.bin";
                    efiBootable = true;
                    efiBootImage = "boot/efi.img";
                    isohybridMbrImage = "/boot/isohdpfx.bin";
                    usbBootable = true;
                    syslinux = pkgs.syslinux;
                  };
                };

                systemd = {
                  coredump.enable = false;
                  oomd.enable = false;
                  services = {
                    systemd-journal-flush.enable = false;
                  };
                  user.services.brightness = {
                    description = "Set Maximum Screen Brightness";
                    enable = true;
                    serviceConfig = {
                      ExecStart = "${pkgs.light}/bin/light -S 100";
                      PassEnvironment = "DISPLAY";
                    };
                    wantedBy = [ "graphical.target" ];
                  };
                };

                time.timeZone = builtins.getEnv "timeZone";

                users.users.kiosk = {
                  isNormalUser = true;
                };

                xdg = {
                  autostart.enable = false;
                  icons.enable = false;
                  menus.enable = false;
                  mime.enable = false;
                  portal.enable = false;
                  sounds.enable = false;
                };

                zramSwap.enable = true;
              }
            )
          ];
        }).config.system.build.isoImage;
    };
}
