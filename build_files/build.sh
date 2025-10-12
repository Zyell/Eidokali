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

# migrate over better proton icons and fix the application listing in cosmic for all proton apps
cp -a proton_icons/. /usr/share/icons/hicolor/scalable/apps/

# remove the proton icons we don't want
rm /usr/share/icons/hicolor/128x128/apps/proton-authenticator.png
rm /usr/share/icons/hicolor/256x256@2/apps/proton-authenticator.png
rm /usr/share/icons/hicolor/32x32/apps/proton-authenticator.png

# update icon cache
gtk-update-icon-cache -f /usr/share/icons/hicolor

# install pop shell for tiling
dnf5 -y install gnome-shell-extension-pop-shell

# clean it all up
dnf5 clean all

# Clean temporary files
rm -rf /tmp/*

# Clean /var directory while preserving essential files
find /var/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \;
find /var/cache/* -maxdepth 0 -type d \! -name libdnf5 \! -name rpm-ostree -exec rm -fr {} \;

# Restore and setup directories
mkdir -p /var/tmp
chmod -R 1777 /var/tmp

# Adding reference to eidokali user managed just recipes
echo "import? \"~/.config/just/eidokali.just\"" >>/usr/share/ublue-os/justfile
