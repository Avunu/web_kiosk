{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.kiosk = {
    startPage = lib.mkOption {
      type = lib.types.str;
      default = "https://www.google.com";
      description = "The URL to open in the kiosk browser.";
    };
    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "America/New_York";
      description = "The timezone for the kiosk system.";
    };
  };

  config = {
    # Hardware
    hardware.graphics.enable = true;

    # Programs
    programs = {
      firefox.enable = true;
      nano.enable = false;
    };

    # Services
    services = {
      cage = {
        enable = true;
        program = "${pkgs.firefox}/bin/firefox -kiosk ${config.kiosk.startPage}";
        user = "kiosk";
      };
      getty.loginProgram = "${pkgs.coreutils}/bin/true";
      logrotate.enable = lib.mkForce false;
      lvm.enable = false;
      openssh.enable = lib.mkForce false;
      pipewire.enable = false;
      pulseaudio.enable = false;
      rsyslogd.enable = false;
      syslog-ng.enable = false;
      udisks2.enable = false;
      xserver.enable = false;
    };

    # Users
    users.users.kiosk.isNormalUser = true;

    # Security
    security = {
      pam.services.su.forwardXAuth = lib.mkForce false;
      sudo.enable = lib.mkForce false;
      tpm2.enable = false;
    };

    # Systemd
    systemd = {
      coredump.enable = false;
      oomd.enable = false;
      services.systemd-journal-flush.enable = false;
      tpm2.enable = false;
      # Set screen brightness to maximum
      user.services.brightness = {
        enable = true;
        description = "Set Maximum Screen Brightness";
        serviceConfig = {
          PassEnvironment = "DISPLAY";
          ExecStart = "${pkgs.brightnessctl}/bin/brightnessctl set 100%";
        };
        wantedBy = [ "graphical.target" ];
      };
    };

    # Time
    time.timeZone = config.kiosk.timeZone;

    # XDG
    xdg = {
      autostart.enable = false;
      icons.enable = false;
      menus.enable = false;
      mime.enable = false;
      portal.enable = false;
      sounds.enable = false;
    };

    # Swap
    zramSwap.enable = true;

    # System
    system.stateVersion = "25.11";
  };
}
