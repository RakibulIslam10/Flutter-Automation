#!/bin/bash

PROJECT_NAME=$1
DESCRIPTION=$2

if [ -z "$PROJECT_NAME" ]; then
  echo "❌ Project name is required."
  exit 1
fi

if [ -z "$DESCRIPTION" ]; then
  DESCRIPTION="A new Flutter project."
fi

cat <<EOF > pubspec.yaml
name: $PROJECT_NAME
description: "$DESCRIPTION"
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: ^3.9.0

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  shimmer:
  url_launcher: ^6.3.1
  pin_code_fields:
  loading_animation_widget:
  http_parser: ^4.0.2
  mime: ^1.0.4
  flutter_screenutil: ^5.9.3
  flutter_animate:
  get:
  google_sign_in: ^6.3.0
  get_storage:
  connectivity_plus:
  flutter_svg:
  intl:
  cached_network_image:
  country_picker: ^2.0.27
  shadify: ^1.0.1


  http:

dev_dependencies:
  change_app_package_name: ^1.4.0
  rename_app: ^1.6.5
  
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner:
  flutter_gen_runner:
  
  # dart run build_runner build
  # dart run rename_app:main all="My App Name"
  # flutter pub run change_app_package_name:main net.appdevs.carbo

flutter:
  uses-material-design: true

  assets:
    - assets/icons/
    - assets/logo/
    - assets/dummy/
EOF

echo "✅ pubspec.yaml generated for project '$PROJECT_NAME'"
