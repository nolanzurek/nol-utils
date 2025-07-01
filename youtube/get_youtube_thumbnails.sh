#!/bin/bash

# Usage: ./get_youtube_thumbnails.sh <playlist_url_or_id> <output_folder> <image_format>
# Example: ./get_youtube_thumbnails.sh qwertyuiopasdfghjklzxcvbnm ./thumbnails jpg

set -e

PLAYLIST="$1"
OUTDIR="$2"
FORMAT="$3"

if [ -z "$PLAYLIST" ] || [ -z "$OUTDIR" ] || [ -z "$FORMAT" ]; then
    echo "Usage: $0 <playlist_url_or_id> <output_folder> <image_format>"
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