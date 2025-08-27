#!/bin/bash

echo "=== Firebase Flutter Setup Automation ==="

# --- Check Node.js & npm ---
if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
    echo "Node.js/npm not found! Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# --- Check Firebase CLI ---
if ! command -v firebase &> /dev/null; then
    echo "Installing Firebase CLI..."
    sudo npm install -g firebase-tools
fi

# --- Check FlutterFire CLI ---
if ! command -v flutterfire &> /dev/null; then
    echo "Installing FlutterFire CLI..."
    dart pub global activate flutterfire_cli
fi

# --- Ensure flutterfire command is in PATH ---
export PATH="$PATH:$HOME/.pub-cache/bin"

# --- User Input ---
read -p "Enter your Firebase project ID: " FIREBASE_PROJECT_ID
read -p "Enter your iOS bundle ID (leave empty if not iOS): " IOS_BUNDLE_ID
read -p "Enter your Android applicationId (leave empty if not Android): " ANDROID_APP_ID

# --- Firebase login ---
echo "Logging into Firebase..."
firebase login

# --- Select Firebase project ---
echo "Selecting Firebase project..."
firebase use "$FIREBASE_PROJECT_ID"

# --- Configure Android ---
if [ ! -z "$ANDROID_APP_ID" ]; then
    echo "Setting up Android..."
    flutterfire configure --project "$FIREBASE_PROJECT_ID" --android-package "$ANDROID_APP_ID" --out lib/firebase_options.dart
fi

# --- Configure iOS ---
if [ ! -z "$IOS_BUNDLE_ID" ]; then
    echo "Setting up iOS..."
    flutterfire configure --project "$FIREBASE_PROJECT_ID" --ios-bundle-id "$IOS_BUNDLE_ID" --out lib/firebase_options.dart
fi

echo "✅ Firebase setup completed successfully!"
