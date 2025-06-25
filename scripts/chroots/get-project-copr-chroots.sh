#!/bin/bash
set -e

# Script to extract chroots from a COPR project
# Usage: ./get-project-copr-chroots.sh <owner>/<project> [--ci]
# Or: copr-cli get <owner>/<project> | ./get-project-copr-chroots.sh [--ci]

# Function to extract chroots from copr-cli get output
extract_chroots() {
    local input="$1"
    
    # Look for the Repo(s): section and extract chroot names
    # The format is: "    chroot-name: https://..."
    echo "$input" | sed -n '/Repo(s):/,/^[A-Za-z]/p' | \
        grep -E '^\s+[a-z].*:' | \
        sed 's/^\s*//' | \
        sed 's/:.*$//' | \
        sort
}

# Function to get project info and extract chroots
get_project_chroots() {
    local project="$1"
    
    if [ -z "$project" ]; then
        echo "Error: Project name required" >&2
        echo "Usage: $0 <owner>/<project> [--ci]" >&2
        echo "   or: copr-cli get <owner>/<project> | $0 [--ci]" >&2
        exit 1
    fi
    
    # Get project info from copr-cli
    local copr_output
    copr_output=$(copr-cli get "$project" 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to get project info for $project" >&2
        exit 1
    fi
    
    # Extract chroots
    extract_chroots "$copr_output"
}

# Project name provided as argument
project="$1"

if [ -z "$project" ]; then
    # No input provided
    if [ "$CI_MODE" = false ]; then
        echo "Error: No project specified and no input from stdin" >&2
        echo "" >&2
        echo "Usage:" >&2
        echo "  $0 <owner>/<project>     - Get chroots for specific project" >&2
        echo "" >&2
        echo "Examples:" >&2
        echo "  $0 myuser/myproject" >&2
    fi
    exit 1
fi

get_project_chroots "$project"