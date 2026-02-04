# Disko configuration for Web Kiosk with F2FS root
# Creates a bootable disk image for USB drives or SSDs
#
# Supports both UEFI and legacy BIOS boot
#
{ config, lib, pkgs, ... }:
{
  disko.devices = {
    disk = {
      main = {
        # This device path is ignored during image building (disko creates virtual disks).
        # It's only used if you run `disko` directly on a live system.
        # The booted system mounts filesystems by label, not device path.
        device = lib.mkDefault "/dev/disk/by-id/some-disk-id";
        type = "disk";
        # Image size - adjust based on your kiosk needs
        # 4GB is usually sufficient for a minimal kiosk
        imageSize = "4G";
        imageName = "web-kiosk";
        content = {
          type = "gpt";
          partitions = {
            # BIOS boot partition for legacy systems
            # Required for GRUB on GPT disks with BIOS
            boot = {
              priority = 1;
              size = "1M";
              type = "EF02"; # BIOS boot partition
            };

            # EFI System Partition for UEFI boot
            ESP = {
              priority = 2;
              size = "512M";
              type = "EF00";
              label = "BOOT";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            # Root partition with F2FS
            # F2FS is ideal for flash-based storage (USB drives, SSDs)
            root = {
              priority = 3;
              size = "100%";
              label = "NIXOS";
              content = {
                type = "filesystem";
                format = "f2fs";
                mountpoint = "/";
                # F2FS options optimized for flash storage
                extraArgs = [
                  "-O"
                  "extra_attr,inode_checksum,sb_checksum,compression"
                  "-f"
                ];
                mountOptions = [
                  "compress_algorithm=zstd:6"
                  "compress_chksum"
                  "atgc"
                  "gc_merge"
                  "lazytime"
                  "noatime"
                ];
              };
            };
          };
        };
      };
    };
  };

  # Filesystem support
  boot.supportedFilesystems = lib.mkForce [ "f2fs" "vfat" ];
  boot.initrd.supportedFilesystems = lib.mkForce [ "f2fs" "vfat" ];
}
