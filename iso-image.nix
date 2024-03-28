{ pkgs }:

let
  # Define the kernel; you might adjust this based on the specific kernel version you want.
  kernel = pkgs.linuxPackages_latest.kernel;

  # Construct the initrd with a set of modules common for booting.
  initrd = pkgs.linuxPackages_latest.kernel.makeInitrd {
    # The following modules are a general suggestion and might need adjustments.
    contents = [
      pkgs.e2fsprogs # For ext4 support.
      pkgs.v86d # Needed for uvesafb support if using framebuffer.
    ];
    # Include essential kernel modules for disk support, filesystems, etc.
    kernelModules = [
      "isofs" # For ISO 9660 filesystems.
      "squashfs" # For compressed filesystems, important for live environments.
      "overlay" # For overlay filesystems, used in live environments.
      "sr_mod" # For optical drives (CD/DVD).
    ];
  };

  # Minimal set of store contents. Typically includes at least the system closure.
  storeContents = [ kernel initrd ];

  # Minimal ISO contents, required for booting. Adjust as necessary.
  isoContents = [
    { source = kernel + "/bzImage";
      target = "/boot/bzImage";
    }
    { source = initrd;
      target = "/boot/initrd";
    }
  ];

in pkgs.callPackage <nixpkgs/lib/make-iso9660-image.nix> {
  inherit isoContents storeContents;
  
  # Configuration for the ISO image.
  isoName = "kiosk.iso";
  volumeID = "KIOSK";
  
  # Bootable configuration for both BIOS and EFI.
  bootable = true; # For BIOS
  efiBootable = true; # For EFI
  efiBootImage = "boot/efi.img";
  usbBootable = true; # For USB
  
  # Include syslinux for BIOS booting.
  syslinux = pkgs.syslinux;
}
