#! /bin/bash

working_dir=$1
outputs_dir=$2

cat $(find $working_dir -type f -path "*/.obsidian/plugins/quick-latex/data.json" -maxdepth 5) \
    | jq -r ".customShorthand_parameter" \
    | sed 's/;*$//;s/$/;/' \
    | grep -v '^;$' \
    | sort | uniq \
    > "$outputs_dir/obsidian_latex_shortcuts.txt"
