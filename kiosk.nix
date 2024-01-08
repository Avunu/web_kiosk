{ config, pkgs, ... }:

let
  # Get environment variables
  wifiSSID = builtins.getEnv "WIFI_SSID";
  wifiPassword = builtins.getEnv "WIFI_PASSWORD";
  startPage = builtins.getEnv "START_PAGE";

  # Check if WiFi credentials are provided
  wirelessEnabled = wifiSSID != "" && wifiPassword != "";

  # Define wireless networks configuration
  wirelessConfig =
    if wirelessEnabled then
      {
        enable = true;
        networks = { "${wifiSSID}".psk = wifiPassword; };
      }
    else
      { };
in
{
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  hardware.enableRedistributableFirmware = true;
  imports = [
    "${pkgs.path}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    ./disable.nix
  ];
  isoImage.squashfsCompression = "lz4";
  networking.wireless = wirelessConfig;
  programs.firefox.enable = true;
  services.cage.enable = true;
  services.cage.program = "${pkgs.firefox}/bin/firefox -kiosk -private-window ${startPage}";
  services.cage.user = "nixos";
  system.stateVersion = "23.11";
  system.switch.enable = false;
  time.timeZone = "America/New_York";
  zramSwap.enable = true;
}
