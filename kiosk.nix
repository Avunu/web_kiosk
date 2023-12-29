{ pkgs, wifiCredentials, ... }:
{

  # imports = [
  #   ./disable.nix
  # ];

  fileSystems."/" = {
    options = [ "noatime" "data=writeback" "barrier=0" "commit=120" ];
  };

  networking = {
    wireless = {
      enable = true;
      networks = {
        "${wifiCredentials.wifiNetwork.ssid}".psk = wifiCredentials.wifiNetwork.psk;
      };
    };
  };

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  programs.firefox.enable = true;

  services = {
    # dbus.implementation = "broker";
    journald.storage = "none";
    cage = {
      enable = true;
      user = "user";
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
