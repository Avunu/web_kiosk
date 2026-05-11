{
  pkgs,
  kioskModule,
  startPage ? "https://www.google.com",
  timeZone ? "America/New_York",
}:

pkgs.testers.runNixOSTest {
  name = "kiosk";

  nodes.machine =
    { ... }:
    {
      imports = [ kioskModule ];

      # Set kiosk options from the actual NixOS module
      kiosk = { inherit startPage timeZone; };

      virtualisation = {
        memorySize = 2048;
        resolution = {
          x = 1920;
          y = 1080;
        };
      };
    };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    machine.wait_for_unit("cage.service")

    # Ensure cage (Wayland compositor) is active
    machine.succeed("systemctl is-active cage.service")

    # Ensure Firefox process is running inside the cage session
    machine.wait_until_succeeds("pgrep -x firefox", timeout=60)

    # Ensure the kiosk user exists and is not in the wheel group
    machine.succeed("id kiosk")
    machine.fail("id -nG kiosk | grep -qw wheel")

    # Ensure sudo is not available
    machine.fail("test -x $(which sudo 2>/dev/null || echo /nonexistent)")

    # Take a screenshot for visual inspection
    machine.screenshot("kiosk_started")
  '';
}
