#!/bin/bash

DART_SCRIPT_URL="https://raw.githubusercontent.com/RakibulIslam10/Flutter-Automation/refs/heads/main/sv.sh"
DART_SCRIPT="generate_views.dart"

if [ $# -eq 0 ]; then
  echo "Error: Please provide view names as arguments."
  exit 1
fi

# Download Dart generator
curl -sSL $DART_SCRIPT_URL -o $DART_SCRIPT

if [ ! -f "$DART_SCRIPT" ]; then
  echo "Error: Failed to download Dart script."
  exit 1
fi

# Run Dart generator with arguments
dart run $DART_SCRIPT "$@"

# Optional: clean up
rm -f $DART_SCRIPT

echo "✅ View generation completed!"
