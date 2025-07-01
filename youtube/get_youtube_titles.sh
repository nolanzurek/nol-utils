#!/bin/bash

# Usage: ./get_youtube_titles.sh <playlist_url_or_id> <output_file>
# Example: ./get_youtube_titles.sh qwertyuiopasdfghjklzxcvbnm ./titles.txt

set -e

PLAYLIST="$1"
OUTFILE="$2"

if [ -z "$PLAYLIST" ] || [ -z "$OUTFILE" ]; then
    echo "Usage: $0 <playlist_url_or_id> <output_file>"
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