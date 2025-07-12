# !/bin/bash

vaults_dir=$1
outputs_dir=$2

ls $(find $vaults_dir -type d -name plugins -maxdepth 3) | sort | egrep -v '^[./]' | uniq > "$outputs_dir/obsidian_plugins.txt"

# note: maxdepth 3 is used to avoid listing plugins from nested obsidian vaults