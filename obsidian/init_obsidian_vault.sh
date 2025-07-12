#!/bin/bash

source ../.env

working_dir=$(pwd)

new_vault_name=$1

if [ -z "$new_vault_name" ]; then
    echo "Usage: $0 <new_vault_name>"
    exit 1
fi

new_vault_path="${OBSIDIAN_VAULTS_DIR}/${new_vault_name}"

mkdir -p "$new_vault_path/.obsidian"

if [ ! -d "$OBSIDIAN_CANONICAL_VAULT_PATH" ]; then
    echo "Error: Canonical vault not specified, using any vault in $OBSIDIAN_VAULTS_DIR"
    canonical_vault=$(find "$OBSIDIAN_VAULTS_DIR" -maxdepth 1 -type d | head -n 1)
    echo "Using canonical vault: $canonical_vault"
else
    canonical_vault="$OBSIDIAN_CANONICAL_VAULT_PATH"
fi

cp -r "$canonical_vault/.obsidian" "$new_vault_path/"

# init git repo
cd "$new_vault_path"
git init
git add .
git commit -m "Initialize Obsidian vault with default settings"
git push -u origin main

cd "$working_dir"

exit 0