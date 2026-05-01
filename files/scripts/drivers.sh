#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

# Determine the installed kernel version
QUALIFIED_KERNEL=$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-cachyos)

# Your code goes here.
echo 'install terra repo'
dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release{,-extras,-mesa}
echo 'install gamescope from terra repo'
dnf5 -y install dkms-zenergy dkms dkms-xone akmod-xpadneo dkms-xpad-noone xone-firmware akmod

mkdir -p /var/log/akmods
touch /var/log/akmods/akmods.log
KVER="$(dnf5 repoquery --installed --qf '%{VERSION}-%{RELEASE}.%{ARCH}' kernel-cachyos)"
akmods --force --kernels "$KVER"

# Build all installed DKMS modules for the installed kernel (if any)
while IFS=' ' read -r pkg_name pkg_ver; do
    module="${pkg_name#dkms-}"
    echo "Building DKMS module: ${module} ${pkg_ver}"

    dkms install -m "${module}" -v "${pkg_ver}" -k "${QUALIFIED_KERNEL}" --force || {
        echo "DKMS build failed for ${module} ${pkg_ver} — make.log:"
        cat "/var/lib/dkms/${module}/${pkg_ver}/build/make.log" 2>/dev/null || true
        exit 1
    }
done < <(rpm -qa --queryformat '%{NAME} %{VERSION}\n' | grep '^dkms-')

#Build initramfs
# Generate module dependencies
depmod "$QUALIFIED_KERNEL"

echo 'remove terra repo'
dnf5 -y remove \
    terra-gpg-keys \
    terra-release \
    terra-release-extras \
    terra-release-mesa
