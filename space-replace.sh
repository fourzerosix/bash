#!/bin/bash
# Authors: Dolphin Whisperer
# Created: 2025-01-17
# Description: This script does the darn thang.
#
# set the target directory (CHANGE THIS)
TARGET_DIR="/path/to/directory"

# find all files (not directories) with spaces in their names and rename them - by default - this only looks for files (add the d for dirs)
find "$TARGET_DIR" -type f | while read -r file; do
#find "$TARGET_DIR" -type d,f | while read -r file; do
    new_name=$(echo "$file" | sed 's/ /_/g')

    # Only rename if the filename has changed
    if [[ "$file" != "$new_name" ]]; then
        mv -v "$file" "$new_name"
    fi
done

echo "File renaming process complete."
