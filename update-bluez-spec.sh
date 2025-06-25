#!/bin/bash
set -e

# Check if target Fedora version is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <fedora-version>"
    echo "Example: $0 fedora-42"
    echo "         $0 fedora-41"
    exit 1
fi

TARGET_FEDORA="$1"
echo "Updating BlueZ spec file with MIDI support for $TARGET_FEDORA..."

# Clean up any previous work
rm -rf work
mkdir -p work
cd work

# Download the latest BlueZ source RPM for the target Fedora version
echo "Downloading latest BlueZ source RPM for $TARGET_FEDORA..."
dnf --releasever=${TARGET_FEDORA#fedora-} download --source bluez

# Extract the source RPM
echo "Extracting source RPM..."
SRPM=$(ls bluez-*.src.rpm)
rpm2cpio "$SRPM" | cpio -idmv

# Backup original spec
echo "Backing up original spec file..."
cp bluez.spec bluez.spec.original

# Modify the spec file to enable MIDI support
echo "Modifying spec file for MIDI support..."

# Note: Keeping original package name and release for drop-in replacement

# Add MIDI-related build dependencies
echo "Adding MIDI-related build dependencies..."
sed -i '/BuildRequires: dbus-devel/a BuildRequires: alsa-lib-devel' bluez.spec
sed -i '/BuildRequires: alsa-lib-devel/a BuildRequires: pipewire-devel' bluez.spec
sed -i '/BuildRequires: pipewire-devel/a BuildRequires: pipewire-jack-audio-connection-kit-devel' bluez.spec

# Ensure MIDI support is enabled in configure/meson options
# Look for configure or meson setup and modify accordingly
if grep -q "%configure" bluez.spec; then
    # Autotools build - add --enable-midi to configure
    if ! grep -q "enable-midi" bluez.spec; then
        sed -i 's/%configure/%configure --enable-midi/' bluez.spec
    fi
elif grep -q "meson setup" bluez.spec || grep -q "%meson" bluez.spec; then
    # Meson build - add -Dmidi=true
    if ! grep -q "midi=true" bluez.spec; then
        if grep -q "%meson" bluez.spec; then
            sed -i 's/%meson/%meson -Dmidi=true/' bluez.spec
        elif grep -q "meson setup" bluez.spec; then
            sed -i 's/meson setup/meson setup -Dmidi=true/' bluez.spec
        fi
    fi
fi

# Note: MIDI support may add files to existing packages or create new binaries
# We'll let the build process determine what files are created

# Copy the modified spec back to the main directory
cp bluez.spec ../spec/bluez-${TARGET_FEDORA}.spec

echo "Modified spec file created as bluez-${TARGET_FEDORA}.spec"
echo ""
echo "Changes made:"
echo "1. Added MIDI-related build dependencies"
echo "2. Enabled MIDI support in build configuration"
echo ""
echo "Note: Package name and release kept the same for drop-in replacement"
echo "Original spec file is preserved as work/bluez.spec.original"
echo "You can review the differences with:"
echo "  diff -u work/bluez.spec.original work/bluez.spec"
echo ""
echo "Target Fedora version: $TARGET_FEDORA"
