#!/usr/bin/env bash

echo "📦 Checking and adding missing dependencies to pubspec.yaml..."

# Step 1: Check if pubspec.yaml exists
if [[ ! -f "pubspec.yaml" ]]; then
    echo "❌ pubspec.yaml not found in current directory!"
    exit 1
fi

# Step 2: Define dependencies to inject
declare -A dependencies=(
  ["get"]=""
  ["http"]=""
  ["flutter_screenutil"]="^5.9.3"
  ["get_storage"]=""
  ["flutter_svg"]=""
  ["loading_animation_widget"]=""
  ["pin_code_fields"]=""
  ["flutter_animate"]=""
  ["intl"]=""
  ["cached_network_image"]=""
  ["google_sign_in"]="^6.3.0"
  ["connectivity_plus"]=""
  ["flutter_lints"]=""
  ["mime"]="^1.0.4"
  ["http_parser"]="^4.0.2"
  ["url_launcher"]="^6.3.1"
  ["shimmer"]=""
  
)

# Step 3: Parse existing pubspec.yaml to avoid duplicates
existing=$(grep -Po '^\s{2,}(\w+):' pubspec.yaml | sed 's/ //g' | sed 's/://g')

insertion=""
for dep in "${!dependencies[@]}"; do
  if echo "$existing" | grep -q "^$dep$"; then
    echo "⚠️  $dep already exists, skipping..."
  else
    version=${dependencies[$dep]}
    if [[ -n "$version" ]]; then
      insertion+="  $dep: $version\n"
    else
      insertion+="  $dep:\n"
    fi
  fi
done

if [[ -z "$insertion" ]]; then
  echo "✅  All dependencies already present. Nothing to add."
  exit 0
fi

# Add vertical spacing before and after insertion
insertion="\n$insertion\n"

# Step 4: Inject new dependencies *after* cupertino_icons (handle leading spaces)
awk -v insert="$insertion" '
  BEGIN { done = 0 }
  {
    print
    if ($0 ~ /^[[:space:]]+cupertino_icons:/ && done == 0) {
      printf "%s", insert
      done = 1
    }
  }
' pubspec.yaml > pubspec_temp.yaml && mv pubspec_temp.yaml pubspec.yaml

# Step 5: Run pub get
flutter pub get

echo "✅  All dependencies added successfully!"
