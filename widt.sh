#!/bin/bash

# First arg = view name (example: home)
viewName=$1
shift

# Paths
view_dir="lib/views/$viewName"
widget_dir="$view_dir/widget"
main_view_file="$view_dir/${viewName}_screen.dart"

mkdir -p "$widget_dir"

# Convert snake_case to PascalCase
to_pascal_case() {
  echo "$1" | sed -r 's/(^|_)([a-z])/\U\2/g'
}

# Ensure part declarations exist in the main view file
if ! grep -q "part 'widget/" "$main_view_file"; then
  echo "🔗 Adding part directives to $main_view_file..."
  echo -e "\n// 🌟 Auto-generated part files" >> "$main_view_file"
fi

for widgetName in "$@"; do
  file="$widget_dir/${widgetName}.dart"
  className=$(to_pascal_case "$widgetName")

  echo "🧱 Generating widget: $widgetName → class $className"

  # Write the widget file
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

  # Add part directive to main file if not already present
  part_line="part 'widget/${widgetName}.dart';"
  if ! grep -Fxq "$part_line" "$main_view_file"; then
    echo "$part_line" >> "$main_view_file"
  fi
done

echo "✅ Widgets and part directives created successfully!"
