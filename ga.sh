#!/bin/bash
# google_auth.sh
# Automation for Google Auth setup in Flutter using Firebase CLI

# Exit on error
set -e

# Get arguments from launcher
PROJECT_ID="$1"
ANDROID_PACKAGE="$2"
IOS_BUNDLE="$3"
SHA1="$4"

# Check Firebase CLI
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Install it first: https://firebase.google.com/docs/cli"
    exit 1
fi

# Select or create project
echo "🔹 Selecting or creating Firebase project: $PROJECT_ID"
firebase use "$PROJECT_ID" || firebase projects:create "$PROJECT_ID" --display-name "$PROJECT_ID"

# Android app
echo "🔹 Creating Android app: $ANDROID_PACKAGE"
firebase apps:create android "$ANDROID_PACKAGE" --project "$PROJECT_ID" || true

# Add SHA1 if provided
if [ -n "$SHA1" ]; then
    firebase apps:sdkconfig android "$ANDROID_PACKAGE" --project "$PROJECT_ID" --sha1="$SHA1" > android_config.json
else
    firebase apps:sdkconfig android "$ANDROID_PACKAGE" --project "$PROJECT_ID" > android_config.json
fi

# Move google-services.json
mkdir -p android/app
mv android_config.json android/app/google-services.json
echo "✅ Android google-services.json downloaded to android/app/"

# iOS app (if provided)
if [ -n "$IOS_BUNDLE" ]; then
    echo "🔹 Creating iOS app: $IOS_BUNDLE"
    firebase apps:create ios "$IOS_BUNDLE" --project "$PROJECT_ID" || true
    firebase apps:sdkconfig ios "$IOS_BUNDLE" --project "$PROJECT_ID" > ios_config.plist
    mkdir -p ios/Runner
    mv ios_config.plist ios/Runner/GoogleService-Info.plist
    echo "✅ iOS GoogleService-Info.plist downloaded to ios/Runner/"
fi

echo "🎉 Google Auth setup completed!"
echo "Run 'flutter pub get' and rebuild your app."
