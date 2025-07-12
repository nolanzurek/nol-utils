#!/bin/bash

# Usage: ./get_youtube_thumbnails.sh <playlist_url_or_id> [-o output_folder] [-f image_format]
# Example: ./get_youtube_thumbnails.sh qwertyuiopasdfghjklzxcvbnm -o ./thumbnails -f jpg

set -e

source "$(dirname "$0")/../.env"

# Default values
OUTDIR="$OUTPUT_DIR/youtube_thumbnails_$(date +%Y%m%d_%H%M%S)"
FORMAT="png"
PLAYLIST=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output)
            OUTDIR="$2"
            shift 2
            ;;
        -f|--format)
            FORMAT="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 <playlist_url_or_id> [-o output_folder] [-f image_format]"
            echo "  -o, --output    Output folder (default: ./thumbnails_YYYYMMDD_HHMMSS)"
            echo "  -f, --format    Image format (default: png)"
            echo "  -h, --help      Show this help message"
            echo ""
            echo "Example: $0 qwertyuiopasdfghjklzxcvbnm -o ./thumbnails -f jpg"
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
    echo "Usage: $0 <playlist_url_or_id> [-o output_folder] [-f image_format]"
    echo "Use -h or --help for more information"
    exit 1
fi

# If only playlist ID is given, construct the full URL
if [[ "$PLAYLIST" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    PLAYLIST="https://www.youtube.com/playlist?list=$PLAYLIST"
fi

mkdir -p "$OUTDIR"

yt-dlp \
    --skip-download \
    --write-thumbnail \
    --convert-thumbnails "$FORMAT" \
    --output "$OUTDIR/%(title)s.%(ext)s" \
    "$PLAYLIST"