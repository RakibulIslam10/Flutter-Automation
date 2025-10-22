for FOLDER in "${ASSET_FOLDERS[@]}"; do
    if [ ! -d "$FOLDER" ]; then continue; fi
    find "$FOLDER" -type f | while read FILE; do
        BASENAME_FILE=$(basename "$FILE")
        KEEP=false
        for USED in $USED_ASSETS; do
            BASENAME_USED=$(basename "$USED")
            if [ "$BASENAME_FILE" == "$BASENAME_USED" ]; then
                KEEP=true
                break
            fi
        done
        if [ "$KEEP" = false ]; then
            if [ "$DRY_RUN" = true ]; then
                echo "[DRY RUN] $FILE"
            else
                echo "Deleting $FILE"
                rm "$FILE"
            fi
        fi
    done
done
