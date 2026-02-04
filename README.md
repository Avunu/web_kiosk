# NixOS Firefox Web Kiosk

This project provides a customizable and easy-to-deploy Firefox web kiosk powered by NixOS, the purely functional Linux distribution. It's ideal for setting up a secure, minimal, and dedicated web browsing environment.

## Features

- **Cage**: A Wayland-based kiosk environment that runs Firefox in kiosk-mode, providing a dedicated full-screen browsing experience.
- **Firefox**: The popular web browser that provides a secure and performant browsing experience.
- **NixOS**: A purely functional Linux distribution that provides declarative configuration and reliable system management.
- **F2FS**: Flash-Friendly File System optimized for USB drives and SSDs with compression support.
- **Disko**: Declarative disk partitioning for reproducible disk images.

## Benefits

- **Security and Stability**: Built on NixOS, the kiosk benefits from declarative configuration and reliable system management.
- **Customizable**: Easily configure network settings and the startup page.
- **Reproducible Builds**: Leverage the power of Nix to ensure consistent and reproducible builds across different machines.
- **Minimalistic**: Only essential components are included, ensuring a lightweight and focused browsing experience.
- **Flash-Optimized**: F2FS with ZSTD compression reduces writes and extends storage life.

## Caveats

- **Hardware**: The kiosk is currently limited to x86_64 hardware. Support for other architectures may be added in the future.
- **Static**: The OS is persistent but non-upgradable in place. Software updates require a flake update, rebuild, and redeployment.
- **Quirky**: This flake-based project uses a non-standard method for secrets management (see build.sh). This may change in the future.

PRs welcome to address any of these caveats!

## Getting Started

### Prerequisites

- Nix package manager installed. Visit [NixOS download page](https://nixos.org/download.html) for installation instructions.
- Basic understanding of Unix-like environments.
- Root/sudo access for building and flashing the disk image.

### Setup

1. **Clone the Repository**

   ```bash
   git clone https://github.com/Avunu/web_kiosk.git
   cd web_kiosk
   ```

2. **Configure Environment Variables**

   Copy the example environment file and customize it:

   ```bash
   cp .env.example .env
   ```

   Edit `.env` with your settings:

   ```bash
   # Required settings
   KIOSK_START_PAGE="https://www.google.com"
   KIOSK_TIMEZONE="America/New_York"

   # Optional WiFi (leave empty to disable)
   KIOSK_WIFI_SSID=""
   KIOSK_WIFI_PASSWORD=""
   ```

3. **Build the Disk Image**

   Run the build script to create your NixOS-based web kiosk:

   ```bash
   ./build.sh
   ```

   Then run the generated script to create the disk image:

   ```bash
   sudo ./result --build-memory 2048
   ```

   This will generate a compressed disk image `web-kiosk.raw.zst` in the current directory.

### Deployment

To deploy the kiosk:

1. **Flash the image to a USB drive:**

   ```bash
   zstd -d web-kiosk.raw.zst -o - | sudo dd of=/dev/sdX bs=4M status=progress
   ```

   Replace `/dev/sdX` with your USB drive device (use `lsblk` to find it).

2. **Boot the target device** from this USB drive.

3. The kiosk will automatically connect to the specified Wi-Fi network and open Firefox to the defined start page.

## Customization

You can further customize the kiosk by editing the configuration files:

- `kiosk.nix`: Define the kiosk's behavior, appearance, and additional settings.
- `disable.nix`: Adjust disabled features or services to suit your security or performance needs.
- `disko-config.nix`: Customize disk partitioning, image size, and filesystem options.

### Adjusting Image Size

Edit `disko-config.nix` and change the `imageSize` value:

```nix
imageSize = "8G";  # Increase for more storage
```

## Contributing

Contributions are welcome! Feel free to submit pull requests or open issues to suggest improvements or report bugs.

## License

This project is licensed under the [MIT License](LICENSE).
