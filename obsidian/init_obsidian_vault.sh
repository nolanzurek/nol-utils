#!/bin/bash

source ../.env

working_dir=$(pwd)

new_vault_name=$1

if [ -z "$new_vault_name" ]; then
    echo "Usage: $0 <new_vault_name>"
    exit 1
fi

new_vault_path="${OBSIDIAN_VAULTS_DIR}/${new_vault_name}"

if [ -d "$new_vault_path" ]; then
    echo "Error: Vault '$new_vault_name' already exists in $OBSIDIAN_VAULTS_DIR"
    exit 1
fi

# create a private github repo for the new vault, then clone it

gh repo create "$new_vault_name" --private
if [ $? -ne 0 ]; then
    echo "Error: Failed to create GitHub repository '$new_vault_name'."
    echo "Ensure the GitHub CLI is installed and authenticated using 'gh auth login'."
    exit 1
fi

cd "$OBSIDIAN_VAULTS_DIR"
git clone "https://github.com/$GITHUB_USERNAME/$new_vault_name.git"
if [ $? -ne 0 ]; then
    echo "Error: Failed to clone the GitHub repository '$new_vault_name'."
    exit 1
fi

cd "$new_vault_name"

# mkdir -p "$new_vault_path/.obsidian"

if [ ! -d "$OBSIDIAN_CANONICAL_VAULT_PATH" ]; then
    echo "Error: Canonical vault not specified, using any vault in $OBSIDIAN_VAULTS_DIR"
    canonical_vault=$(find "$OBSIDIAN_VAULTS_DIR" -maxdepth 1 -type d | head -n 1)
    echo "Using canonical vault: $canonical_vault"
else
    canonical_vault="$OBSIDIAN_CANONICAL_VAULT_PATH"
    echo "Using canonical vault: $canonical_vault"
fi

cp -r "$canonical_vault/.obsidian" .

git add .
git commit -m "Initial commit for new Obsidian vault: $new_vault_name"
git push origin main

echo "New Obsidian vault '$new_vault_name' created successfully at $new_vault_path."
cd "$working_dir"

exit 0
