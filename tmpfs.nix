{ config, pkgs, ... }:

{

  fileSystems."/home" = {
    fsType = "tmpfs";
    device = "tmpfs";
    options = [ "size=100M" ];
  };

  fileSystems."/tmp" = {
    fsType = "tmpfs";
    device = "tmpfs";
    options = [ "size=100M" ];
  };

  fileSystems."/var/log" = {
    fsType = "tmpfs";
    device = "tmpfs";
    options = [ "size=100M" ];
  };

  fileSystems."/var/cache" = {
    fsType = "tmpfs";
    device = "tmpfs";
    options = [ "size=100M" ];
  };

}
