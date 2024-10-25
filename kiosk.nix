{ lib, pkgs, ... }:

{
  hardware = {
    enableRedistributableFirmware = true;
  };
  networking = {
    useNetworkd = true;
    wireless =
      let
        ssid = builtins.getEnv "wifiSSID";
        password = builtins.getEnv "wifiPassword";
      in
      lib.optionalAttrs (ssid != "" && password != "") {
        enable = true;
        networks.${ssid}.psk = password;
      };
  };
  programs = {
    firefox.enable = true;
    light.enable = true;
  };
  services = {
    cage = {
      enable = true;
      program = "${pkgs.firefox}/bin/firefox -kiosk " + builtins.getEnv "startPage";
      user = "kiosk";
    };
    getty = {
      loginProgram = "${pkgs.coreutils}/bin/true";
    };
  };
  system = {
    stateVersion = "24.11";
  };
  systemd = {
    user.services = {
      brightness = {
        description = "Set Maximum Screen Brightness";
        enable = true;
        serviceConfig = {
          ExecStart = "${pkgs.light}/bin/light -S 100";
          PassEnvironment = "DISPLAY";
        };
        wantedBy = [ "graphical.target" ];
      };
    };
  };
  time = {
    timeZone = builtins.getEnv "timeZone";
  };
  users = {
    users = {
      kiosk = {
        isNormalUser = true;
      };
    };
  };
  zramSwap = {
    enable = true;
  };
}
