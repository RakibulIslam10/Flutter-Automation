import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Error: No view names provided.');
    return;
  }

  List<String> viewsList = args;

  Directory('lib/views').createSync(recursive: true);
  Directory('lib/bindings').createSync(recursive: true);

  String capitalize(String input) {
    if (input.isEmpty) return input;
    return input
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join('');
  }

  void writeFile(String path, String content) {
    File(path).createSync(recursive: true);
    File(path).writeAsStringSync(content);
  }

  void appendRoute(String className, String viewName) {
    final routesFile = File('lib/routes/routes.dart');
    if (routesFile.existsSync()) {
      final content = routesFile.readAsStringSync();
      final routeConstant =
          "  static const ${viewName}Screen = '/${viewName}Screen';\n";
      if (!content.contains(routeConstant)) {
        final insertPos = content.lastIndexOf('}');
        final newContent = content.substring(0, insertPos) +
            routeConstant +
            content.substring(insertPos);
        routesFile.writeAsStringSync(newContent);
        print("✅ Route constant added for $className");
      }
    }

    final pagesFile = File('lib/routes/route_pages.dart');
    if (pagesFile.existsSync()) {
      final content = pagesFile.readAsStringSync();
      final routeCode = """
    GetPage(
      name: Routes.${viewName}Screen,
      page: () => const ${className}Screen(),
      binding: ${className}Binding(),
    ),
""";
      final insertPos = content.indexOf('static var list = [');
      if (insertPos != -1) {
        final insertAfter = content.indexOf('[', insertPos) + 1;
        final newContent =
            content.substring(0, insertAfter) + '\n' + routeCode + content.substring(insertAfter);
        pagesFile.writeAsStringSync(newContent);
        print("✅ Route page added for $className");
      }
    }
  }

  for (var viewName in viewsList) {
    final className = capitalize(viewName);

    // Create folders
    Directory('lib/views/$viewName/controller').createSync(recursive: true);
    Directory('lib/views/$viewName/screen').createSync(recursive: true);
    Directory('lib/views/$viewName/widget').createSync(recursive: true);

    // File paths
    final controllerPath = 'lib/views/$viewName/controller/${viewName}_controller.dart';
    final screenPath = 'lib/views/$viewName/screen/${viewName}_screen.dart';
    final mobileScreenPath = 'lib/views/$viewName/screen/${viewName}_mobile_screen.dart';
    final tabletScreenPath = 'lib/views/$viewName/screen/${viewName}_tablet_screen.dart';
    final bindingPath = 'lib/bindings/${viewName}_binding.dart';

    // File contents
    final controllerContent = '''
import 'package:get/get.dart';

class ${className}Controller extends GetxController {}
''';

    final screenContent = '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/${viewName}_controller.dart';
part '${viewName}_mobile_screen.dart';
part '${viewName}_tablet_screen.dart';

class ${className}Screen extends GetView<${className}Controller> {
  const ${className}Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: ${className}MobileScreen(),
      tablet: ${className}TabletScreen(),
    );
  }
}
''';

    final mobileScreenContent = '''
part of '${viewName}_screen.dart';

class ${className}MobileScreen extends GetView<${className}Controller> {
  const ${className}MobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: []),
      ),
    );
  }
}
''';

    final tabletScreenContent = '''
part of '${viewName}_screen.dart';

class ${className}TabletScreen extends GetView<${className}Controller> {
  const ${className}TabletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: []),
      ),
    );
  }
}
''';

    final bindingContent = '''
import 'package:get/get.dart';
import '../views/$viewName/controller/${viewName}_controller.dart';

class ${className}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ${className}Controller());
  }
}
''';

    // Write files
    writeFile(controllerPath, controllerContent);
    writeFile(screenPath, screenContent);
    writeFile(mobileScreenPath, mobileScreenContent);
    writeFile(tabletScreenPath, tabletScreenContent);
    writeFile(bindingPath, bindingContent);

    // Add routes
    appendRoute(className, viewName);
  }

  print("✅ All views generated successfully!");
}
