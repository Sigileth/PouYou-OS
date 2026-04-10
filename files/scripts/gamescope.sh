#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

# Your code goes here.
echo 'install terra repo'
dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release{,-extras,-mesa}
echo 'install bazzite copr'
dnf copr enable ublue-os/bazzite
dnf copr enable ublue-os/bazzite-multilib
echo 'install gamescope'
dnf5 -y install \
    gamescope.x86_64 \
    gamescope-libs.x86_64 \
    gamescope-libs.i686 \
    gamescope-shaders \
    ScopeBuddy
echo 'remove terra repo'
dnf5 -y remove \
    terra-gpg-keys \
    terra-release \
    terra-release-extras \
    terra-release-mesa
echo 'remove bazzite copr'
dnf copr remove ublue-os/bazzite
dnf copr remove ublue-os/bazzite-multilib
