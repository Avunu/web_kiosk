---
title: Build a Firefox web kiosk USB drive
description: "Build a bootable NixOS image that opens Firefox in kiosk mode on one URL and joins your WiFi automatically, then write it to a USB drive."
nav_title: Getting started
order: 1
tags: [kiosk, usb, firefox]
updated: 2026-11-24
---

This document shows how to build the `web_kiosk` image, a small NixOS live system that boots straight into Firefox in kiosk mode on a URL you choose, with your WiFi credentials baked in. Use it when you need a dedicated single-page display (a dashboard, a sign-in screen, a status board) that starts itself when you plug in a USB drive and power on.

The project lives at [github.com/Avunu/web_kiosk](https://github.com/Avunu/web_kiosk) and is MIT licensed.

## What you get

The image is a hybrid ISO built from a Nix flake. When it boots, it does the following:

- Starts cage, a single-application Wayland compositor, as a user named `kiosk`.
- Runs `firefox -kiosk <START_PAGE>` inside cage, so Firefox fills the screen with no tabs or address bar.
- Joins the WiFi network you configured, if any.
- Sets the time zone and turns the screen brightness to 100%.

The system runs live from the USB drive and is not installed anywhere. There is no login prompt, no SSH, no `sudo`, and no firewall. The sections below explain what that means for how you use it.

## Prerequisites

The flake builds the image for the system it runs on, and the kiosk only supports x86_64, so build it on an x86_64 Linux machine. You need:

- The [Nix package manager](https://nixos.org/download.html) with flakes enabled (the `nix-command` and `flakes` experimental features).
- [direnv](https://direnv.net/), if you want to use the project's development shell (recommended). The shell provides the `build` and `setup` helper commands and loads your `.env` file.
- Git, to clone the repository.
- A USB drive. The finished image is roughly 1.6 GB, so use a drive of at least 2 GB.
- A target computer with x86_64 hardware. The project does not support other architectures.

> [!NOTE]
> The flake declares a binary cache for devenv in its `nixConfig`. Depending on your Nix configuration, Nix may ask you to confirm that setting the first time you build.

## Configure the kiosk

Clone the repository and move into it:

```bash
git clone https://github.com/Avunu/web_kiosk.git
cd web_kiosk
```

The build reads four environment variables. The simplest way to set them is a `.env` file in the project root.

| Variable | Meaning | Default when empty |
| --- | --- | --- |
| `START_PAGE` | The URL Firefox opens. | `https://www.google.com` |
| `TIME_ZONE` | An IANA time zone name. | `America/New_York` |
| `WIFI_SSID` | The network name to join. | WiFi is disabled |
| `WIFI_PASSWORD` | The WiFi passphrase. | Not used |

### Use the setup wizard

Inside the development shell, the `setup` command asks for each value and writes `.env` for you. It also offers to start the build when it finishes. Run it after the shell is active (see the next section), or skip ahead and write the file by hand.

### Write the file by hand

Create `.env` in the project root:

```ini
START_PAGE=https://example.com/dashboard
TIME_ZONE=America/New_York
WIFI_SSID=<WIFI_SSID>
WIFI_PASSWORD=<WIFI_PASSWORD>
```

The repository includes `.env.example` with the same four keys. You can copy it as a starting point.

To see valid time zone names, run this on any systemd-based Linux machine:

```bash
timedatectl list-timezones
```

To build an image with no WiFi, leave both WiFi values empty. The README says this disables WiFi; Avunu has not verified how the image behaves on wired Ethernet, since the flake only turns on `systemd-networkd` and does not set up a wired connection explicitly:

```ini
WIFI_SSID=
WIFI_PASSWORD=
```

> [!WARNING]
> Your WiFi passphrase is written into the image in plain text. Anyone who has the ISO or the USB drive can recover it. Use a dedicated network or guest SSID for kiosks, never your main network, and treat the image like a credential. The `.env` file and the `result` link are listed in `.gitignore` so they stay out of Git, but keep them out of backups and shared folders too.

## Build the image

1. Enter the development shell. The project's `.envrc` loads `.env` and the flake shell:

   ```bash
   direnv allow
   ```

2. Build the image with the helper command:

   ```bash
   build
   ```

   The `build` command runs `nix build --impure`. The `--impure` flag is required because the flake reads your settings from environment variables at evaluation time.

3. When the build finishes, the image is at `result/iso/kiosk.iso`:

   ```bash
   ls -lh result/iso/
   ```

If you run the `setup` command from the shell, it writes `.env`, asks whether to build, and runs `direnv reload` followed by `nix build --impure` for you.

### Build without direnv

You do not need direnv. The flake reads plain environment variables, so you can pass them on the command line:

```bash
START_PAGE=https://example.com/dashboard TIME_ZONE=America/New_York WIFI_SSID=<WIFI_SSID> WIFI_PASSWORD=<WIFI_PASSWORD> nix build --impure
```

### If your changes do not show up

Changing `.env` does not rebuild anything on its own. If the new image still has old values, reload the shell so the variables are re-read, then build again:

```bash
direnv reload
build
```

## Write the image to a USB drive

The ISO is built to be bootable from USB, and the project supports both UEFI and legacy BIOS boot. The repository itself only says to burn the ISO to a USB drive, so the commands below are the standard Linux method rather than something the project provides.

1. Plug in the drive and identify it by size:

   ```bash
   lsblk
   ```

2. Write the image to the whole device (for example `/dev/sdX`, not a partition such as `/dev/sdX1`):

   ```bash
   sudo dd if=result/iso/kiosk.iso of=/dev/<USB_DEVICE> bs=4M status=progress conv=fsync
   ```

3. Flush buffers before you unplug:

   ```bash
   sync
   ```

> [!WARNING]
> `dd` overwrites the target device without asking. If you pick the wrong device you will destroy its contents. Check the device name against `lsblk` twice.

On macOS or Windows, use any tool that writes a raw image to a disk. Graphical tools such as balenaEtcher work for hybrid ISOs like this one.

## Boot the kiosk

1. Plug the drive into the target computer and power it on.
2. Open the firmware boot menu (the key varies by manufacturer) and choose the USB drive.
3. If a boot menu appears, let it time out. The project's boot test relies on the default entry starting automatically after a short countdown (about ten seconds in its BIOS boot configuration).

The system then starts `cage-tty1.service`, which launches Firefox on your start page. If WiFi is configured, the machine joins the network without any input.

Things to know about how it behaves:

- **No persistence.** Nothing you do in the browser survives a reboot. Every power cycle starts from the image as built.
- **No login.** The login program on the console is replaced so you cannot sign in from a keyboard. The `kiosk` user is not in the `wheel` group and `sudo` is disabled.
- **No remote access.** SSH is disabled. If you need to reach the machine after deployment, this image is the wrong tool.
- **Firewall off.** The image does not run a firewall. SSH is disabled, but keep the kiosk on a network you trust.
- **No sound.** PipeWire and PulseAudio are disabled.
- **Physical access still matters.** Kiosk mode limits the browser UI. The project does not claim to lock down attached keyboards or mice, so secure the machine physically if that matters.

## Update or change the kiosk

The image is static. It does not update itself, and there is no way to change the start page or WiFi settings on a running kiosk. To change anything, rebuild and rewrite the drive.

### Change the URL, time zone or WiFi

1. Edit `.env` (or run `setup` again).
2. Run `direnv reload`, then `build`.
3. Write the new ISO to the drive as above.

### Update Firefox and the base system

The flake pins its inputs (`nixpkgs` on the `nixos-unstable` branch, `devenv` and `flake-parts`) in `flake.lock`. To pick up newer software, update the lock file, rebuild, and reflash:

```bash
nix flake update
build
```

### Change how the kiosk behaves

Kiosk behavior lives in `modules/kiosk.nix`. It exposes two options, `kiosk.startPage` and `kiosk.timeZone`, and also defines the Firefox command line, the `kiosk` user, the disabled services and the brightness service. Image settings (boot modules, compression, volume label, WiFi and firewall) live in `flake.nix`.

For example, the Firefox command is set here:

```nix
services.cage = {
  enable = true;
  program = "${pkgs.firefox}/bin/firefox -kiosk ${config.kiosk.startPage}";
  user = "kiosk";
};
```

Edit that line to add Firefox flags, then rebuild.

## Test the build

The flake defines two checks that run NixOS virtual machine tests:

- `kiosk` boots the kiosk module in a VM and confirms that `cage-tty1.service` is active, that Firefox is running, that the `kiosk` user exists outside the `wheel` group, and that the `sudo` wrapper is absent.
- `kiosk-iso-boot` attaches the built ISO to a VM as a CD-ROM and waits for the console to report that `cage-tty1.service` started.

Both checks are available on Linux. They are useful when you change the module and want to know it still boots before you touch real hardware.

## Troubleshoot

### The kiosk shows the wrong page or time zone

The image was built with different values than you expected. Confirm what is in `.env`, run `direnv reload`, rebuild, and reflash. If a variable is empty, the defaults in the table above apply.

### The machine does not connect to WiFi

- Check `WIFI_SSID` and `WIFI_PASSWORD` for typos. If the SSID is empty, WiFi is not configured at all.
- The image includes redistributable firmware, but Avunu has not verified support for any particular WiFi adapter. If one does not work, test the same image on different hardware.
- Rebuild after any change. The credentials cannot be edited on the drive.

### The machine does not boot from the drive

- Pick the USB drive explicitly in the firmware boot menu.
- Confirm you wrote the ISO to the whole device and not to a partition, and that `dd` finished without errors.
- Check that the hardware is x86_64.

### The screen stays blank or the boot stalls

You cannot log in to inspect a running kiosk, but the kernel is configured to log to the first serial port (`console=ttyS0,115200n8`). If the machine has a serial port, or you are testing in a VM, you can read boot messages there. A healthy boot reports that `cage-tty1.service` started.

### The build ignores your settings

Make sure you pass `--impure`. A plain `nix build` cannot read your environment variables during evaluation, so your settings are ignored and the defaults are used. Use the `build` helper or run `nix build --impure` yourself.

## Known limitations

These are the project's own stated caveats:

- x86_64 hardware only.
- The image is static and non-upgradable. Updates mean rebuilding and reflashing.
- The ISO is about 1.6 GB, larger than the job strictly needs.

Pull requests that address these are welcome on the [project repository](https://github.com/Avunu/web_kiosk).

## Related documents

- [A NixOS Micro Desktop for Family and Friends](https://docs.avunu.net/nixos-micro-desktop/docs/getting-started/), for a NixOS desktop that installs to disk and keeps itself updated, in contrast to this static live image.
- [Why Nix for Business Systems](https://avunu.net/kb/nixos/why-nix-for-business-systems/), for the wider case for building devices and servers declaratively.
