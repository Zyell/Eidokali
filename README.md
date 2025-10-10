[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/amyos)](https://artifacthub.io/packages/container/amyos/amyos)
[![Build Eidokali](https://github.com/Zyell/Eidokali/actions/workflows/build.yml/badge.svg)](https://github.com/astrovm/amyos/actions/workflows/build.yml)

<div style="text-align: center;">
  <picture>
    <img alt="Eidokali Logo" src="./assets/kali.png" width="200">
  </picture>
</div>

# Eidokali

A custom bluefin-dx image for development & daily use with [Cosmic DE](https://system76.com/cosmic), [Proton](https://proton.me/) apps, nix directory, and a link to custom just recipes.

Eidokali combines the stability and developer-focused features of Bluefin-DX with modern desktop environments and privacy-focused applications, creating a powerful and secure platform for both development work and daily computing needs.

## 🚀 Base System

* **[Bluefin-DX](https://github.com/ublue-os/bluefin/pkgs/container/bluefin-dx)** - Developer-focused Universal Blue image
  * **GNOME 48** - Modern desktop environment with extensive customizability
  * **Fedora 42** - Built on Fedora Linux foundation
  * **Atomic updates** - Reliable, rollback-capable system updates
* **[Cosmic DE](https://system76.com/cosmic)** - System76's next-generation desktop environment
  * Written in Rust for performance and reliability
  * Modern tiling window management
  * Highly customizable and responsive interface

## ✨ Features

### Desktop Environment & Window Management
* **[Pop Shell](https://github.com/pop-os/shell)** - Advanced tiling window management extension for gnome
  * Automatic window tiling
  * Keyboard-driven workflow

### Privacy & Security Suite (Proton)
* **Protonmail Desktop App** - Secure, encrypted email client
* **Protonmail Bridge** - IMAP/SMTP bridge for using Proton Mail with other email clients
* **Proton Password Manager** - End-to-end encrypted password management
* **Proton Authenticator** - Two-factor authentication app
* **Proton VPN** - Privacy-focused VPN service

### Development Tools
* **Nix integration** - Declarative package management and development environments
* **Custom Just recipes** - Simplified task automation and system management
* **Full Bluefin-DX toolchain** - Includes containers, development tools, and utilities

## 📦 Installation

For a fresh installation, install the stable or latest version of the [Bluefin ISO](https://docs.projectbluefin.io/downloads/)

From an existing Fedora Atomic / Universal Blue installation, switch to the Eidokali image:

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/Zyell/Eidokali:latest
```

## 🛠️ Usage

Eidokali inherits all the powerful `just` commands from Bluefin-DX. Run `ujust` in your terminal to see available recipes for system management, updates, and customization.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/Zyell/Eidokali/issues) if you want to contribute.

## 📄 License

This project builds upon [Universal Blue](https://universal-blue.org/) and follows their licensing terms.

## 💝 Dedication

<div style="text-align: center;">

**🌈✨ In Loving Memory of Kali ✨🌈**

*Forever in our hearts • A beautiful soul • Deeply missed*

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

*"Those we love don't go away, they walk beside us every day.*  
*Unseen, unheard, but always near, still loved, still missed, and very dear."*

🕊️ ♡ 🌟

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

*This project is built with love and dedication to honor the memory*  
*of Kali, whose spirit continues to inspire us.*

</div>