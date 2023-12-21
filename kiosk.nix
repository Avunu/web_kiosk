{ config, pkgs, lib, ... }:

{
  # imports = [
  #   <nixpkgs/nixos/modules/profiles/base.nix>
  #   <nixpkgs/nixos/modules/installer/sd-card/sd-image.nix>
  # ];


  # imports = [
  #   <nixpkgs/nixos/modules/installer/sd-card/sd-image-x86_64.nix>
  # ];

  # sdImage = {
  #   populateFirmwareCommands = ''
  #     # Create the directories required for the EFI System Partition
  #     mkdir -p ./files/boot/efi

  #     # Install systemd-boot into the EFI System Partition
  #     ${pkgs.systemd}/bin/bootctl --path=./files/boot/efi install

  #     # Optionally, copy additional required files, like a custom loader.conf or entries
  #   '';

  #   populateRootCommands = ''
  #     # Place any necessary files on the root partition
  #   '';
  # };

  # boot.loader.grub = {
  #   enable = true;
  #   efiSupport = true;
  #   device = "nodev";
  #   efiInstallAsRemovable = true;
  # };

  # fileSystems = {
  #   "/boot" = {
  #     device = "/dev/disk/by-label/FIRMWARE";
  #     fsType = "vfat";
  #   };
  #   "/" = lib.mkDefault {
  #     device = "/dev/disk/by-label/NIXOS_SD";
  #     fsType = "ext4";
  #     autoResize = true;
  #   };
  # };

  # boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.generic-extlinux-compatible.enable = false;
  # boot.loader.grub.enable = false;
  # boot.loader.systemd-boot.enable = true;

  systemd.services.systemd-journald.enable = false;
  systemd.services.systemd-journal-flush.enable = false;
  services.journald.storage = "none";
  services.rsyslogd.enable = false;
  services.syslog-ng.enable = false;
  systemd.coredump.enable = false;
  systemd.oomd.enable = false;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  boot.kernelParams = [ "console=tty0" ];
  hardware.pulseaudio.enable = false;
  networking.enableIntel2200BGFirmware = true;
  networking.wireless.enable = true;
  networking.wireless.networks."Freedom is Coming".psk = builtins.readFile ./pass.txt;
  programs.firefox.enable = true;
  services.pipewire.enable = false;
  services.xserver.enable = false;
  system.autoUpgrade.allowReboot = true;
  system.autoUpgrade.enable = true;
  system.stateVersion = "23.11";
  time.timeZone = "America/New_York";
  zramSwap.enable = true;

  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "";
    home = "/home/user";
  };

  system.autoUpgrade.rebootWindow = {
    lower = "01:00";
    upper = "05:00";
  };

  services.cage = {
    enable = true;
    user = "user";
    program =
      "${pkgs.firefox}/bin/firefox -kiosk -private-window https://google.com";
  };
}
