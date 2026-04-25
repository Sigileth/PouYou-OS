#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

# Your code goes here.

# create a shims to bypass kernel install triggering dracut/rpm-ostree
# seems to be minimal impact, but allows progress on build
#pushd /usr/lib/kernel/install.d
#mv 05-rpmostree.install 05-rpmostree.install.bak
#mv 50-dracut.install 50-dracut.install.bak
#printf '%s\n' '#!/bin/sh' 'exit 0' > 05-rpmostree.install
#printf '%s\n' '#!/bin/sh' 'exit 0' > 50-dracut.install
#chmod +x  05-rpmostree.install 50-dracut.install
#popd

# Remove Fedora kernel & remove leftover files
#dnf -y remove kernel kernel-headers kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-tools kernel-tools-libs
rpm -e --nodeps kernel kernel-headers kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-tools kernel-tools-libs
rm -r -f /usr/lib/modules/*

# Enable repos
dnf -y copr enable bieszczaders/kernel-cachyos
dnf -y copr enable bieszczaders/kernel-cachyos-addons

# Install CachyOS LTO kernel & akmods
dnf5 -y --setopt=tsflags=noscripts install kernel-cachyos
#dnf -y install --setopt=install_weak_deps=False kernel-cachyos
dnf -y install --allowerasing cachyos-settings

# Manually build modules, run depmod
VER=$(ls /lib/modules) && \
    depmod -a $VER

#pushd /usr/lib/kernel/install.d
#mv -f 05-rpmostree.install.bak 05-rpmostree.install
#mv -f 50-dracut.install.bak 50-dracut.install
#popd

# Disable repos
dnf -y copr disable bieszczaders/kernel-cachyos
dnf -y copr disable bieszczaders/kernel-cachyos-addons
