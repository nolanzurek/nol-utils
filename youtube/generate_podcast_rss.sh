#!/bin/bash

# Generate RSS feed for YouTube playlist audio downloads

set -e

# Import env
source "$(dirname "$0")/../.env"

PLAYLIST_FILE="$1"
RSS_DIR="$OUTPUT_DIR/rss"

# check if playlist file is provided
if [ -z "$PLAYLIST_FILE" ]; then
    echo "Usage: $0 <playlist_file>"
    exit 1
fi

# loop through all the playlists in the file and download them using 
# download_youtube_playlist_audio.sh
while IFS= read -r PLAYLIST; do
    if [[ -z "$PLAYLIST" || "$PLAYLIST" =~ ^# ]]; then
        continue  # skip empty lines and comments
    fi
    echo "Processing playlist: $PLAYLIST"
    $NOL_UTILS_DIR/youtube/download_youtube_playlist_audio.sh "$PLAYLIST" --output-dir-name "rss"
done < "$PLAYLIST_FILE"

# Generate RSS feed
echo "Generating RSS feed XML file in $RSS_DIR"
python3 "$NOL_UTILS_DIR/youtube/python_scripts/generate_rss_feed.py" "$RSS_DIR" "$RSS_FEED_URL"