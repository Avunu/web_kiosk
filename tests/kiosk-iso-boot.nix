{
  pkgs,
  isoImage,
}:

pkgs.testers.runNixOSTest {
  name = "kiosk-iso-boot";

  nodes.machine =
    { lib, ... }:
    {
      virtualisation = {
        memorySize = 2048;
        directBoot.enable = false;
        useEFIBoot = false;
        # Attach ISO as a real IDE CDROM so sr_mod + ata_piix detect it
        # (qemu.drives uses virtio which the ISO initrd lacks drivers for)
        qemu.options = [
          "-cdrom" "${isoImage}/iso/kiosk.iso"
        ];
      };

      # Minimal dummy config — the VM boots from the ISO, not this NixOS config
      boot.loader.systemd-boot.enable = true;
      system.stateVersion = "25.11";
    };

  # The ISO boots its own system without the NixOS test backdoor, so we can
  # only use QEMU-level checks: serial console text and screenshots.
  testScript = ''
    machine.start()

    # Syslinux has TIMEOUT 100 (10s) — let it auto-select the default entry.
    # The kernel has console=ttyS0,115200n8 so serial output is available.

    # Wait for cage kiosk service to start
    machine.wait_for_console_text("[  OK  ] Started cage-tty1.service", timeout=300)

    # Give Firefox time to launch inside cage
    import time
    time.sleep(15)
  '';
}
