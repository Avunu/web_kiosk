{ pkgs, envConfig, ... }:

let
  # Get environment variables
  startPage = envConfig.startPage;
  wifiSSID = envConfig.wifiNetwork.ssid;
  wifiPassword = envConfig.wifiNetwork.psk;

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
  system.switch.enable = false;
  time.timeZone = "America/New_York";
  zramSwap.enable = true;
}