#!/bin/bash

if [ "$1" == "." ]; then
  dir="$(basename "$(pwd)")"
elif [ "$1" == ".." ]; then
  dir="$(basename "$(dirname "$(pwd)")")"
elif [[ "$1" == */* ]]; then
  dir="$(basename "$1")"
elif [ -n "$1" ]; then
  dir="$1"
fi

echo "Opening vault $dir..."
open "obsidian://open?vault=$dir"
