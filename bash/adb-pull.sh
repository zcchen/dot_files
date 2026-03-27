#!/bin/bash

# Function to display help and exit with a specific code
show_help() {
    local exit_code=$1
    echo "Usage: $(basename "$0") [-h|--help] <FILE_Wildcard> [DEST]"
    echo "  Pulls files from an Android device using wildcards. Important: Always wrap the wildcard path in quotes."
    echo "  Arguments:"
    echo "      <FILE_Wildcard>  Remote path with wildcards (e.g., \"/sdcard/*.png\")"
    echo "      [DEST]           Local destination directory (default: current directory)"
    echo "  Options:"
    echo "      -h, --help       Show this help info and exit"
    exit "$exit_code"
}

# Core logic function
pull_android_files() {
    local remote_pattern="$1"
    local local_dest="${2:-.}"
    # Check for device connection
    if ! adb get-state &>/dev/null; then
        echo "Error: Device not found or unauthorized." >&2
        return 1
    fi
    # Get file list, strip carriage returns (\r), and handle empty results
    local files
    files=$(adb shell ls -d "$remote_pattern" 2>/dev/null | tr -d '\r')
    if [[ -z "$files" ]]; then
        echo "Error: No files found matching: '$remote_pattern'" >&2
        return 1
    fi
    # Create local directory if needed
    mkdir -p "$local_dest" || {
        echo "Error: Failed to create '$local_dest'" >&2
        return 1
    }
    # Pull files one by one to handle wildcards correctly
    echo "Starting pull..."
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        if adb pull "$file" "$local_dest"; then
            echo "Pulled: '$file'"
        else
            echo "Failed: '$file'" >&2
        fi
    done <<< "$files"
    return 0
}

# --- Argument Parsing ---
# Check for explicit help request
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help 0
# Validate argument count, If no arguments are provided OR more than 2 are provided, show error and exit 1
elif [[ "$#" -lt 1 || "$#" -gt 2 ]]; then
    echo "Error: Invalid number of parameters." >&2
    echo ""
    show_help 1
fi
# Run the function
pull_android_files "$1" "$2"
