# NixOS Firefox Web Kiosk

This project provides a customizable and easy-to-deploy Firefox web kiosk powered by NixOS, the purely functional Linux distribution. It's ideal for setting up a secure, minimal, and dedicated web browsing environment.

## Features

- **Cage**: A Wayland-based kiosk environment that runs Firefox in kiosk-mode, providing a dedicated full-screen browsing experience.
- **Firefox**: The popular web browser that provides a secure and performant browsing experience.
- **NixOS**: A purely functional Linux distribution that provides declarative configuration and reliable system management.

## Benefits

- **Security and Stability**: Built on NixOS, the kiosk benefits from declarative configuration and reliable system management.
- **Customizable**: Easily configure network settings and the startup page.
- **Reproducible Builds**: Leverage the power of Nix to ensure consistent and reproducible builds across different machines.
- **Minimalistic**: Only essential components are included, ensuring a lightweight and focused browsing experience.

## Caveats

- **Experimental**: This project is still in its early stages and is not yet ready for production use.
- **Firefox**: The kiosk is currently limited to Firefox. Support for other browsers may be added in the future.
- **Hardware**: The kiosk is currently limited to x86_64 hardware. Support for other architectures may be added in the future.
- **Static**: The OS, as it stands, is persistent and non-upgradable. This may change in the future.

## Getting Started

### Prerequisites

- Nix package manager installed. Visit [NixOS download page](https://nixos.org/download.html) for installation instructions.
- Basic understanding of Nix and Unix-like environments.

### Setup

1. **Clone the Repository**

   ```bash
   git clone https://github.com/Avunu/web_kiosk.git
   cd web_kiosk
   ```

2. **Configure Environment Variables**

   Create a `env.nix` file in the project root with your custom configuration. Use `env.nix.example` as a template:

   ```nix
    # env.nix
    {
        startPage = "https://www.google.com";
        timeZone = "America/New_York";
        wifiSSID = "YourWifiSSID"; # leave empty to disable wifi
        wifiPassword = "YourWifiPassword";
    }
   ```

   Make sure to replace `https://startpage.com`, `America/New_York`, `YourWifiSSID`, and `YourWifiPassword` with your desired startup page URL, timeZone, and Wi-Fi credentials. If you don't need Wi-Fi, you can replace `YourWifiSSID` and `YourWifiPassword` variables with empty strings.

3. **Build the Kiosk**

   Run the build script to create your NixOS-based web kiosk:

   ```bash
   ./build.sh
   ```

   This will generate an ISO image that you can use to boot your kiosk system. The image will be located in the `result/iso/` directory.

### Deployment

To deploy the kiosk:

- Burn the generated ISO image onto a USB drive or a CD.
- Boot the target device from this USB drive or CD.
- The kiosk will automatically connect to the specified Wi-Fi network and open Firefox to the defined start page.

## Customization

You can further customize the kiosk by editing `kiosk.nix` and `disable.nix` files:

- `kiosk.nix`: Define the kiosk's behavior, appearance, and additional settings.
- `disable.nix`: Adjust disabled features or services to suit your security or performance needs.

## Contributing

Contributions are welcome! Feel free to submit pull requests or open issues to suggest improvements or report bugs.

## License

This project is licensed under the [MIT License](LICENSE).
