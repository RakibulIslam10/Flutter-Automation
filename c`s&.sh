#!/usr/bin/env bash
set -e  # Error হলে স্ক্রিপ্ট থামবে

BASE_DIR="lib"

echo "📁 Creating Your Custom Structure ..."

# Bindings
mkdir -p "$BASE_DIR/bind"
touch "$BASE_DIR/bind/splash_bindings.dart"

# Core folders একসাথে
mkdir -p "$BASE_DIR/core"/{api,helpers,languages,themes,utils}

touch "$BASE_DIR/core/utils"/{basic_import.dart,app_storage.dart,app_storage_model.dart,custom_style.dart,dimensions.dart,extensions.dart,layout.dart,space.dart}

# Resources
mkdir -p "$BASE_DIR/res"
touch "$BASE_DIR/res/assets.dart"

# Routes
mkdir -p "$BASE_DIR/routes"
touch "$BASE_DIR/routes"/{pages.dart,routes.dart}

# Views: splash
mkdir -p "$BASE_DIR/views/splash"/{controller,screens,widget}
touch "$BASE_DIR/views/splash/screens"/{splash_screen_mobile.dart,splash_screen.dart}

# Views: onboard
mkdir -p "$BASE_DIR/views/onboard"/{controller,screens,widgets}
touch "$BASE_DIR/views/onboard/screens"/{onboard_screen_mobile.dart,onboard_screen.dart}

# Main entry files (brace expansion)
touch "$BASE_DIR"/{main.dart,initial.dart}

cat <<EOF > "$BASE_DIR/main.dart"
import 'core/helpers/network_controller.dart';
import 'core/utils/basic_import.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Initial.init();
  Get.put(NetworkController());

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.white, // status bar color
      statusBarIconBrightness: Brightness.dark, // icon color
      statusBarBrightness: Brightness.light, // iOS status bar brightness
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
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(1.0)),
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

# Write part directives inside splash screen files
cat <<EOF > "$BASE_DIR/views/splash/screens/splash_screen_mobile.dart"
part of 'splash_screen.dart';

// hello rakib vai
EOF

cat <<EOF > "$BASE_DIR/views/splash/screens/splash_screen.dart"
part 'splash_screen_mobile.dart';

// hello rakib vai 2
EOF

echo "🛠️📥 Creating Api Method..."
curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Structure-Auto/main/api_method.sh | bash

echo "📥 Running Dependencies installation script..."
curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Structure-Auto/main/get_dependencies.sh | bash

echo "📥 Writing Code In Your Stucture..."
curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Flutter-Automation/refs/heads/main/%3C%3E.sh | bash



echo "✅ Your Flutter project structure has been created successfully!"
