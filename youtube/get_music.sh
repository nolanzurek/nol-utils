#!/bin/bash
set -e

# import env
source "$(dirname "$0")/../.env"

$NOL_UTILS_DIR/youtube/download_youtube_playlist_audio.sh "$1" --output-dir-path "$MUSIC_DIR"