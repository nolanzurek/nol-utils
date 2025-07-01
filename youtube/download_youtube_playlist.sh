#!/bin/bash

# Usage: ./download_youtube_playlist.sh <playlist_url_or_id> <output_folder> [quality]
# Example: ./download_youtube_playlist.sh qwertyuiopasdfghjklzxcvbnm ./downloads best
# Quality options: best, worst, 720p, 480p, etc. Default is 'best'

set -e

PLAYLIST="$1"
OUTDIR="$2"
QUALITY="${3:-best}"

if [ -z "$PLAYLIST" ] || [ -z "$OUTDIR" ]; then
    echo "Usage: $0 <playlist_url_or_id> <output_folder> [quality]"
    echo "Quality options: best, worst, 720p, 480p, etc. Default is 'best'"
    exit 1
fi

# If only playlist ID is given, construct the full URL
if [[ "$PLAYLIST" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    PLAYLIST="https://www.youtube.com/playlist?list=$PLAYLIST"
fi

mkdir -p "$OUTDIR"

echo "Downloading playlist to: $OUTDIR"
echo "Quality: $QUALITY"

yt-dlp \
    --format "$QUALITY" \
    --output "$OUTDIR/%(playlist_index)02d - %(title)s.%(ext)s" \
    --embed-metadata \
    --write-description \
    --write-info-json \
    "$PLAYLIST"

echo "Download complete!"