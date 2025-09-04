#!/bin/bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <viewName> <widget1> [widget2 ...]"
  echo "Example: $0 home category services_list search_bar"
  exit 1
fi

viewName=$1
shift

widget_dir="lib/views/$viewName/widget"
screen_file="lib/views/$viewName/screen/${viewName}_screen.dart"

mkdir -p "$widget_dir"

if [ ! -f "$screen_file" ]; then
  echo "Error: screen file not found at $screen_file"
  echo "Make sure you're running the script from project root and the screen file exists."
  exit 1
fi

to_pascal_case() {
  local input=$1
  local output=""
  IFS='_' read -ra parts <<< "$input"
  for part in "${parts[@]}"; do
    output+="${part^}"
  done
  echo "$output"
}

controllerPascal=$(to_pascal_case "$viewName")
controllerName="${controllerPascal}Controller"

for widgetName in "$@"; do
  pascalName=$(to_pascal_case "$widgetName")
  widget_filename="${widgetName}_widget.dart"
  widget_file="$widget_dir/$widget_filename"
  className="${pascalName}Widget"

  echo "🧱 Generating: $widget_file  (class $className extends GetView<$controllerName>)"

  cat > "$widget_file" <<EOF
part of '../screen/${viewName}_screen.dart';

class ${className} extends GetView<$controllerName> {
  const ${className}({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossStart,
      children: [
      Text('${className}');


      ],
    );
  }
}
EOF

  part_line="part '../widget/${widget_filename}';"

  # find last import line number (0 if none)
  last_import_line=$(grep -n "^import " "$screen_file" | tail -n1 | cut -d: -f1 || true)
  if [ -z "$last_import_line" ]; then
    last_import_line=0
  fi

  # find last existing part line after the imports
  last_part_line=$(awk -v start="$last_import_line" 'NR>start && $0 ~ /^part / {p=NR} END{ if(p) print p }' "$screen_file" || true)

  if [ -n "$last_part_line" ]; then
    insertion_line=$((last_part_line+1))
  else
    insertion_line=$((last_import_line+1))
  fi

  # only add if not already present
  if grep -Fxq "$part_line" "$screen_file"; then
    echo "  ℹ️ Part already exists in $screen_file"
  else
    tmp=$(mktemp)
    awk -v ins="$insertion_line" -v line="$part_line" 'BEGIN{inserted=0}
    { if(NR==ins){ print line; inserted=1 } print }
    END{ if(!inserted) print line }' "$screen_file" > "$tmp" && mv "$tmp" "$screen_file"
    echo "  🔗 Added: $part_line"
  fi
done

echo "✅ Done: widgets created and linked in $screen_file"
