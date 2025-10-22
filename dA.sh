#!/bin/bash

# ===========================================
# 🔧 Flutter Unused Asset Cleaner (by Rakib)
# ===========================================

# Folders to scan
ASSET_FOLDERS=("assets/dummy" "assets/icons" "assets/logo")

# Parse argument
MODE=${1:-dry-run}  # Default is dry-run if no argument is passed

if [[ "$MODE" == "delete-assets" ]]; then
    DRY_RUN=false
    echo "⚠️  Delete mode enabled. Unused assets will be removed!"
elif [[ "$MODE" == "dry-run-assets" ]]; then
    DRY_RUN=true
    echo "👀 Dry-run mode enabled. Only showing unused assets..."
else
    echo "Usage:"
    echo "  ./rakib.sh dry-run-assets    # Show unused assets"
    echo "  ./rakib.sh delete-assets     # Delete unused assets"
    exit 1
fi

# Collect all used assets from Dart files
echo "🔍 Scanning Dart code for asset references..."
USED_ASSETS=$(grep -rho "assets/[^'\"[:space:]]*" lib | sort | uniq)

if [ -z "$USED_ASSETS" ]; then
    echo "⚠️  No asset references found in lib/. Make sure your code uses asset paths."
fi

# Loop through each asset folder
for FOLDER in "${ASSET_FOLDERS[@]}"; do
    if [ ! -d "$FOLDER" ]; then
        echo "🚫 Folder not found: $FOLDER (skipping)"
        continue
    fi

    echo ""
    echo "📁 Checking folder: $FOLDER"

    # Use process substitution to avoid subshell issue
    while IFS= read -r FILE; do
        KEEP=false
        BASENAME_FILE=$(basename "$FILE")

        for USED in $USED_ASSETS; do
            BASENAME_USED=$(basename "$USED")
            if [[ "$BASENAME_FILE" == "$BASENAME_USED" ]]; then
                KEEP=true
                break
            fi
        done

        if [ "$KEEP" = false ]; then
            if [ "$DRY_RUN" = true ]; then
                echo "   [DRY RUN] Would delete: $FILE"
            else
                echo "   🗑️ Deleting: $FILE"
                rm "$FILE"
            fi
        fi
    done < <(find "$FOLDER" -type f)
done

echo ""
echo "✅ Done!"
if [ "$DRY_RUN" = true ]; then
    echo "💡 Tip: Run './rakib.sh delete-assets' to actually remove them."
fi
