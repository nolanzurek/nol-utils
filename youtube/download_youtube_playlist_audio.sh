#!/bin/bash

# Usage: ./download_youtube_playlist.sh <playlist_url_or_id> <output_folder> [quality]
# Example: ./download_youtube_playlist.sh qwertyuiopasdfghjklzxcvbnm ./downloads best
# Quality options: best, worst, 720p, 480p, etc. Default is 'best'

set -e

# import env
source "$(dirname "$0")/../.env"

# Initialize variables
PLAYLIST=""
OUTDIR_PATH=""
OUTDIR_NAME=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --output-dir-path)
            OUTDIR_PATH="$2"
            shift 2
            ;;
        --output-dir-name)
            OUTDIR_NAME="$2"
            shift 2
            ;;
        -*)
            echo "Unknown option: $1"
            echo "Usage: $0 <playlist_url_or_id> [--output-dir-path <path>] [--output-dir-name <name>]"
            exit 1
            ;;
        *)
            if [ -z "$PLAYLIST" ]; then
                PLAYLIST="$1"
            else
                echo "Unexpected argument: $1"
                echo "Usage: $0 <playlist_url_or_id> [--output-dir-path <path>] [--output-dir-name <name>]"
                exit 1
            fi
            shift
            ;;
    esac
done

# Set defaults if not provided
if [ -z "$OUTDIR_NAME" ]; then
    OUTDIR_NAME=""
fi

if [ -z "$OUTDIR_PATH" ]; then
    OUTDIR_PATH="$OUTPUT_DIR"
fi

OUTDIR="$OUTDIR_PATH/$OUTDIR_NAME"

if [ -z "$PLAYLIST" ]; then
    echo "Usage: $0 <playlist_url_or_id> [--output-dir-path <path>] [--output-dir-name <name>]"
    exit 1
fi

# If only playlist ID is given, construct the full URL
if [[ "$PLAYLIST" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    PLAYLIST="https://www.youtube.com/playlist?list=$PLAYLIST"
fi

mkdir -p "$OUTDIR"

echo "Downloading playlist to: $OUTDIR"

yt-dlp \
    -f "ba[ext=m4a]" \
    --output "$OUTDIR/%(playlist_index)02d - %(title)s.%(ext)s" \
    --embed-metadata \
    "$PLAYLIST"

echo "Download complete!"