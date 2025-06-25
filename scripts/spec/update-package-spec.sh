#!/bin/bash
set -e

# Check if target Fedora version and package are provided
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Usage: $0 <fedora-version> [<package-name>]"
    echo "Example: $0 fedora-42"
    echo "         $0 fedora-41 bluez"
    exit 1
fi

TARGET_FEDORA="$1"
PACKAGE="${2:-bluez}"
echo "Updating $PACKAGE spec file with MIDI support for $TARGET_FEDORA..."

# Clean up any previous work
rm -rf work
mkdir -p work
cd work

# Download the latest source RPM for the target Fedora version
echo "Downloading latest $PACKAGE source RPM for $TARGET_FEDORA..."
dnf --releasever=${TARGET_FEDORA#fedora-} download --source "$PACKAGE"

# Extract the source RPM
echo "Extracting source RPM..."
SRPM=$(ls ${PACKAGE}-*.src.rpm)
rpm2cpio "$SRPM" | cpio -idmv

# Backup original spec
echo "Backing up original spec file..."
cp ${PACKAGE}.spec ${PACKAGE}.spec.original

# Modify the spec file to enable MIDI support
echo "Modifying spec file for MIDI support..."

# Note: Keeping original package name and release for drop-in replacement

# Add MIDI-related build dependencies
echo "Adding MIDI-related build dependencies..."
sed -i '/BuildRequires: dbus-devel/a BuildRequires: alsa-lib-devel' ${PACKAGE}.spec
sed -i '/BuildRequires: alsa-lib-devel/a BuildRequires: pipewire-devel' ${PACKAGE}.spec
sed -i '/BuildRequires: pipewire-devel/a BuildRequires: pipewire-jack-audio-connection-kit-devel' ${PACKAGE}.spec

# Ensure MIDI support is enabled in configure/meson options
# Look for configure or meson setup and modify accordingly
if grep -q "%configure" ${PACKAGE}.spec; then
    # Autotools build - add --enable-midi to configure
    if ! grep -q "enable-midi" ${PACKAGE}.spec; then
        sed -i 's/%configure/%configure --enable-midi/' ${PACKAGE}.spec
    fi
elif grep -q "meson setup" ${PACKAGE}.spec || grep -q "%meson" ${PACKAGE}.spec; then
    # Meson build - add -Dmidi=true
    if ! grep -q "midi=true" ${PACKAGE}.spec; then
        if grep -q "%meson" ${PACKAGE}.spec; then
            sed -i 's/%meson/%meson -Dmidi=true/' ${PACKAGE}.spec
        elif grep -q "meson setup" ${PACKAGE}.spec; then
            sed -i 's/meson setup/meson setup -Dmidi=true/' ${PACKAGE}.spec
        fi
    fi
fi

# Note: MIDI support may add files to existing packages or create new binaries
# We'll let the build process determine what files are created

# Copy the modified spec back to the main directory
mkdir -p ../spec/${TARGET_FEDORA}
cp ${PACKAGE}.spec ../spec/${TARGET_FEDORA}/${PACKAGE}.spec

echo "Modified spec file created as spec/${TARGET_FEDORA}/${PACKAGE}.spec"