nix-build '<nixpkgs/nixos>' -A config.system.build.sdImage -I nixos-config=./kiosk.nix -o ./result
zstdcat ./result/sd-image/*.img.zst | dd of=/dev/sda bs=32M status=progress; sync
