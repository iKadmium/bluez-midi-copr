#!/bin/bash
set -e

echo "Getting available COPR chroots..."

# Function to get available chroots from COPR API
get_fedora_chroots() {
    echo "Querying COPR API for available Fedora chroots..." >&2
    
    # Get chroots from COPR API with better error handling
    API_RESPONSE=$(curl -s "https://copr.fedorainfracloud.org/api_3/mock-chroots/list" 2>/dev/null)
    
    if [ $? -ne 0 ] || [ -z "$API_RESPONSE" ]; then
        echo "Failed to connect to COPR API, using fallback list..." >&2
        echo "fedora-40-x86_64"
        echo "fedora-40-aarch64"
        echo "fedora-41-x86_64"
        echo "fedora-41-aarch64" 
        echo "fedora-42-x86_64"
        echo "fedora-42-aarch64"
        echo "fedora-rawhide-x86_64"
        echo "fedora-rawhide-aarch64"
        return
    fi
    
    # Check if jq can parse the response
    if ! echo "$API_RESPONSE" | jq . >/dev/null 2>&1; then
        echo "Invalid JSON response from COPR API, using fallback list..." >&2
        echo "fedora-40-x86_64"
        echo "fedora-40-aarch64"
        echo "fedora-41-x86_64"
        echo "fedora-41-aarch64" 
        echo "fedora-42-x86_64"
        echo "fedora-42-aarch64"
        echo "fedora-rawhide-x86_64"
        echo "fedora-rawhide-aarch64"
        return
    fi
    
    # Extract Fedora chroots (keys that match the pattern for x86_64 and aarch64)
    CHROOTS=$(echo "$API_RESPONSE" | jq -r 'keys[] | select(test("^fedora-[0-9]+-(x86_64|aarch64)$"))' | sort -V)
    
    if [ -z "$CHROOTS" ]; then
        echo "No Fedora chroots found in API response, using fallback list..." >&2
        echo "fedora-40-x86_64"
        echo "fedora-40-aarch64"
        echo "fedora-41-x86_64"
        echo "fedora-41-aarch64" 
        echo "fedora-42-x86_64"
        echo "fedora-42-aarch64"
        echo "fedora-rawhide-x86_64"
        echo "fedora-rawhide-aarch64"
    else
        echo "$CHROOTS"
        # Add rawhide if it exists in the API
        if echo "$API_RESPONSE" | jq -r 'keys[]' | grep -q "fedora-rawhide-x86_64"; then
            echo "fedora-rawhide-x86_64"
        fi
        if echo "$API_RESPONSE" | jq -r 'keys[]' | grep -q "fedora-rawhide-aarch64"; then
            echo "fedora-rawhide-aarch64"
        fi
    fi
}

# Function to generate chroot arguments for copr-cli
generate_chroot_args() {
    local chroots="$1"
    echo "$chroots" | while read -r chroot; do
        if [ -n "$chroot" ]; then
            echo -n "--chroot $chroot "
        fi
    done
}

echo "Available Fedora chroots:"
echo "========================="
AVAILABLE_CHROOTS=$(get_fedora_chroots)
echo "$AVAILABLE_CHROOTS"

echo ""
echo "Suggested COPR commands:"
echo "========================"

# Generate the chroot arguments
CHROOT_ARGS=$(generate_chroot_args "$AVAILABLE_CHROOTS")

echo "# Create project with all current Fedora versions:"
echo "copr-cli create bluez-midi $CHROOT_ARGS"
echo ""

echo "# Or create with just stable releases (excluding rawhide):"
STABLE_CHROOTS=$(echo "$AVAILABLE_CHROOTS" | grep -v rawhide)
STABLE_ARGS=$(generate_chroot_args "$STABLE_CHROOTS")
echo "copr-cli create bluez-midi $STABLE_ARGS"

echo ""
echo "# Modify existing project to add/update chroots:"
echo "copr-cli modify bluez-midi $CHROOT_ARGS"

echo ""
echo "# Submit build for all configured chroots:"
echo "copr-cli build bluez-midi *.spec --sources *.tar.*"
