#!/usr/bin/env bash
set -e

# 🌈 Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

BASE_DIR="lib"

# Snake_case → PascalCase
to_pascal_case() {
  echo "$1" | sed -r 's/(^|_)([a-z])/\U\2/g'
}

# Snake_case → camelCase
to_camel_case() {
  local input=$(to_pascal_case "$1")
  echo "$(tr '[:upper:]' '[:lower:]' <<< ${input:0:1})${input:1}"
}

# ✅ Add GetPage to route_page_list.dart
add_to_route_page_list() {
  local viewName=$1
  local pascalName=$2
  local routePageListFile="lib/routes/route_page_list.dart"

  if [ ! -f "$routePageListFile" ]; then
    echo -e "${RED}❌ $routePageListFile ফাইল পাওয়া যায়নি!${NC}"
    return
  fi

  local lineNumber
  lineNumber=$(grep -n "//Page Route List" "$routePageListFile" | cut -d: -f1)

  if [ -z "$lineNumber" ]; then
    echo -e "${RED}❌ //Page Route List comment পাওয়া যায়নি!${NC}"
    return
  fi

  sed -i "$((lineNumber+1)) i\    GetPage(\n      name: Routes.$viewName,\n      page: () => const ${pascalName}Screen(),\n      binding: ${pascalName}Binding(),\n    ),\n" "$routePageListFile"

  echo -e "${GREEN}✅ $pascalName route এ যুক্ত হয়েছে!${NC}"
}

# ✅ Generate Views
generate_views() {
  echo -ne "${CYAN}📥 Enter View Names (space-separated): ${NC}"
  read -r viewNames

  for viewName in $viewNames; do
    pascalName=$(to_pascal_case "$viewName")
    camelName=$(to_camel_case "$viewName")

    viewDir="$BASE_DIR/views/$viewName"
    screenDir="$viewDir/screen"
    widgetDir="$viewDir/widget"
    controllerDir="$viewDir/controller"
    bindDir="lib/bind"

    mkdir -p "$screenDir" "$widgetDir" "$controllerDir" "$bindDir"

    # Screen file
    screenFile="$screenDir/${viewName}_screen.dart"
    if [ ! -f "$screenFile" ]; then
      cat > "$screenFile" <<EOF
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/dimensions.dart';
import '../controller/${viewName}_controller.dart';
import '../../../core/utils/layout.dart';
part '../widget/${viewName}_widget.dart';

class ${pascalName}Screen extends GetView<${pascalName}Controller> {
  const ${pascalName}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Layout(mobile: ${pascalName}Widget());
  }
}
EOF
      echo -e "${GREEN}✅ $screenFile তৈরি হয়েছে${NC}"
    fi

    # Widget file
    widgetFile="$widgetDir/${viewName}_widget.dart"
    if [ ! -f "$widgetFile" ]; then
      cat > "$widgetFile" <<EOF
part of '../screen/${viewName}_screen.dart';

class ${pascalName}Widget extends StatelessWidget {
  const ${pascalName}Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("$pascalName")),
      body: Center(child: Text("$pascalName Screen")),
    );
  }
}
EOF
      echo -e "${GREEN}✅ $widgetFile তৈরি হয়েছে${NC}"
    fi

    # Controller file
    controllerFile="$controllerDir/${viewName}_controller.dart"
    if [ ! -f "$controllerFile" ]; then
      cat > "$controllerFile" <<EOF
import 'package:get/get.dart';

class ${pascalName}Controller extends GetxController {
  // Controller Logic
}
EOF
      echo -e "${GREEN}✅ $controllerFile তৈরি হয়েছে${NC}"
    fi

    # Binding file
    bindingFile="$bindDir/${viewName}_binding.dart"
    if [ ! -f "$bindingFile" ]; then
      cat > "$bindingFile" <<EOF
import 'package:get/get.dart';
import '../views/$viewName/controller/${viewName}_controller.dart';

class ${pascalName}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<${pascalName}Controller>(() => ${pascalName}Controller());
  }
}
EOF
      echo -e "${GREEN}✅ $bindingFile তৈরি হয়েছে${NC}"
    fi

    # Add Route
    add_to_route_page_list "$viewName" "$pascalName"
  done
}

# ✅ Menu
case $1 in
  generate-views)
    generate_views
    ;;
  *)
    echo -e "${CYAN}Usage: ./rakib.sh generate-views${NC}"
    ;;
esac
