#!/usr/bin/env bash

# ✅ Read mode (dry-run or delete)
MODE=$1

# Folders to scan
ASSET_FOLDERS=("assets/dummy" "assets/icons" "assets/logo")

# Collect all used assets from Dart files
USED_ASSETS=$(grep -rho "assets/[^'\"\s]*" lib | sort | uniq)

if [ "$MODE" == "dry-run" ]; then
  echo "🔍 Running in DRY RUN mode — will only show unused assets"
else
  echo "🧹 Running in DELETE mode — unused assets will be deleted"
fi

echo ""
echo "🔎 Scanning for unused assets..."

# Loop through each asset folder
for FOLDER in "${ASSET_FOLDERS[@]}"; do
  if [ ! -d "$FOLDER" ]; then
    echo "⚠️ Folder $FOLDER does not exist, skipping."
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
      if [ "$MODE" == "dry-run" ]; then
        echo "❌ Unused: $FILE"
      else
        echo "🗑️ Deleting: $FILE"
        rm -f "$FILE"
      fi
    fi
  done
done

echo ""
echo "✅ Done!"
