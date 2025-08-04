#!/bin/bash

# Usage: bash generate_widget_parts.sh view_name widget1 widget2 ...

# First argument is the view name (like: home, navigation, profile)
viewName=$1
shift

# Path setup
view_dir="lib/views/$viewName"
widget_dir="$view_dir/widget"
main_view_file="$view_dir/${viewName}_screen.dart"

mkdir -p "$widget_dir"

# Convert snake_case to PascalCase
to_pascal_case() {
  echo "$1" | sed -r 's/(^|_)([a-z])/\U\2/g'
}

# Ensure main view file has auto-generated comment section
if ! grep -q "// 🌟 Auto-generated part files" "$main_view_file"; then
  echo -e "\n// 🌟 Auto-generated part files" >> "$main_view_file"
fi

# Loop through widget names
for widgetName in "$@"; do
  file="$widget_dir/${widgetName}.dart"
  className=$(to_pascal_case "$widgetName")

  echo "🧱 Generating widget: $widgetName → class $className"

  # Create widget file with part of directive
  cat <<EOF > "$file"
part of '../${viewName}_screen.dart';

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

  # Add part directive to main view screen if not already present
  part_line="part 'widget/${widgetName}.dart';"
  if ! grep -Fxq "$part_line" "$main_view_file"; then
    echo "$part_line" >> "$main_view_file"
  fi
done

echo "✅ All widgets and part directives added successfully!"
