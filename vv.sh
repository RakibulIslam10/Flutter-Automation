#!/bin/bash

# 🔠 Convert snake_case to PascalCase
capitalize() {
  IFS='_' read -ra parts <<< "$1"
  result=""
  for part in "${parts[@]}"; do
    result+=$(echo "${part:0:1}" | tr '[:lower:]' '[:upper:]')${part:1}
  done
  echo "$result"
}

# 🔡 Convert PascalCase to camelCase
camelCase() {
  str="$1"
  first="${str:0:1}"
  rest="${str:1}"
  echo "${first,,}$rest"
}

for viewName in "$@"; do
  capitalizedViewName=$(capitalize "$viewName")           # e.g., DetailsPreview
  routeName=$(camelCase "${capitalizedViewName}Screen")  # e.g., detailsPreviewScreen
  base_dir="lib/views/$viewName"
  echo "📦 Generating view: $viewName"

  mkdir -p "$base_dir/controller"
  mkdir -p "$base_dir/screen"
  mkdir -p "$base_dir/widget"
  mkdir -p "lib/bind"

  # 🎯 Controller File
  cat <<EOF > "$base_dir/controller/${viewName}_controller.dart"
import 'package:get/get.dart';

class ${capitalizedViewName}Controller extends GetxController {
  // TODO: Logic
}
EOF

  # 📱 Mobile Screen File
  cat <<EOF > "$base_dir/screen/${viewName}_screen_mobile.dart"
part of '${viewName}_screen.dart';

class ${capitalizedViewName}ScreenMobile extends GetView<${capitalizedViewName}Controller> {
  const ${capitalizedViewName}ScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
          children: [
            
          ],
        ),
      ),
    );
  }
}
EOF

  # 🧩 Main Screen File
  cat <<EOF > "$base_dir/screen/${viewName}_screen.dart"
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/layout.dart';
import '../controller/${viewName}_controller.dart';

part '${viewName}_screen_mobile.dart';
EOF

  # 🔚 Append class definition to main screen
  cat <<EOF >> "$base_dir/screen/${viewName}_screen.dart"

class ${capitalizedViewName}Screen extends GetView<${capitalizedViewName}Controller> {
  const ${capitalizedViewName}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Layout(mobile: ${capitalizedViewName}ScreenMobile());
  }
}
EOF

  # 🔗 Binding File
  cat <<EOF > "lib/bind/${viewName}_binding.dart"
import 'package:get/get.dart';
import '../views/$viewName/controller/${viewName}_controller.dart';

class ${capitalizedViewName}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<${capitalizedViewName}Controller>(() => ${capitalizedViewName}Controller());
  }
}
EOF

  # 🛤️ Add route constant to routes.dart
  route_file="lib/routes/routes.dart"
  route_const="  static const $routeName = '/$routeName';"
  grep -qxF "$route_const" "$route_file" || sed -i "/class RoutePageList/i $route_const" "$route_file"

  # 📥 Add GetPage to pages.dart
  page_file="lib/routes/pages.dart"
  screen_import="import '../views/$viewName/screen/${viewName}_screen.dart';"
  binding_import="import '../bind/${viewName}_binding.dart';"

  grep -qxF "$screen_import" "$page_file" || sed -i "/^import/a $screen_import" "$page_file"
  grep -qxF "$binding_import" "$page_file" || sed -i "/^import/a $binding_import" "$page_file"

  # Multi-line GetPage insertion using printf
  route_code=$(printf "    GetPage(\n      name: Routes.%s,\n      page: () => const %sScreen(),\n      binding: %sBinding(),\n    )," "$routeName" "$capitalizedViewName" "$capitalizedViewName")

  # Insert after '//Page Route List' inside the list
  sed -i "/\/\/Page Route List/a $route_code" "$page_file"

  echo "✅ View '$viewName' created with clean structure, camelCase route, binding, and properly indented GetPage"
done
