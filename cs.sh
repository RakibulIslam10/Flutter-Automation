#!/usr/bin/env bash
set -e  # Error হলে স্ক্রিপ্ট থামবে

# 🌈 Terminal Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

BASE_DIR="lib"

echo -e "${CYAN}📁 Creating Your Custom Structure ...${NC}"

# --- Bindings folder
mkdir -p "$BASE_DIR/bind"
mkdir -p "$BASE_DIR/views"

# --- Core folders
mkdir -p "$BASE_DIR/core"/{api,helpers,languages,themes,utils}
mkdir -p "$BASE_DIR/core/api"/{end_point,services}

# Core files
touch "$BASE_DIR/core/api/services"/{api_request.dart,auth_services.dart}
touch "$BASE_DIR/core/api/end_point"/api_end_points.dart
touch "$BASE_DIR/core/utils"/{basic_import.dart,app_storage.dart,app_storage_model.dart,custom_style.dart,dimensions.dart,extensions.dart,layout.dart,space.dart}
touch "$BASE_DIR/core/helpers"/{helpers.dart}

# --- Resources
mkdir -p "$BASE_DIR/res"
touch "$BASE_DIR/res/assets.dart"

# --- Routes
mkdir -p "$BASE_DIR/routes"
touch "$BASE_DIR/routes"/{pages.dart,routes.dart}

# --- Main entry files
touch "$BASE_DIR"/{main.dart,initial.dart}





















# ---------------- main.dart
echo -e "${YELLOW}📄 Writing main.dart ...${NC}"
cat <<EOF > "$BASE_DIR/main.dart"
import 'core/utils/basic_import.dart';
import 'initial.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Initial.init();
 // Get.put(NetworkController());

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      ensureScreenSize: true,
      designSize: const Size(375, 812),
      builder: (_, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/', // later change to Routes.splashScreen
        title: 'My App',   // later use Strings.appName
        theme: ThemeData.light(),  // later use Themes.light
        darkTheme: ThemeData.dark(), // later use Themes.dark
        getPages: [], // later add Routes.list
        themeMode: ThemeMode.light,
        builder: (context, widget) {
          ScreenUtil.init(context);
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: widget!,
            ),
          );
        },
      ),
    );
  }
}
EOF

# ---------------- initial.dart
cat <<EOF > "$BASE_DIR/initial.dart"
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';

class Initial {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await GetStorage.init();
    await ScreenUtil.ensureScreenSize();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
EOF

echo -e "${GREEN}✅ Flutter project structure created successfully!${NC}"
