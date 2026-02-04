{ lib, pkgs, envConfig, ... }:

{
  # Kernel configuration
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  boot.initrd.systemd.network.wait-online.enable = true;

  # Hardware support
  hardware.enableRedistributableFirmware = true;

  # Networking
  networking.useNetworkd = true;
  systemd.network.enable = true;
  networking.wireless = lib.optionalAttrs (envConfig.wifiSSID != "") {
    enable = true;
    networks."${envConfig.wifiSSID}".psk = envConfig.wifiPassword;
  };

  # Firefox kiosk with Cage Wayland compositor
  programs.firefox.enable = true;
  programs.light.enable = true;
  services.cage = {
    enable = true;
    program = "${pkgs.firefox}/bin/firefox -kiosk ${envConfig.startPage}";
    user = "kiosk";
  };

  # Disable login prompt (auto-login to cage)
  services.getty.loginProgram = "${pkgs.coreutils}/bin/true";

  # Timezone
  time.timeZone = envConfig.timeZone;

  # Kiosk user
  users.users.kiosk = {
    isNormalUser = true;
    # No password - kiosk auto-logs in
  };

  # Use zram for swap (no swap partition needed)
  zramSwap.enable = true;

  # Set screen brightness to maximum on startup
  systemd.user.services.brightness = {
    enable = true;
    description = "Set Maximum Screen Brightness";
    serviceConfig = {
      PassEnvironment = "DISPLAY";
      ExecStart = "${pkgs.light}/bin/light -S 100";
    };
    wantedBy = [ "graphical.target" ];
  };
}
