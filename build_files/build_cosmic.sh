#!/bin/bash

set -ouex pipefail

### Install packages

# this installs a package from fedora repos

# install cosmic de
dnf5 copr enable -y ryanabx/cosmic-epoch
dnf5 -y install @cosmic-desktop

# clean it all up
dnf5 clean all