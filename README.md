# NixOS Firefox Web Kiosk

This project provides a customizable and easy-to-deploy Firefox web kiosk powered by NixOS, the purely functional Linux distribution. It's ideal for setting up a secure, minimal, and dedicated web browsing environment.

## Features

* **Firefox Kiosk**: Uses the native Firefox kiosk mode to provide an isolated browsing experience at your selected URL.
* **USB Key**: Deploy the OS with an easy-to-build image on a thumb drive attached to the target system.
* **WiFi**: Bake your wireless credentials into the image for auto-connection to your network.

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

   ```Shell
   git clone https://github.com/Avunu/web_kiosk.git
   cd web_kiosk
   ```

2. **Configure Environment Variables**

   Create a `.env` file in the project root with your custom configuration.

   Run the `setup.sh` script to set your parameters in the local `.env` file.

   Alternatively, copy and use `.env.example` as a template:

   ```Shell
   START_PAGE=https://www.google.com
   TIME_ZONE=America/New_York
   WIFI_SSID=YourWifiSSID
   WIFI_PASSWORD=YourWifiPassword
   ```

   Set `WIFI_SSID` and `WIFI_PASSWORD` to empty strings to disable Wi-Fi.

3. **Enter the Development Shell**

   ```Shell
   direnv allow
   ```

   This activates the devenv shell which loads `.env` variables into the environment.

4. **Build the Kiosk**

   ```Shell
   build
   ```

   This will generate an ISO image that you can use to boot your kiosk system. The image will be located in the `result/iso/` directory.

### Deployment

To deploy the kiosk:

* Burn the generated ISO image onto a USB drive or a CD.
* Boot the target device from this USB drive or CD.
* The kiosk will automatically connect to the specified Wi-Fi network and open Firefox to the defined start page.

## Customization

All kiosk configuration lives in `flake.nix`. Edit the NixOS module within it to adjust:

* Kiosk behavior (browser, start page, screen brightness)
* Disabled features and services (for security and minimal footprint)
* ISO image settings (compression, bootability)

## Contributing

Contributions are welcome! Feel free to submit pull requests or open issues to suggest improvements or report bugs.

## License

This project is licensed under the [MIT License](LICENSE).
