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
echo "Preparing COPR submission files for $TARGET_FEDORA..."

# Check if spec file exists
if [ ! -f "spec/bluez-${TARGET_FEDORA}.spec" ]; then
    echo "Error: bluez-${TARGET_FEDORA}.spec not found!"
    echo "Run: ./update-bluez-spec.sh $TARGET_FEDORA first"
    exit 1
fi

# Create submission directory
mkdir -p "copr-submission-${TARGET_FEDORA}"
cd "copr-submission-${TARGET_FEDORA}"

# Copy the modified spec file
cp "../spec/bluez-${TARGET_FEDORA}.spec" bluez.spec

# List what we have
echo ""
echo "COPR submission files prepared in copr-submission-${TARGET_FEDORA}/:"
ls -la

echo ""
echo "Files ready for COPR submission ($TARGET_FEDORA):"
echo "================================="
echo "1. bluez.spec - Modified spec file with MIDI support for $TARGET_FEDORA"
echo "   (COPR will download sources automatically from URLs in the spec)"
echo ""
echo "Next steps:"
echo "1. Upload these files to your COPR project"
echo "2. Or use 'copr-cli' to submit from command line"
echo ""
echo "Example copr-cli commands:"
echo "  # Create a new project (one time) for $TARGET_FEDORA with both architectures"
echo "  copr-cli create bluez-midi --chroot ${TARGET_FEDORA}-x86_64 --chroot ${TARGET_FEDORA}-aarch64"
echo ""
echo "  # Submit build for $TARGET_FEDORA (COPR will download sources from URLs in spec)"
echo "  copr-cli build bluez-midi bluez.spec"
echo ""
echo "  # Or submit for specific architecture only:"
echo "  copr-cli build bluez-midi bluez.spec --chroot ${TARGET_FEDORA}-x86_64"
echo "  copr-cli build bluez-midi bluez.spec --chroot ${TARGET_FEDORA}-aarch64"
