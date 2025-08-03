#!/bin/bash

viewName=$1
shift

widget_dir="lib/views/$viewName/widget"
mkdir -p "$widget_dir"

for widgetName in "$@"; do
  file="$widget_dir/${widgetName}.dart"
  echo "🧱 Generating widget: $widgetName"

  cat <<EOF > "$file"
import 'package:flutter/material.dart';

class ${widgetName^}Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('${widgetName^}'),
    );
  }
}
EOF
done

echo "✅  Widgets created successfully!"
