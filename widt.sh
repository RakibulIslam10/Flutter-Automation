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
part of '../screen/${viewName}_screen.dart';

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
