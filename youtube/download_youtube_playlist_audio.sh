#!/bin/bash

# Usage: ./download_youtube_playlist.sh <playlist_url_or_id> <output_folder> [quality]
# Example: ./download_youtube_playlist.sh qwertyuiopasdfghjklzxcvbnm ./downloads best
# Quality options: best, worst, 720p, 480p, etc. Default is 'best'

set -e

# import env
source "$(dirname "$0")/../.env"

PLAYLIST="$1"
OUTDIR_NAME="$2"

if [ -z "$OUTDIR_NAME" ]; then
    OUTDIR_NAME="youtube_playlist_$(date +%Y%m%d_%H%M%S)"
fi

OUTDIR="$OUTPUT_DIR/$OUTDIR_NAME"

if [ -z "$PLAYLIST" ]; then
    echo "Usage: $0 <playlist_url_or_id> <output_folder_name>?"
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