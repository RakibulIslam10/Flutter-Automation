#!/bin/bash

# ===========================================
# 🔧 Flutter Unused Asset Cleaner (Remote Version)
# ===========================================

ASSET_FOLDERS=("assets/dummy" "assets/icons" "assets/logo")

MODE=${1:-dry-run}

if [[ "$MODE" == "delete" ]]; then
  DRY_RUN=false
  echo "⚠️ Delete mode enabled. Unused assets will be removed!"
else
  DRY_RUN=true
  echo "👀 Dry-run mode enabled. Only showing unused assets..."
fi

echo "🔍 Scanning Dart code for asset references..."
USED_ASSETS=$(grep -rho "assets/[^'\"[:space:]]*" lib | sort | uniq)

for FOLDER in "${ASSET_FOLDERS[@]}"; do
  if [ ! -d "$FOLDER" ]; then
    echo "🚫 Folder not found: $FOLDER (skipping)"
    continue
  fi

  echo ""
  echo "📁 Checking folder: $FOLDER"

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
  echo "💡 Tip: Use './rakib.sh delete-unused-assets' to actually delete them."
fi
