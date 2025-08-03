#!/bin/bash

# 🔠 Capitalize first letter
capitalize() {
  echo "$1" | awk '{ print toupper(substr($0,1,1)) tolower(substr($0,2)) }'
}

for viewName in "$@"; do
  capitalizedViewName=$(capitalize "$viewName")
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
  // TODO: Logic add korte hobe ekhane
}
EOF

  # 📱 Mobile Screen File
  cat <<EOF > "$base_dir/screen/${viewName}_screen_mobile.dart"
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:your_project_name/core/utils/dimensions.dart'; // Adjust this path if needed
import '../controller/${viewName}_controller.dart';

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
import '../controller/${viewName}_controller.dart';
import '${viewName}_screen_mobile.dart';

class ${capitalizedViewName}Screen extends GetView<${capitalizedViewName}Controller> {
  const ${capitalizedViewName}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Layout(mobile: ${capitalizedViewName}ScreenMobile());
  }
}
EOF

  # 🔗 Binding File (lib/bind/)
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
  route_const="  static const $viewName = '/$viewName';"
  grep -qxF "$route_const" "$route_file" || sed -i "/static var list = RoutePageList.list;/a $route_const" "$route_file"

  # 📥 Add GetPage to pages.dart
  page_file="lib/routes/pages.dart"
  screen_import="import '../views/$viewName/screen/${viewName}_screen.dart';"
  binding_import="import '../bind/${viewName}_binding.dart';"

  # Import check and insert
  grep -qxF "$screen_import" "$page_file" || sed -i "/^import/a $screen_import" "$page_file"
  grep -qxF "$binding_import" "$page_file" || sed -i "/^import/a $binding_import" "$page_file"

  # 📌 Insert GetPage
  route_code="  GetPage(\n    name: Routes.$viewName,\n    page: () => const ${capitalizedViewName}Screen(),\n    binding: ${capitalizedViewName}Binding(),\n  ),"
  sed -i "/\/\/Page Route List/a $route_code" "$page_file"

  echo "✅ View '$viewName' created with proper screen, binding & route"
done
