#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

# Your code goes here.

# Remove Fedora kernel & remove leftover files
#dnf -y remove kernel kernel-headers kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-tools kernel-tools-libs
rpm -e --nodeps kernel kernel-headers kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-tools kernel-tools-libs
rm -r -f /usr/lib/modules/*

# Enable repos
dnf -y copr enable bieszczaders/kernel-cachyos
dnf -y copr enable bieszczaders/kernel-cachyos-addons

# Install CachyOS LTO kernel & akmods
dnf5 -y --setopt=tsflags=noscripts install kernel-cachyos kernel-cachyos-devel-matched
dnf -y install --allowerasing cachyos-settings

# Manually build modules, run depmod
VER=$(ls /lib/modules) && \
    depmod -a $VER

# Disable repos
dnf -y copr disable bieszczaders/kernel-cachyos
dnf -y copr disable bieszczaders/kernel-cachyos-addons
