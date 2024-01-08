{ lib, ... }:

{
  appstream.enable = false;
  boot = {
    initrd = {
      services.lvm.enable = false;
      systemd.enableTpm2 = false;
    };
    swraid.enable = lib.mkForce false;
  };
  environment.defaultPackages = [ ];
  environment.systemPackages = [ ];
  fonts.fontconfig.enable = false;
  hardware = {
    bluetooth.enable = false;
    pulseaudio.enable = false;
  };
  programs.nano.enable = false;
  networking = {
    dhcpcd.enable = false;
    firewall.enable = false;
    useNetworkd = true;
  };
  security = {
    pam.services.su.forwardXAuth = lib.mkForce false;
    # polkit.enable = lib.mkForce false;
    tpm2.applyUdevRules = false;
  };
  services = {
    logrotate.enable = lib.mkForce false;
    lvm.enable = false;
    nscd.enable = false;
    pipewire.enable = false;
    rsyslogd.enable = false;
    syslog-ng.enable = false;
    udev.enable = false;
    udisks2.enable = false;
    # upower.enable = false;
    xserver.enable = false;
  };
  sound.enable = false;
  system.nssModules = lib.mkForce [ ];
  system.switch.enable = false;
  systemd = {
    coredump.enable = false;
    oomd.enable = false;
    services = {
      systemd-journal-flush.enable = false;
    };
  };
  xdg = {
    autostart.enable = false;
    icons.enable = false;
    menus.enable = false;
    mime.enable = false;
    portal.enable = false;
    sounds.enable = false;
  };
}