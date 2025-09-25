#!/bin/bash

# import env
source "$(dirname "$0")/../.env"

if [ "$1" ]; then
# add .free as suffix if not present
  if [[ "$1" != *.free ]]; then
    FILENAME="$1.free"
  else
    FILENAME="$1"
  fi
else
  FILENAME="PPTemplate_$(date +%Y-%m-%d).free"
fi

cp -n $NOL_UTILS_DIR/pp/PPTemplate.free ./"$FILENAME"

open "$FILENAME"
