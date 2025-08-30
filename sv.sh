#!/bin/bash
set -e

# 🔠 Capitalize first letter
capitalize() {
  echo "$1" | awk '{ print toupper(substr($0,1,1)) tolower(substr($0,2)) }'
}

# Ensure route and pages files exist
route_file="lib/routes/routes.dart"
page_file="lib/routes/pages.dart"

[ -f "$route_file" ] || echo -e "class Routes {\n  static var list = RoutePageList.list;\n}" > "$route_file"
[ -f "$page_file" ] || echo -e "//Page Route List\n" > "$page_file"

for viewName in "$@"; do
  capitalizedViewName=$(capitalize "$viewName")
  base_dir="lib/views/$viewName"
  echo "📦 Generating view: $viewName"

  mkdir -p "$base_dir/controller" "$base_dir/screen" "$base_dir/widget" "lib/bind"

  # 🎯 Controller File
  cat <<EOF > "$base_dir/controller/${viewName}_controller.dart"
import 'package:get/get.dart';

class ${capitalizedViewName}Controller extends GetxController {
  // TODO: Add your logic here
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
            // Add your widgets here
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
import '../controller/${viewName}_controller.dart';
import '../../../core/utils/layout.dart';
part '${viewName}_screen_mobile.dart';
EOF

  # 🔧 Add part lines for widget files if exist
  for widgetPath in "$base_dir/widget/"*.dart; do
    [ -e "$widgetPath" ] || continue
    widgetFileName=$(basename "$widgetPath")
    echo "part '../widget/$widgetFileName';" >> "$base_dir/screen/${viewName}_screen.dart"
  done

  # 🔚 Append main screen class
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

  # 🛤️ Add route constant
  route_const="  static const ${viewName}Screen = '/${viewName}Screen';"
  grep -qxF "$route_const" "$route_file" || sed -i "/static var list = RoutePageList.list;/a $route_const" "$route_file"

  # 📥 Add GetPage to pages.dart
  screen_import="import '../views/$viewName/screen/${viewName}_screen.dart';"
  binding_import="import '../bind/${viewName}_binding.dart';"

  grep -qxF "$screen_import" "$page_file" || sed -i "/^import/i $screen_import" "$page_file"
  grep -qxF "$binding_import" "$page_file" || sed -i "/^import/i $binding_import" "$page_file"

  route_code="    GetPage(
      name: Routes.${viewName}Screen,
      page: () => const ${capitalizedViewName}Screen(),
      binding: ${capitalizedViewName}Binding(),
    ),"
  sed -i "/\/\/Page Route List/a $route_code" "$page_file"

  echo "✅ View '$viewName' created with clean structure, route, binding, and widget part links"
done
