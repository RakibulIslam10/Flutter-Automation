#!/usr/bin/env bash

MODE=$1

# 🧩 Asset folders to check
ASSET_FOLDERS=("assets/icons" "assets/logo" "assets/dummy")

echo "🚀 FlutterGen Asset Cleaner"
echo "Mode: $MODE"
echo ""

# ✅ Collect all used asset references from Dart files
USED_ASSETS=$(grep -rhoE "Assets\.[A-Za-z0-9_\.]+|assets/[A-Za-z0-9_/\.-]+" lib | sort | uniq)

echo "🔍 Scanning for unused assets..."
echo ""

UNUSED_COUNT=0
DELETED_COUNT=0

# Loop through all files in assets folders
for FOLDER in "${ASSET_FOLDERS[@]}"; do
  if [ ! -d "$FOLDER" ]; then
    echo "⚠️ Folder $FOLDER not found, skipping..."
    continue
  fi

  find "$FOLDER" -type f | while read FILE; do
    FILE_BASENAME=$(basename "$FILE")
    KEEP=false

    # Check if used in Dart code (with or without .path)
    for USED in $USED_ASSETS; do
      if echo "$USED" | grep -q "$FILE_BASENAME"; then
        KEEP=true
        break
      fi
    done

    if [ "$KEEP" = false ]; then
      ((UNUSED_COUNT++))
      if [ "$MODE" == "dry-run" ]; then
        echo "❌ Unused: $FILE"
      elif [ "$MODE" == "delete" ]; then
        echo "🗑️ Deleting: $FILE"
        rm -f "$FILE"
        ((DELETED_COUNT++))
      fi
    fi
  done
done

echo ""
if [ "$MODE" == "dry-run" ]; then
  echo "🔍 Dry Run Complete → Total unused: $UNUSED_COUNT"
else
  echo "✅ Deleted $DELETED_COUNT unused assets"
fi
