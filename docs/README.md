# NixOS Firefox Web Kiosk

This project provides a customizable and easy-to-deploy Firefox web kiosk powered by NixOS, the purely functional Linux distribution. It's ideal for setting up a secure, minimal, and dedicated web browsing environment.

## Features

* **Firefox Kiosk**: Uses the native Firefox kiosk mode to provide an isolated browsing experience at your selected URL.
* **USB Key**: Deploy the OS with an easy-to-build image on a thumb drive attached to the target system.
* **WiFi**: Bake your wireless credentials into the image for auto-connection to your network (see the security note under [Configure Environment Variables](#setup)).

## Benefits

* **Security and Stability**: Built on NixOS, the kiosk benefits from declarative configuration and reliable system management.
* **Customizable**: Easily configure network settings and the startup page.
* **Reproducible Builds**: Leverage the power of Nix to ensure consistent and reproducible builds across different machines.
* **Minimalistic**: Only essential components are included, ensuring a lightweight and focused browsing experience.

## Caveats

* **Hardware**: The kiosk is currently limited to x86\_64 hardware. Support for other architectures may be added in the future.
* **Static**: The OS, as it stands, is persistent and non-upgradable. Software updates require a flake update, rebuild, and redeployment. This may change in the future.
* **Bloated**: Although every attempt has been made at minimalism, the resulting ISO image is still quite large for what it does (\~1.6GB). More work is needed to reduce the image size.

PRs welcome to address any of these caveats!

## Getting Started

### Prerequisites

* Nix package manager with flakes enabled. Visit [NixOS download page](https://nixos.org/download.html) for installation instructions.
* [direnv](https://direnv.net/) for the development shell (provides `.env` loading).
* Basic understanding of Unix-like environments.

### Setup

1. **Clone the Repository**

   ```shell
   git clone https://github.com/Avunu/web_kiosk.git
   cd web_kiosk
   ```

2. **Configure Environment Variables**

   The build reads its settings from a local `.env` file in the project root. Create it in one of two ways:

   * Run the interactive setup wizard (`./setup.sh`, or `setup` once you are inside the development shell from step 3). It prompts for each value, writes `.env`, and offers to build the image.
   * Copy `.env.example` to `.env` and edit it:

     ```shell
     cp .env.example .env
     ```

   The file contains one `KEY=value` pair per line:

   ```dotenv
   START_PAGE=https://www.google.com
   TIME_ZONE=America/New_York
   WIFI_SSID=YourWifiSSID
   WIFI_PASSWORD=YourWifiPassword
   ```

   | Variable        | Purpose                                                   | Default if empty         |
   | --------------- | --------------------------------------------------------- | ------------------------ |
   | `START_PAGE`    | URL Firefox opens in kiosk mode                           | `https://www.google.com` |
   | `TIME_ZONE`     | Time zone of the kiosk (see `timedatectl list-timezones`) | `America/New_York`       |
   | `WIFI_SSID`     | Wi-Fi network to join                                     | Wi-Fi disabled           |
   | `WIFI_PASSWORD` | Wi-Fi passphrase                                          | none                     |

   Set `WIFI_SSID` and `WIFI_PASSWORD` to empty strings to disable Wi-Fi.

   > [!WARNING]
   > Wi-Fi credentials are baked into the image in plain text, and the Nix build reads them from your environment. Treat the resulting ISO as sensitive, do not share it, and never commit your `.env` file (it is already in `.gitignore`).

3. **Enter the Development Shell**

   ```shell
   direnv allow
   ```

   This activates the devenv shell, which loads the `.env` variables into the environment and provides the `build` and `setup` commands.

4. **Build the Kiosk**

   ```shell
   build
   ```

   This runs `nix build --impure` (impure evaluation is required so the flake can read your environment variables) and generates an ISO image that you can use to boot your kiosk system. The image is written to the `result/iso/` directory as `kiosk.iso`.

### Deployment

To deploy the kiosk:

* Burn the generated ISO image onto a USB drive or a CD.
* Boot the target device from this USB drive or CD.
* The kiosk will automatically connect to the specified Wi-Fi network and open Firefox to the defined start page.

## Customization

Day-to-day settings (start page, time zone, Wi-Fi) come from `.env`, as described above. For anything deeper, edit the NixOS configuration:

* `modules/kiosk.nix` is the kiosk module. It defines the `kiosk.startPage` and `kiosk.timeZone` options and configures Firefox under the `cage` Wayland compositor, screen brightness, and the disabled services and features that keep the system minimal and locked down.
* `flake.nix` assembles the ISO image: boot and initrd modules, ISO settings (compression, BIOS and EFI bootability), networking, and the development shell.

## Testing

On Linux, `nix flake check` runs the NixOS VM tests in `tests/` (add `--impure` to test with the values from your `.env` instead of the defaults):

* `kiosk` boots the kiosk module in a VM and checks that the `cage` service and Firefox start, and that the `kiosk` user has no `sudo` or `wheel` access.
* `kiosk-iso-boot` boots the built ISO from a virtual CD-ROM and waits for the kiosk service to start on the serial console.

Both tests build a full image or VM, so expect them to take a while. There is no CI workflow in this repository yet.

## Contributing

Contributions are welcome! Feel free to submit pull requests or open issues to suggest improvements or report bugs.

## License

This project is licensed under the [MIT License](LICENSE).
