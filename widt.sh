#!/bin/bash

# Usage: bash generate_widget_parts.sh view_name widget1 widget2 ...

# Validate input
if [ -z "$1" ]; then
  echo "❌ Usage: $0 <view_name> [widget_names...]"
  exit 1
fi

# Variables
viewName=$1
shift
widgetNames=("$@")

view_dir="lib/views/$viewName"
widget_dir="$view_dir/widget"
main_view_file="$view_dir/${viewName}_screen.dart"

# Create directories if not exist
mkdir -p "$widget_dir"
mkdir -p "$(dirname "$main_view_file")"

# Convert snake_case to PascalCase function
to_pascal_case() {
  echo "$1" | sed -r 's/(^|_)([a-z])/\U\2/g'
}

# Create main screen file if missing
if [ ! -f "$main_view_file" ]; then
  echo "🆕 Creating main screen file: $main_view_file"
  cat > "$main_view_file" <<EOF
import 'package:flutter/material.dart';

/// Auto-generated screen for $viewName view.

// 🌟 Auto-generated part files
EOF
fi

# Ensure auto-generated comment is present
if ! grep -q "// 🌟 Auto-generated part files" "$main_view_file"; then
  echo "// 🌟 Auto-generated part files" >> "$main_view_file"
fi

# Generate widgets
for widgetName in "${widgetNames[@]}"; do
  widgetFile="$widget_dir/${widgetName}.dart"
  className=$(to_pascal_case "$widgetName")
  partDirective="part 'widget/${widgetName}.dart';"

  echo "🧱 Generating widget: $widgetName → class $className"

  # Skip if widget file already exists
  if [ -f "$widgetFile" ]; then
    echo "⚠️  $widgetFile already exists. Skipping..."
  else
    cat > "$widgetFile" <<EOF
part of '../${viewName}_screen.dart';

import 'package:flutter/material.dart';

class ${className} extends StatelessWidget {
  const ${className}({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$className'),
    );
  }
}
EOF
    echo "✅ Created widget file: $widgetFile"
  fi

  # Add part directive to main screen if missing
  if ! grep -Fxq "$partDirective" "$main_view_file"; then
    echo "$partDirective" >> "$main_view_file"
    echo "✅ Added part directive for $widgetName in main screen"
  fi
done

echo "🎉 All widget files and part directives processed successfully!"
