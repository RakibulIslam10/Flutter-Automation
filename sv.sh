#!/usr/bin/env bash
set -e

BASE_DIR="lib"

# Snake_case → PascalCase
to_pascal_case() {
  IFS=_ read -ra parts <<< "$1"
  for part in "${parts[@]}"; do
    printf "%s" "$(tr '[:lower:]' '[:upper:]' <<< "${part:0:1}")${part:1}"
  done
}

# RoutePageList.list auto add
add_to_route_page_list() {
  local viewName="$1"
  local pascalName
  pascalName=$(to_pascal_case "$viewName")
  local routePageListFile="$BASE_DIR/routes/route_page_list.dart"

  if [ ! -f "$routePageListFile" ]; then
    echo "❌ $routePageListFile ফাইল নেই!"
    return
  fi

  local lineNumber
  lineNumber=$(grep -n "//Page Route List" "$routePageListFile" | cut -d: -f1)

  if [ -z "$lineNumber" ]; then
    echo "❌ //Page Route List comment পাওয়া যায়নি!"
    return
  fi

  sed -i "$((lineNumber+1)) i\    GetPage(\n      name: Routes.$viewName,\n      page: () => const ${pascalName}Screen(),\n      binding: ${pascalName}Binding(),\n    ),\n" "$routePageListFile"
  echo "✅ $pascalName GetPage যুক্ত হয়েছে RoutePageList.list এ"
}

# Generate Local View
generate_local_view() {
  local viewName="$1"
  local pascalName
  pascalName=$(to_pascal_case "$viewName")

  # Folder structure
  mkdir -p "$BASE_DIR/views/$viewName/screen" \
           "$BASE_DIR/views/$viewName/widget" \
           "$BASE_DIR/views/$viewName/controller" \
           "$BASE_DIR/bind"

  # Screen
  cat > "$BASE_DIR/views/$viewName/screen/${viewName}_screen.dart" <<EOF
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/layout.dart';
import '../controller/${viewName}_controller.dart';
part '../widget/${viewName}_widget.dart';

class ${pascalName}Screen extends GetView<${pascalName}Controller> {
  const ${pascalName}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Layout(
      mobile: Scaffold(
        body: Center(child: Text('$pascalName Screen')),
      ),
    );
  }
}
EOF

  # Controller
  cat > "$BASE_DIR/views/$viewName/controller/${viewName}_controller.dart" <<EOF
import 'package:get/get.dart';

class ${pascalName}Controller extends GetxController {}
EOF

  # Binding
  cat > "$BASE_DIR/bind/${viewName}_binding.dart" <<EOF
import 'package:get/get.dart';
import '../views/$viewName/controller/${viewName}_controller.dart';

class ${pascalName}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<${pascalName}Controller>(() => ${pascalName}Controller());
  }
}
EOF

  # Widget
  cat > "$BASE_DIR/views/$viewName/widget/${viewName}_widget.dart" <<EOF
part of '../screen/${viewName}_screen.dart';

class ${pascalName}Widget extends StatelessWidget {
  const ${pascalName}Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('$pascalName Widget');
  }
}
EOF

  add_to_route_page_list "$viewName"

  echo "✅ View '$viewName' local তৈরি হয়েছে!"
}

# Main
echo "📥 Enter View Names (space-separated) for local generation:"
read -r viewNames

for view in $viewNames; do
    generate_local_view "$view"
done
