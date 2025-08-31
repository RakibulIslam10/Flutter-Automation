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
  controllerName="${pascalName}Controller"
  file="$widget_dir/${widgetName}.dart"

  echo "🧱 Generating GetView widget: $pascalName → $controllerName"

  cat <<EOF > "$file"
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/${widgetName}_controller.dart';

class ${pascalName}View extends GetView<$controllerName> {
  const ${pascalName}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('${pascalName}View'),
    );
  }
}
EOF

done

echo "✅ GetView widgets created successfully!"
