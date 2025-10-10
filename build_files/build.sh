#!/bin/bash

set -ouex pipefail

### Install packages
mkdir temp_apps
cd temp_apps

# install protonmail bridge
wget https://proton.me/download/bridge/protonmail-bridge-3.21.2-1.x86_64.rpm
dnf5 -y install protonmail-bridge-3.21.2-1.x86_64.rpm

# install protonvpn
wget "https://repo.protonvpn.com/fedora-$(cat /etc/fedora-release | cut -d' ' -f 3)-stable/protonvpn-stable-release/protonvpn-stable-release-1.0.3-1.noarch.rpm"
dnf5 -y install ./protonvpn-stable-release-1.0.3-1.noarch.rpm
dnf5 check-update --refresh || true
dnf5 -y install proton-vpn-gnome-desktop
dnf5 -y install libappindicator-gtk3 gnome-shell-extension-appindicator gnome-extensions-app

# install proton authenticator
wget https://proton.me/download/authenticator/linux/ProtonAuthenticator.rpm
dnf5 -y install ProtonAuthenticator.rpm

# install proton password manager
wget https://proton.me/download/PassDesktop/linux/x64/ProtonPass.rpm
dnf5 -y install ProtonPass.rpm

# install protonmail client
wget https://proton.me/download/mail/linux/ProtonMail-desktop-beta.rpm
dnf5 -y install ProtonMail-desktop-beta.rpm

cd ..
rm -rf ./temp_apps

# install pop shell for tiling
dnf5 -y install gnome-shell-extension-pop-shell

# clean it all up
dnf5 clean all

# Adding reference to eidokali user managed just recipes
echo "import? \"~/.config/just/eidokali.just\"" >>/usr/share/ublue-os/justfile
