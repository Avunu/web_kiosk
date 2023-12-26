{ config
, lib
, pkgs
, modulesPath
, ...
}:
let
  wifiCredentials = import ./wifi-credentials.nix;
in
{

  # imports = [
  #   ./disable.nix
  # ];

  boot = {
    growPartition = true;
    initrd.availableKernelModules = [ "uas" ];
    kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [ "console=tty0" ];
    loader = {
      timeout = lib.mkDefault 0;
      grub = {
        device = "nodev";
        efiSupport = true;
        efiInstallAsRemovable = true;
      };
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    autoResize = true;
    options = [ "noatime" "data=writeback" "barrier=0" "commit=120" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
    autoResize = false;
  };

  system.build.raw = import "${toString modulesPath}/../lib/make-disk-image.nix" {
    inherit lib config pkgs;
    partitionTableType = "efi";
    diskSize = "auto";
    format = "raw";
  };

  hardware = {
    opengl.enable = true;
    # enableRedistributableFirmware = true;
  };

  networking = {
    # enableIntel2200BGFirmware = true;
    networkmanager.enable = false;
    useNetworkd = true;
    wireless = {
      enable = true;
      networks = {
        "${wifiCredentials.wifiNetwork.ssid}".psk = wifiCredentials.wifiNetwork.psk;
      };
    };
  };

  services = {
    dbus.implementation = "broker";
    journald.storage = "none";
    cage = {
      enable = true;
      user = "user";
      program =
        "${pkgs.cog}/bin/cog https://google.com";
    };
    openssh = {
      enable = true;
      extraConfig = ''
        PermitEmptyPasswords yes
      '';
    };
  };

  system = {
    autoUpgrade = {
      allowReboot = true;
      enable = true;
      rebootWindow = {
        lower = "01:00";
        upper = "05:00";
      };
    };
    stateVersion = "23.11";
  };

  # systemd.services."cage-tty1" = {
  #   after = [ "dev-dri-card0.device" ];
  #   wants = [ "dev-dri-card0.device" ];
  # };

  # fonts.enableDefaultPackages = true;
  # programs.cfs-zen-tweaks.enable = true;
  time.timeZone = "America/New_York";
  # zramSwap.enable = true;

  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "";
    home = "/home/user";
  };

}
