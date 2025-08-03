#!/usr/bin/env bash
set -e  # Error হলে স্ক্রিপ্ট থামবে

# 🌈 Terminal Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

BASE_DIR="lib"

echo -e "${CYAN}📁 Creating Your Custom Structure ...${NC}"

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

# Main entry files
touch "$BASE_DIR"/{main.dart,initial.dart}

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

# Write part directives inside splash screen files
echo -e "${YELLOW}📄 Writing splash screen parts...${NC}"
cat <<EOF > "$BASE_DIR/views/splash/screens/splash_screen_mobile.dart"
part of 'splash_screen.dart';

// hello rakib vai
EOF

cat <<EOF > "$BASE_DIR/views/splash/screens/splash_screen.dart"
part 'splash_screen_mobile.dart';

// hello rakib vai 2
EOF

# External scripts
echo -e "${CYAN}🛠️ Creating API Method...${NC}"
curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Structure-Auto/main/am.sh | bash

echo -e "${CYAN}📥 Installing Dependencies...${NC}"
curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Structure-Auto/main/py.sh | bash

echo -e "${CYAN}✏️ Writing Code In Your Structure...${NC}"
curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Flutter-Automation/main/cu.sh | bash
curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Flutter-Automation/main/ch.sh | bash

echo -e "${GREEN}✅ Your Flutter project structure was created successfully!${NC}"
