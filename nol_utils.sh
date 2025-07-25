#!/bin/bash
# filepath: /Users/nzurek/Programming/nol-utils/nol_utils.sh

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: nol_utils <script_name> [arguments...]"
    exit 1
fi

# Get script name and find it exactly one level down
SCRIPT_NAME="$1"
shift

# Find the script one level down in subfolders
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_SCRIPT=$(find "$SCRIPT_DIR" -maxdepth 2 -name "${SCRIPT_NAME}.sh" -type f | head -1)

# Check if script was found
if [ -z "$TARGET_SCRIPT" ]; then
    echo "Error: Script '${SCRIPT_NAME}.sh' not found"
    exit 1
fi

# Execute the target script with remaining arguments
exec "$TARGET_SCRIPT" "$@"