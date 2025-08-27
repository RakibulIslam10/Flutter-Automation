#!/usr/bin/env bash
set -e  # Error হলে স্ক্রিপ্ট থামবে

# 🌈 Terminal Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

BASE_DIR="lib"

echo -e "${CYAN}📁 Creating Your Custom Structure ...${NC}"

# --- Bindings
mkdir -p "$BASE_DIR/bind"
touch "$BASE_DIR/bind/splash_bindings.dart"

# --- Core folders
mkdir -p "$BASE_DIR/core"/{api,helpers,languages,themes,utils}
mkdir -p "$BASE_DIR/core/api"/{end_point,services}

touch "$BASE_DIR/core/api/services"/{api_request.dart,auth_services.dart}
touch "$BASE_DIR/core/api/end_point"/api_end_points.dart

touch "$BASE_DIR/core/utils"/{basic_import.dart,app_storage.dart,app_storage_model.dart,custom_style.dart,dimensions.dart,extensions.dart,layout.dart,space.dart}
touch "$BASE_DIR/core/helpers"/{helpers.dart,network_controller.dart}

# --- Resources
mkdir -p "$BASE_DIR/res"
touch "$BASE_DIR/res/assets.dart"

# --- Routes
mkdir -p "$BASE_DIR/routes"
touch "$BASE_DIR/routes"/{pages.dart,routes.dart}

# --- Views: splash
mkdir -p "$BASE_DIR/views/splash"/{controller,screens,widget}
touch "$BASE_DIR/views/splash/controller/splash_controller.dart"
touch "$BASE_DIR/views/splash/screens"/{splash_screen.dart,splash_screen_mobile.dart}

# --- Views: onboard
mkdir -p "$BASE_DIR/views/onboard"/{controller,screens,widget}
touch "$BASE_DIR/views/onboard/controller/onboard_controller.dart"
touch "$BASE_DIR/views/onboard/screens"/{onboard_screen.dart,onboard_screen_mobile.dart}

# --- Main entry files
touch "$BASE_DIR"/{main.dart,initial.dart}

# ---------------- main.dart
echo -e "${YELLOW}📄 Writing main.dart ...${NC}"
cat <<EOF > "$BASE_DIR/main.dart"
import 'core/helpers/network_controller.dart';
import 'core/utils/basic_import.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Initial.init();
  Get.put(NetworkController());

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
        initialRoute: Routes.splashScreen,
        title: Strings.appName,
        theme: Themes.light,
        darkTheme: Themes.dark,
        getPages: Routes.list,
        themeMode: ThemeMode.light,
        initialBinding: BindingsBuilder(() {
          Get.lazyPut(() => SplashController());
        }),
        builder: (context, widget) {
          ScreenUtil.init(context);
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
            child: Directionality(
              textDirection: Get.locale?.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: widget!,
            ),
          );
        },
      ),
    );
  }
}
EOF

# ---------------- Splash Screen with part
echo -e "${YELLOW}📄 Writing splash screen parts...${NC}"
cat <<EOF > "$BASE_DIR/views/splash/screens/splash_screen.dart"
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/splash_controller.dart';

part 'splash_screen_mobile.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SplashScreenMobile();
  }
}
EOF

cat <<EOF > "$BASE_DIR/views/splash/screens/splash_screen_mobile.dart"
part of 'splash_screen.dart';

class SplashScreenMobile extends GetView<SplashController> {
  const SplashScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Hello Rakib Vai 🚀")),
    );
  }
}
EOF

# ---------------- Onboard Screen with part
echo -e "${YELLOW}📄 Writing onboard screen parts...${NC}"
cat <<EOF > "$BASE_DIR/views/onboard/screens/onboard_screen.dart"
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/onboard_controller.dart';

part 'onboard_screen_mobile.dart';

class OnboardScreen extends StatelessWidget {
  const OnboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardScreenMobile();
  }
}
EOF

cat <<EOF > "$BASE_DIR/views/onboard/screens/onboard_screen_mobile.dart"
part of 'onboard_screen.dart';

class OnboardScreenMobile extends GetView<OnboardController> {
  const OnboardScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Onboarding 🚀")),
    );
  }
}
EOF
echo -e "${GREEN}✅ Your Flutter project structure was created successfully!${NC}"
