#!/bin/bash
set -e

# Script to get the latest version of a package from a COPR project
# Usage: ./get-copr-package-version.sh <owner>/<project> <package-name> <fedora-version>

PROJECT_PATH="$1"
PACKAGE="$2"
FEDORA_VERSION="$3"

if [ -z "$PROJECT_PATH" ] || [ -z "$PACKAGE" ] || [ -z "$FEDORA_VERSION" ]; then
    echo "Error: All arguments required" >&2
    echo "Usage: $0 <owner>/<project> <package-name> <fedora-version>" >&2
    echo "" >&2
    echo "Arguments:" >&2
    echo "  <owner>/<project>  COPR project (e.g., kadmium/bluez-midi)" >&2
    echo "  <package-name>     Package name (e.g., bluez)" >&2
    echo "  <fedora-version>   Fedora version (e.g., fedora-42)" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $0 kadmium/bluez-midi bluez fedora-42" >&2
    exit 1
fi

repo="copr:copr.fedorainfracloud.org:$(echo "$PROJECT_PATH" | tr '/' ':')"
release_ver="${FEDORA_VERSION#fedora-}"

# Use dnf list to get package info and parse the version
package_info=$(sudo dnf --repo="$repo" --releasever="$release_ver" list "$PACKAGE" 2>/dev/null)

# Extract version from the output (format: package.arch version.release repo)
package_version=$(echo "$package_info" | grep "^$PACKAGE\." | head -1 | awk '{print $2}' | sed 's/\.fc[0-9]*$//')

if [ -n "$package_version" ]; then
    echo "$package_version"
    exit 0
else
    echo "Error: Package '$PACKAGE' not found in COPR project $PROJECT_PATH (Fedora $release_ver)" >&2
    exit 1
fi

