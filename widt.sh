#!/bin/bash

viewName=$1
shift

widget_dir="lib/views/$viewName/widget"
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

done

echo "✅ GetView widgets created successfully!"
