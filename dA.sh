#!/bin/bash

# Folders to scan
ASSET_FOLDERS=("assets/dummy" "assets/icons" "assets/logo")

# Dry run mode (set to true to only print, false to delete)
DRY_RUN=false

# Collect all used assets from Dart files
USED_ASSETS=$(grep -rho "assets/[^'\"\s]*" lib | sort | uniq)

echo "Scanning for unused assets..."

# Loop through each asset folder
for FOLDER in "${ASSET_FOLDERS[@]}"; do
    if [ ! -d "$FOLDER" ]; then
        echo "Folder $FOLDER does not exist, skipping."
        continue
    fi

    # Loop through all files in the folder
    find "$FOLDER" -type f | while read FILE; do
        KEEP=false
        for USED in $USED_ASSETS; do
            BASENAME_USED=$(basename "$USED")
            BASENAME_FILE=$(basename "$FILE")
            if [ "$BASENAME_USED" == "$BASENAME_FILE" ]; then
                KEEP=true
                break
            fi
        done

        if [ "$KEEP" = false ]; then
            if [ "$DRY_RUN" = true ]; then
                echo "[DRY RUN] Would delete: $FILE"
            else
                echo "Deleting: $FILE"
                rm "$FILE"
            fi
        fi
    done
done

echo "✅ Done!"
