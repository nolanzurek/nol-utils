#!/bin/bash

# Usage: ./get_youtube_titles.sh <playlist_url_or_id> [-o output_file]
# Example: ./get_youtube_titles.sh qwertyuiopasdfghjklzxcvbnm -o ./titles.txt

set -e

source "$(dirname "$0")/../.env"

# Default values
OUTFILE="$OUTPUT_DIR/youtube_titles_$(date +%Y%m%d_%H%M%S).txt"
PLAYLIST=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output)
            OUTFILE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 <playlist_url_or_id> [-o output_file]"
            echo "  -o, --output    Output file (default: ./titles_YYYYMMDD_HHMMSS.txt)"
            echo "  -h, --help      Show this help message"
            echo ""
            echo "Example: $0 qwertyuiopasdfghjklzxcvbnm -o ./titles.txt"
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            if [ -z "$PLAYLIST" ]; then
                PLAYLIST="$1"
            else
                echo "Error: Multiple playlist arguments provided"
                exit 1
            fi
            shift
            ;;
    esac
done

if [ -z "$PLAYLIST" ]; then
    echo "Error: Playlist URL or ID is required"
    echo "Usage: $0 <playlist_url_or_id> [-o output_file]"
    echo "Use -h or --help for more information"
    exit 1
fi

# If only playlist ID is given, construct the full URL
if [[ "$PLAYLIST" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    PLAYLIST="https://www.youtube.com/playlist?list=$PLAYLIST"
fi

# Create output directory if it doesn't exist
mkdir -p "$(dirname "$OUTFILE")"

echo "Extracting video titles from playlist: $PLAYLIST"
echo "Output file: $OUTFILE"

yt-dlp \
    --skip-download \
    --print "%(title)s" \
    "$PLAYLIST" > "$OUTFILE"

echo "Done! Video titles saved to $OUTFILE"