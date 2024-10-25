{ config, lib, pkgs, ... }:

{
  imports = [ ];

  boot = {
    initrd.availableKernelModules = [ "isofs" "squashfs" "overlay" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  system.build = {
    isoImage = pkgs.callPackage "${pkgs.path}/nixos/lib/make-iso9660-image.nix" {
      contents = [
        {
          source = "${config.boot.kernelPackages.kernel}/bzImage";
          target = "/boot/bzImage";
        }
        {
          source = "${config.system.build.initialRamdisk}/initrd";
          target = "/boot/initrd";
        }
        {
          source = "${pkgs.syslinux}/share/syslinux/isolinux.bin";
          target = "/boot/isolinux.bin";
        }
        {
          source = "${pkgs.syslinux}/share/syslinux/isohdpfx.bin";
          target = "/boot/isohdpfx.bin";
        }
      ];

      storeContents = [
        {
          object = config.boot.kernelPackages.kernel;
          symlink = "/kernel";
        }
        {
          object = config.system.build.initialRamdisk;
          symlink = "/initrd";
        }
        {
          object = config.system.build.toplevel;
          symlink = "/system";
        }
      ];

      isoName = "kiosk.iso";
      volumeID = "KIOSK";
      squashfsCompression = "xz";

      bootable = true;
      bootImage = "/boot/isolinux.bin";
      efiBootable = true;
      efiBootImage = "boot/efi.img";
      isohybridMbrImage = "/boot/isohdpfx.bin";
      usbBootable = true;

      syslinux = pkgs.syslinux;
    };
  };
}