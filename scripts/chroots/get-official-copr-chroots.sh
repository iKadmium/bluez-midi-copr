#!/bin/bash
set -e

# Check for CI mode
CI_MODE=false
if [ "$1" = "--ci" ] || [ "$1" = "-c" ]; then
    CI_MODE=true
fi

if [ "$CI_MODE" = false ]; then
    echo "Getting available COPR chroots..."
fi

# Function to get available chroots from COPR API
get_fedora_chroots() {
    if [ "$CI_MODE" = false ]; then
        echo "Querying COPR API for available Fedora chroots..." >&2
    fi
    
    # Get chroots from COPR API with better error handling
    API_RESPONSE=$(curl -s "https://copr.fedorainfracloud.org/api_3/mock-chroots/list" 2>/dev/null)
    
    if [ $? -ne 0 ] || [ -z "$API_RESPONSE" ]; then
        if [ "$CI_MODE" = false ]; then
            echo "Failed to connect to COPR API" >&2
        fi
        return
    fi
    
    # Check if jq can parse the response
    if ! echo "$API_RESPONSE" | jq . >/dev/null 2>&1; then
        if [ "$CI_MODE" = false ]; then
            echo "Invalid JSON response from COPR API" >&2
        fi
        return
    fi
    
    # Extract Fedora chroots (keys that match the pattern for x86_64 and aarch64)
    CHROOTS=$(echo "$API_RESPONSE" | jq -r 'keys[] | select(test("^fedora-([0-9]|rawhide)+-(x86_64|aarch64)$"))' | sort -V)
    
    if [ -z "$CHROOTS" ]; then
        if [ "$CI_MODE" = false ]; then
            echo "No Fedora chroots found in API response" >&2
        fi
    else
        echo "$CHROOTS"
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

# In CI mode, just output the chroots and exit
if [ "$CI_MODE" = true ]; then
    get_fedora_chroots
    exit 0
fi

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

echo ""
echo "# Usage:"
echo "# $0          - Show detailed output with suggestions"
echo "# $0 --ci     - CI mode: only output chroots (one per line)"
echo "# $0 -c       - Short form of --ci"
