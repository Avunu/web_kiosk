{ lib, pkgs, envConfig, ... }:

{
  boot.initrd.systemd.network.wait-online.enable = true;
  # boot.kernelPackages = pkgs.linuxKernm el.packages.linux_zen;
  hardware.enableRedistributableFirmware = true;
  isoImage.squashfsCompression = "xz";
  networking.useNetworkd = true;
  networking.wireless = lib.optionalAttrs (envConfig.wifiSSID != "") {
    enable = true;
    networks."${envConfig.wifiSSID}".psk = envConfig.wifiPassword;
  };
  programs.firefox.enable = true;
  services.cage.enable = true;
  services.cage.program = "${pkgs.firefox}/bin/firefox -kiosk ${envConfig.startPage}";
  services.cage.user = "nixos";
  systemd.network.enable = true;
  # services.getty.loginProgram = "${pkgs.coreutils}/bin/true";
  time.timeZone = envConfig.timeZone;
  zramSwap.enable = true;
}
