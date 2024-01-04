{ pkgs, system, ... }:
let
  wifiSSID = builtins.getEnv "WIFI_SSID";
  wifiPassword = builtins.getEnv "WIFI_PASSWORD";
  wirelessEnabled = wifiSSID != "" && wifiPassword != "";

  # Define wireless networks configuration
  wirelessNetworks =
    if wirelessEnabled && wifiSSID != "" && wifiPassword != "" then
      { "${wifiSSID}".psk = wifiPassword; }
    else
      { };

  # Trace for debugging
  _ = builtins.trace "Configuring WiFi for SSID: ${wifiSSID}" wirelessEnabled;
in
{
  networking = {
    useDHCP = true;
    wireless = {
      enable = wirelessEnabled;
      networks = wirelessNetworks;
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
