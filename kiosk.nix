{ pkgs, system, ... }:
let
  wifiCredentialsPath = ./wifi-credentials.nix;
  wirelessEnabled = true;
  wifiNetworks =
    if wirelessEnabled
    then
      let credentials = import wifiCredentialsPath;
      in { "${credentials.wifiNetwork.ssid}".psk = credentials.wifiNetwork.psk; }
    else { };
in
{
  networking = {
    useDHCP = true;
    wireless = {
      enable = wirelessEnabled;
      networks = wifiNetworks;
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
      user = "nixos";
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
  zramSwap.enable = true;

}
