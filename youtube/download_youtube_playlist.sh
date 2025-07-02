#!/bin/bash

# Usage: ./download_youtube_playlist.sh <playlist_url_or_id> <output_folder> [quality]
# Example: ./download_youtube_playlist.sh qwertyuiopasdfghjklzxcvbnm ./downloads best
# Quality options: best, worst, 720p, 480p, etc. Default is 'best'

set -e

PLAYLIST="$1"
OUTDIR="$2"

if [ -z "$PLAYLIST" ] || [ -z "$OUTDIR" ]; then
    echo "Usage: $0 <playlist_url_or_id> <output_folder>"
    exit 1
fi

# If only playlist ID is given, construct the full URL
if [[ "$PLAYLIST" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    PLAYLIST="https://www.youtube.com/playlist?list=$PLAYLIST"
fi

mkdir -p "$OUTDIR"

echo "Downloading playlist to: $OUTDIR"

yt-dlp \
    -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" \
    --output "$OUTDIR/%(playlist_index)02d - %(title)s.%(ext)s" \
    --embed-metadata \
    "$PLAYLIST"

echo "Download complete!"