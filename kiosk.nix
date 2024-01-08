{ pkgs, envConfig, ... }:

let
  # Get environment variables
  startPage = envConfig.startPage;
  wifiSSID = envConfig.wifiSSID;
  wifiPassword = envConfig.wifiPassword;

  # Check if WiFi credentials are provided
  wirelessEnabled = wifiSSID != "";

  # Define wireless networks configuration
  wirelessConfig =
    if wirelessEnabled then
      {
        enable = true;
        networks = { "${wifiSSID}".psk = wifiPassword; };
      }
    else
      {
        enable = false;
      };
in
{
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  hardware.enableRedistributableFirmware = true;
  isoImage.squashfsCompression = "xz";
  networking.useNetworkd = true;
  networking.wireless = wirelessConfig;
  programs.firefox.enable = true;
  services.cage.enable = true;
  services.cage.program = "${pkgs.firefox}/bin/firefox -kiosk ${startPage}";
  services.cage.user = "nixos";
  services.getty.loginProgram = "${pkgs.coreutils}/bin/true";
  time.timeZone = envConfig.timeZone;
  zramSwap.enable = true;
}
