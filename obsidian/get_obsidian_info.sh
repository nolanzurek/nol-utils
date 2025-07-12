#!/bin/bash

source "$(dirname "$0")/../.env"

./get_latex_shortcuts.sh $OBSIDIAN_VAULTS_DIR $OUTPUT_DIR
./get_plugins.sh $OBSIDIAN_VAULTS_DIR $OUTPUT_DIR