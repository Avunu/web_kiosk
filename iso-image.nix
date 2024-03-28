{ config, lib, pkgs, ... }:

with lib;

{
  options = {

    isoImage.isoName = mkOption {
      default = "nixos-minimal.iso";
      type = types.str;
      description = "Name of the generated ISO image file.";
    };

    isoImage.volumeID = mkOption {
      default = "NIXOS_ISO";
      type = types.str;
      description = "Specifies the label or volume ID of the generated ISO image.";
    };

    isoImage.makeEfiBootable = mkOption {
      default = true;
      type = types.bool;
      description = "Whether the ISO image should be an EFI-bootable volume.";
    };

    isoImage.contents = mkOption {
      default = [];
      description = "This option lists files to be copied to fixed locations in the generated ISO image.";
    };

    isoImage.storeContents = mkOption {
      default = [ config.system.build.toplevel ];
      description = "This option lists additional derivations to be included in the Nix store in the generated ISO image.";
    };

  };

  config = {
    assertions = [
      {
        assertion = config.isoImage.makeEfiBootable;
        message = "EFI boot is required for a minimal bootable ISO.";
      }
    ];

    boot.kernelParams = [ "loglevel=4" ];

    isoImage.contents = [
      { source = config.boot.kernelPackages.kernel + "/" + config.system.boot.loader.kernelFile;
        target = "/boot/" + config.system.boot.loader.kernelFile;
      }
      { source = config.system.build.initialRamdisk + "/" + config.system.boot.loader.initrdFile;
        target = "/boot/" + config.system.boot.loader.initrdFile;
      }
    ];

    boot.loader.grub.enable = false;
    boot.loader.efi.canTouchEfiVariables = false;

    system.build.isoImage = pkgs.callPackage ../../../lib/make-iso9660-image.nix {
      inherit (config.isoImage) isoName volumeID contents;
      bootable = true;
      efiBootable = true;
      efiBootImage = "boot/efi.img";
      squashfsContents = config.isoImage.storeContents;
    };
  };
}
