#!/bin/bash

# 🔠 Function: Capitalize first letter of view name
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

  # 🧠 Controller File
  cat <<EOF > "$base_dir/controller/${viewName}_controller.dart"
import 'package:get/get.dart';

class ${capitalizedViewName}Controller extends GetxController {
  // TODO: Logic add korte hobe ekhane
}
EOF

  # 📱 Mobile Screen Part
  cat <<EOF > "$base_dir/screen/${viewName}_screen_mobile.dart"
part of "${viewName}_screen.dart";

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/${viewName}_controller.dart';

class ${capitalizedViewName}ScreenMobile extends GetView<${capitalizedViewName}Controller> {
  const ${capitalizedViewName}ScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16.0), // Customizable
          children: const [],
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

part '${viewName}_screen_mobile.dart';

class ${capitalizedViewName}Screen extends GetView<${capitalizedViewName}Controller> {
  const ${capitalizedViewName}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return ${capitalizedViewName}ScreenMobile(); // Desktop support optional
  }
}
EOF

  # 📎 Binding File
  cat <<EOF > "$base_dir/${viewName}_binding.dart"
import 'package:get/get.dart';
import 'controller/${viewName}_controller.dart';

class ${capitalizedViewName}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<${capitalizedViewName}Controller>(() => ${capitalizedViewName}Controller());
  }
}
EOF

  # 🛣️ Add Route Name to routes.dart (if using named routes)
  route_file="lib/routes/routes.dart"
  route_name="  static const ${viewName}Screen = '/${viewName}-screen';"
  sed -i "/\/\/Route Name List/a $route_name" "$route_file"

  # 📍 Add GetPage to pages.dart
  page_file="lib/routes/pages.dart"
  route_code="  GetPage(\n    name: Routes.${viewName}Screen,\n    page: () => const ${capitalizedViewName}Screen(),\n    binding: ${capitalizedViewName}Binding(),\n  ),"
  sed -i "/\/\/Page Route List/a $route_code" "$page_file"

  echo "✅ View '$viewName' generated successfully"
done
