{ pkgs, system, wifiCredentials, ... }:
{

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SYSTEM";
    fsType = "ext4";
    autoResize = true;
    options = [ "noatime" "data=writeback" "barrier=0" "commit=120" ];
  };

  networking = {
    useDHCP = true;
    wireless = {
      enable = true;
      networks = {
        "${wifiCredentials.wifiNetwork.ssid}".psk = wifiCredentials.wifiNetwork.psk;
      };
    };
  };

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  hardware.enableRedistributableFirmware = true;
  programs.firefox.enable = true;

  services = {
    dbus.implementation = "broker";
    journald.storage = "volatile";
    cage = {
      enable = true;
      user = "user";
      environment = {
        "WLR_RENDERER" = "gles2";
        "WLR_BACKENDS" = "libinput,drm";
        "WLR_RENDERER_ALLOW_SOFTWARE" = "0";
        "XCURSOR_PATH" = "/dev/null";
      };
      program =
        "${pkgs.firefox}/bin/firefox -kiosk -private-window https://google.com";
    };
    openssh = {
      enable = true;
      extraConfig = ''
        PermitEmptyPasswords yes
      '';
    };
  };

  system.stateVersion = "23.11";

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
