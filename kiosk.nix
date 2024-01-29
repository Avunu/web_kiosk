{ lib, pkgs, envConfig, ... }:

{
  boot.initrd.systemd.network.wait-online.enable = true;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  hardware.enableRedistributableFirmware = true;
  isoImage.isoName = "kiosk.iso";
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  isoImage.squashfsCompression = "xz";
  networking.useNetworkd = true;
  networking.wireless = lib.optionalAttrs (envConfig.wifiSSID != "") {
    enable = true;
    networks."${envConfig.wifiSSID}".psk = envConfig.wifiPassword;
  };
  programs.firefox.enable = true;
  programs.light.enable = true;
  services.cage.enable = true;
  services.cage.program = "${pkgs.firefox}/bin/firefox -kiosk ${envConfig.startPage}";
  services.cage.user = "kiosk";
  services.getty.loginProgram = "${pkgs.coreutils}/bin/true";
  system.stateVersion = "23.11";
  systemd.network.enable = true;
  time.timeZone = envConfig.timeZone;
  users.users.kiosk.isNormalUser = true;
  zramSwap.enable = true;

  # Set screen brightness to maximum
  systemd.user.services.setMaxBrightness = {
    description = "Set Maximum Screen Brightness";
    serviceConfig.PassEnvironment = "DISPLAY";
    script = ''
      #!${pkgs.stdenv.shell}
      ${pkgs.light}/bin/light -S 100
    '';
    wantedBy = [ "basic.target" ];
    enabled = true;
  };
}
