#!/bin/bash
set -e

PROJECT="kadmium/bluez-midi"
PACKAGE="bluez"

./scripts/chroots/verify-project-chroots.sh $PROJECT
sudo dnf copr enable -y $PROJECT && sudo dnf update
chroots=$(./scripts/chroots/get-project-copr-chroots.sh $PROJECT)

# Extract unique Fedora versions from chroots
fedora_versions=$(echo "$chroots" | sed 's/-[^-]*$//' | sort -u)
echo "Fedora versions:"
echo "$fedora_versions"

# Extract architectures from chroots
architectures=$(echo "$chroots" | sed 's/.*-//' | sort -u | tr '\n' ' ')
echo "Architectures:"
echo "$architectures"

# Loop through each Fedora version and run update-package-spec
echo ""
echo "Checking for new versions..."
echo "$fedora_versions" | while read -r version; do
    if [ -n "$version" ]; then
        echo "Processing $version..."
        echo "Getting latest $PACKAGE version for $version..."
        latest_version=$(./scripts/spec/get-latest-package-version.sh "$version" "$PACKAGE")
        echo "Latest $PACKAGE version for $version: $latest_version"
        # Check if the latest version is newer than the last processed version
        echo "Checking $PACKAGE version in COPR project $PROJECT..." >&2
        last_processed_version=$(./scripts/spec/get-copr-package-version.sh $PROJECT "$PACKAGE" "$version")
        latest_version=$(./scripts/spec/get-latest-package-version.sh "$version" "$PACKAGE")
        if [ $? -ne 0 ]; then
            echo "Error getting COPR version for $version - assuming new version" >&2
            latest_version=0
        else
            echo "Last processed $PACKAGE version for $version: $last_processed_version"
        fi
        if [ "$latest_version" = "$last_processed_version" ]; then
            echo "No update needed for $version (latest version is already processed)."
            continue
        fi

        rm -rf work
        ./scripts/spec/update-package-spec.sh "$version" "$PACKAGE"
    fi
done

rm -rf work

echo ""
echo "Running update-copr for each spec directory..."
if [ -d "spec" ]; then
    for spec_dir in spec/*/; do
        if [ -d "$spec_dir" ]; then
            version=$(basename "$spec_dir")
            echo "Processing spec directory: $version"
            
            # Get architectures that have chroots for this specific version
            version_architectures=$(echo "$chroots" | grep "^$version-" | sed 's/.*-//' | sort -u | tr '\n' ' ')
            echo "Available architectures for $version: $version_architectures"
            ./scripts/spec/update-copr.sh $PROJECT "$version" "$PACKAGE" "$version_architectures"
        fi
    done
else
    echo "No spec directory found."
fi

