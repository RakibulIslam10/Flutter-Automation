#!/usr/bin/env bash

MODE=$1

ASSET_FOLDERS=("assets/dummy" "assets/icons" "assets/logo")

if [ "$MODE" == "dry-run" ]; then
  echo "🔍 Running in DRY RUN mode — will only show unused assets"
else
  echo "🧹 Running in DELETE mode — unused assets will be deleted"
fi

echo ""
echo "🔎 Collecting used assets from Dart files..."

# Collect assets used directly like 'assets/...'
USED_ASSETS=$(grep -rho "assets/[^'\"\s]*" lib 2>/dev/null)

# Collect FlutterGen asset references like Assets.icons.frame etc.
GEN_REFS=$(grep -rho "Assets\.[a-zA-Z0-9_\.]*" lib 2>/dev/null)

# Map FlutterGen keys to actual asset paths from generated file (flutter_gen)
if [ -f "lib/gen/assets.gen.dart" ]; then
  while read -r LINE; do
    # Extract path
    PATH_MATCH=$(echo "$LINE" | grep -o "'assets/[^']*'")
    if [ -n "$PATH_MATCH" ]; then
      CLEAN_PATH=$(echo "$PATH_MATCH" | tr -d "'")
      USED_ASSETS+=$'\n'"$CLEAN_PATH"
    fi
  done < lib/gen/assets.gen.dart
fi

# Remove duplicates
USED_ASSETS=$(echo "$USED_ASSETS" | sort | uniq)

echo "✅ Found $(echo "$USED_ASSETS" | wc -l) used asset references."
echo ""
echo "🔎 Scanning for unused assets..."

for FOLDER in "${ASSET_FOLDERS[@]}"; do
  if [ ! -d "$FOLDER" ]; then
    echo "⚠️ Folder $FOLDER does not exist, skipping."
    continue
  fi

  find "$FOLDER" -type f | while read FILE; do
    REL_PATH=$(echo "$FILE" | sed 's|^\./||')
    if echo "$USED_ASSETS" | grep -q "$REL_PATH"; then
      continue
    fi

    if [ "$MODE" == "dry-run" ]; then
      echo "❌ Unused: $FILE"
    else
      echo "🗑️ Deleting: $FILE"
      rm -f "$FILE"
    fi
  done
done

echo ""
echo "✅ Done!"
