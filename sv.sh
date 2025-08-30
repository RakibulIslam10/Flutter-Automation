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
import '../controller/${viewName}_controller.dart';
import '../../../core/utils/layout.dart';

part '${viewName}_screen_mobile.dart';
EOF

  # 🔧 Add part lines for each widget file (if any exist)
  for widgetPath in "$base_dir/widget/"*.dart; do
    [ -e "$widgetPath" ] || continue
    widgetFileName=$(basename "$widgetPath")
    echo "part '../widget/$widgetFileName';" >> "$base_dir/screen/${viewName}_screen.dart"
  done

  # 🔚 Append class definition to screen.dart
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
  route_name="${viewName}Screen"
  route_const="  static const $route_name = '/$route_name';"
  grep -qxF "$route_const" "$route_file" || sed -i "/static var list = RoutePageList.list;/a $route_const" "$route_file"

  # 📥 Add imports + GetPage to pages.dart
  page_file="lib/routes/pages.dart"
  screen_import="import '../views/$viewName/screen/${viewName}_screen.dart';"
  binding_import="import '../bind/${viewName}_binding.dart';"

  # import গুলো part of এর পরেই ঢোকানো হবে
  grep -qxF "$screen_import" "$page_file" || sed -i "/^part of 'routes.dart';/a $screen_import" "$page_file"
  grep -qxF "$binding_import" "$page_file" || sed -i "/^part of 'routes.dart';/a $binding_import" "$page_file"

  route_code="    GetPage(
      name: Routes.${viewName}Screen,
      page: () => const ${capitalizedViewName}Screen(),
      binding: ${capitalizedViewName}Binding(),
    ),"

  # 🔑 Insert into //Page Route List
  grep -qxF "$route_code" "$page_file" || sed -i "/\/\/Page Route List/a $route_code" "$page_file"

  echo "✅ View '$viewName' created with clean structure, route, binding, and page entry"
done
