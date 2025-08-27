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

  # 🛤️ Add route constant to routes.dart
  route_file="lib/routes/routes.dart"
  route_name="${viewName}Screen"
  route_const="  static const $route_name = '/$route_name';"
  grep -qxF "$route_const" "$route_file" || sed -i "/static var list = RoutePageList.list;/a $route_const" "$route_file"

  # 📥 Add GetPage to pages.dart
  page_file="lib/routes/pages.dart"
  screen_import="import '../views/$viewName/screen/${viewName}_screen.dart';"
  binding_import="import '../bind/${viewName}_binding.dart';"

  grep -qxF "$screen_import" "$page_file" || sed -i "/^import/a $screen_import" "$page_file"
  grep -qxF "$binding_import" "$page_file" || sed -i "/^import/a $binding_import" "$page_file"

  route_code="    GetPage(\n    name: Routes.$viewName,\n    page: () => const ${capitalizedViewName}Screen(),\n    binding: ${capitalizedViewName}Binding(),\n  ),"
  sed -i "/\/\/Page Route List/a $route_code" "$page_file"

  echo "✅ View '$viewName' created with clean structure, route, binding, and widget part links"
done
