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

      # Allow software rendering in the VM (no GPU)
      environment.variables = {
        WLR_RENDERER_ALLOW_SOFTWARE = "1";
        LIBGL_ALWAYS_SOFTWARE = "1";
        MOZ_DISABLE_GPU_PROCESS = "1";
        MOZ_WEBRENDER = "0";
      };
    };

  testScript = ''
    machine.wait_for_unit("multi-user.target")

    # NixOS cage module creates cage-tty1.service (not cage.service)
    machine.wait_for_unit("cage-tty1.service")

    # Ensure cage (Wayland compositor) is active
    machine.succeed("systemctl is-active cage-tty1.service")

    # Ensure Firefox process is running inside the cage session
    machine.wait_until_succeeds("pgrep firefox", timeout=90)

    # Ensure the kiosk user exists and is not in the wheel group
    machine.succeed("id kiosk")
    machine.fail("id -nG kiosk | grep -qw wheel")

    # Ensure sudo setuid wrapper is absent
    machine.fail("test -u /run/wrappers/bin/sudo")

    # Take a screenshot for visual inspection
    machine.screenshot("kiosk_started")
  '';
}
