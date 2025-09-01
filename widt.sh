#!/bin/bash

viewName=$1
shift

widget_dir="lib/views/$viewName/widget"
screen_file="lib/views/$viewName/screen/${viewName}_screen.dart"
mkdir -p "$widget_dir"

to_pascal_case() {
  local input=$1
  local output=""
  IFS='_' read -ra parts <<< "$input"
  for part in "${parts[@]}"; do
    output+="${part^}"
  done
  echo "$output"
}

for widgetName in "$@"; do
  pascalName=$(to_pascal_case "$widgetName")
  file="$widget_dir/${widgetName}.dart"

  echo "🧱 Generating GetView widget: $pascalName → HomeController"

  # Create widget file
  cat <<EOF > "$file"
part of '../screen/${viewName}_screen.dart';

class ${pascalName}WidgetView extends GetView<HomeController> {
  const ${pascalName}WidgetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('${pascalName}WidgetView');
  }
}
EOF

  # Add part line into home_screen.dart if not exists
  part_line="part '../widget/${widgetName}.dart';"
  if ! grep -Fxq "$part_line" "$screen_file"; then
    echo "$part_line" >> "$screen_file"
    echo "🔗 Added part to $screen_file"
  else
    echo "ℹ️ Part already exists in $screen_file"
  fi
done

echo "✅ GetView widgets created and linked successfully!"
