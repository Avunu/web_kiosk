{ pkgs, envConfig, ... }:

{
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  hardware.enableRedistributableFirmware = true;
  isoImage.squashfsCompression = "xz";
  # networking.useNetworkd = true;
  networking.wireless =
    if envConfig.wifiSSID != "" then {
      enable = true;
      networks."${envConfig.wifiSSID}".psk = envConfig.wifiPassword;
    } else { };
  programs.firefox.enable = true;
  services.cage.enable = true;
  services.cage.program = "${pkgs.firefox}/bin/firefox -kiosk ${envConfig.startPage}";
  services.cage.user = "nixos";
  # services.getty.loginProgram = "${pkgs.coreutils}/bin/true";
  time.timeZone = envConfig.timeZone;
  zramSwap.enable = true;
}
