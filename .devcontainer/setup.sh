#!/bin/bash
set -e

echo "Setting up Fedora development environment for BlueZ MIDI COPR..."

# Update the system
dnf update -y

# Install COPR development tools
dnf install -y \
    fedpkg \
    copr-cli \
    rpm-build \
    rpm-devel \
    rpmdevtools \
    rpmlint \
    mock \
    spectool \
    git \
    wget \
    curl

# Install BlueZ build dependencies
dnf install -y \
    gcc \
    gcc-c++ \
    make \
    automake \
    autoconf \
    libtool \
    pkgconfig \
    dbus-devel \
    glib2-devel \
    libical-devel \
    readline-devel \
    systemd-devel \
    alsa-lib-devel \
    json-c-devel \
    ell-devel

# Install additional dependencies for MIDI support
dnf install -y \
    alsa-lib-devel \
    pipewire-devel \
    pipewire-jack-audio-connection-kit-devel

# Install documentation and development tools
dnf install -y \
    vim \
    nano \
    tree \
    htop \
    which \
    less \
    man-db \
    man-pages

# Add vscode user to mock group (user already exists in container)
usermod -aG mock vscode || true

# Set up RPM build environment for vscode user
runuser -l vscode -c 'rpmdev-setuptree'

# Create mock configuration directory
mkdir -p /etc/mock
chown -R vscode:vscode /etc/mock

echo "Development environment setup complete!"
echo "You can now:"
echo "1. Set up your COPR configuration with 'copr-cli'"
echo "2. Create RPM spec files for BlueZ with MIDI support"
echo "3. Build and test packages with 'mock'"
