#!/usr/bin/env bash

# =========================================
# FlutterGen Smart Asset Cleaner
# =========================================

MODE=$1   # dry-run / delete

# ✅ Folders to scan
ASSET_FOLDERS=("assets/icons" "assets/logo" "assets/dummy")

# ✅ Assets to always keep (even if .path used)
KEEP_REFERENCES=(
  "Assets.icons.notification"
  "Assets.icons.notification.path"
  "Assets.dummy.logo"
  "Assets.dummy.logo.path"
  "Assets.logo.appLogo"
  "Assets.logo.appLogo.path"
)

echo "🚀 FlutterGen Asset Cleaner"
echo "Mode: $MODE"
echo ""

# --- Step 1: Collect all asset references from Dart code ---
USED_ASSETS=$(grep -rhoE "Assets\.[A-Za-z0-9_\.]+|[a-zA-Z0-9_]+\.component85" lib | sort | uniq)

echo "🔍 Scanning for unused assets..."
echo ""

UNUSED_COUNT=0
DELETED_COUNT=0

# --- Step 2: Loop through all asset files ---
for FOLDER in "${ASSET_FOLDERS[@]}"; do
  if [ ! -d "$FOLDER" ]; then
    echo "⚠️ Folder $FOLDER not found, skipping..."
    continue
  fi

  find "$FOLDER" -type f | while read FILE; do
    FILE_BASENAME=$(basename "$FILE")
    KEEP=false

    # --- Step 2a: Check against used assets and KEEP_REFERENCES ---
    for USED in $USED_ASSETS; do
      for KEEP_REF in "${KEEP_REFERENCES[@]}"; do
        if [[ "$USED" == *"$KEEP_REF"* ]]; then
          KEEP=true
          break 2
        fi
      done
    done

    # --- Step 2b: Delete if not used ---
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

# --- Step 3: Summary ---
echo ""
if [ "$MODE" == "dry-run" ]; then
  echo "🔍 Dry Run Complete → Total unused assets: $UNUSED_COUNT"
else
  echo "✅ Deleted $DELETED_COUNT unused assets"
fi
