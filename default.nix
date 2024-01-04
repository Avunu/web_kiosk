{ ... }:

let
  # Specify the NixOS version
  system = "x86_64-linux";
  fetchNixpkgs = builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs.git";
    ref = "nixos-23.11"; # Specify the desired branch
  };
  pkgs = import fetchNixpkgs { inherit system; };

  # Environment variables
  wifiSSID = builtins.getEnv "WIFI_SSID";
  wifiPassword = builtins.getEnv "WIFI_PASSWORD";
  startPage = builtins.getEnv "START_PAGE";

  # Check if WiFi credentials are provided
  wirelessEnabled = wifiSSID != "" && wifiPassword != "";

  # Define wireless networks configuration
  wirelessNetworks =
    if wirelessEnabled then
      { "${wifiSSID}".psk = wifiPassword; }
    else
      { };

in pkgs.nixos {
  configuration = {
    imports = [
      "${pkgs.path}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    ];

    networking = {
      useDHCP = true;
      wireless = if wirelessEnabled then { enable = true; networks = wirelessNetworks; } else {};
    };

    boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    hardware.enableRedistributableFirmware = true;
    programs.firefox.enable = true;

    services.cage = {
      enable = true;
      user = "nixos";
      program = "${pkgs.firefox}/bin/firefox -kiosk -private-window ${startPage}";
    };

    system.stateVersion = "23.11";
    time.timeZone = "America/New_York";
    zramSwap.enable = true;
  };
}.config.system.build.isoImage
