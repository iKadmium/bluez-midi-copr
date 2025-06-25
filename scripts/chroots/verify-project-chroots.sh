#!/bin/bash
set -e

# Script to verify and update COPR project chroots to match official available chroots
# Usage: ./verify-project-chroots.sh <owner>/<project> [--dry-run]

PROJECT="$1"
DRY_RUN=false

if [ "$2" = "--dry-run" ] || [ "$2" = "-n" ]; then
    DRY_RUN=true
fi

if [ -z "$PROJECT" ]; then
    echo "Error: Project name required" >&2
    echo "Usage: $0 <owner>/<project> [--dry-run]" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  --dry-run, -n    Show what would be changed without making changes" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $0 myuser/myproject" >&2
    echo "  $0 myuser/myproject --dry-run" >&2
    exit 1
fi

echo "Verifying chroots for COPR project: $PROJECT"
echo "============================================="

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Look for the chroot scripts in various locations
OFFICIAL_SCRIPT=""
PROJECT_SCRIPT=""

# Check in the script directory first
if [ -f "$SCRIPT_DIR/get-official-copr-chroots.sh" ]; then
    OFFICIAL_SCRIPT="$SCRIPT_DIR/get-official-copr-chroots.sh"
elif [ -f "$SCRIPT_DIR/../get-official-copr-chroots.sh" ]; then
    OFFICIAL_SCRIPT="$SCRIPT_DIR/../get-official-copr-chroots.sh"
elif [ -f "$SCRIPT_DIR/../../get-official-copr-chroots.sh" ]; then
    OFFICIAL_SCRIPT="$SCRIPT_DIR/../../get-official-copr-chroots.sh"
fi

if [ -f "$SCRIPT_DIR/get-project-copr-chroots.sh" ]; then
    PROJECT_SCRIPT="$SCRIPT_DIR/get-project-copr-chroots.sh"
elif [ -f "$SCRIPT_DIR/../get-project-copr-chroots.sh" ]; then
    PROJECT_SCRIPT="$SCRIPT_DIR/../get-project-copr-chroots.sh"
elif [ -f "$SCRIPT_DIR/../../get-project-copr-chroots.sh" ]; then
    PROJECT_SCRIPT="$SCRIPT_DIR/../../get-project-copr-chroots.sh"
fi

if [ -z "$OFFICIAL_SCRIPT" ]; then
    echo "Error: get-official-copr-chroots.sh not found" >&2
    exit 1
fi

if [ -z "$PROJECT_SCRIPT" ]; then
    echo "Error: get-project-copr-chroots.sh not found" >&2
    exit 1
fi

echo "Getting official COPR chroots..."
OFFICIAL_CHROOTS=$("$OFFICIAL_SCRIPT" --ci)
if [ $? -ne 0 ] || [ -z "$OFFICIAL_CHROOTS" ]; then
    echo "Error: Failed to get official chroots" >&2
    exit 1
fi

echo "Getting project chroots..."
PROJECT_CHROOTS=$("$PROJECT_SCRIPT" "$PROJECT" --ci)
if [ $? -ne 0 ]; then
    echo "Error: Failed to get project chroots for $PROJECT" >&2
    echo "Make sure the project exists and you have access to it." >&2
    exit 1
fi

# Create temporary files for comparison
OFFICIAL_TEMP=$(mktemp)
PROJECT_TEMP=$(mktemp)
trap 'rm -f "$OFFICIAL_TEMP" "$PROJECT_TEMP"' EXIT

echo "$OFFICIAL_CHROOTS" > "$OFFICIAL_TEMP"
echo "$PROJECT_CHROOTS" > "$PROJECT_TEMP"

# Compare the lists
echo ""
echo "Official chroots:"
echo "$OFFICIAL_CHROOTS" | sed 's/^/  /'

echo ""
echo "Project chroots:"
echo "$PROJECT_CHROOTS" | sed 's/^/  /'

# Check for differences
MISSING_CHROOTS=$(comm -23 "$OFFICIAL_TEMP" "$PROJECT_TEMP")
EXTRA_CHROOTS=$(comm -13 "$OFFICIAL_TEMP" "$PROJECT_TEMP")

echo ""
if [ -z "$MISSING_CHROOTS" ] && [ -z "$EXTRA_CHROOTS" ]; then
    echo "✅ Project chroots are up to date!"
    exit 0
fi

echo "Differences found:"
if [ -n "$MISSING_CHROOTS" ]; then
    echo "  Missing chroots (available but not configured):"
    echo "$MISSING_CHROOTS" | sed 's/^/    /'
fi

if [ -n "$EXTRA_CHROOTS" ]; then
    echo "  Extra chroots (configured but not available):"
    echo "$EXTRA_CHROOTS" | sed 's/^/    /'
fi

echo ""
if [ "$DRY_RUN" = true ]; then
    echo "🔍 DRY RUN: Would update project to use these chroots:"
    echo "$OFFICIAL_CHROOTS" | sed 's/^/    /'
    echo ""
    echo "Command that would be run:"
    CHROOT_ARGS=$(echo "$OFFICIAL_CHROOTS" | sed 's/^/--chroot /' | tr '\n' ' ')
    echo "  copr-cli modify $PROJECT $CHROOT_ARGS"
    exit 0
fi

echo "🔧 Updating project chroots..."

# Build the copr-cli modify command
CHROOT_ARGS=$(echo "$OFFICIAL_CHROOTS" | sed 's/^/--chroot /' | tr '\n' ' ')

echo "Running: copr-cli modify $PROJECT $CHROOT_ARGS"
if copr-cli modify $PROJECT $CHROOT_ARGS; then
    echo "✅ Successfully updated project chroots!"
    echo ""
    echo "Updated chroots:"
    echo "$OFFICIAL_CHROOTS" | sed 's/^/  /'
else
    echo "❌ Failed to update project chroots" >&2
    exit 1
fi