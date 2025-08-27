#!/bin/bash

echo "=== Firebase Flutter Setup Automation ==="

# --- Function: check command existence ---
check_command() {
    if ! command -v $1 &> /dev/null; then
        return 1
    else
        return 0
    fi
}

# --- Node.js / npm install ---
if ! check_command node || ! check_command npm; then
    echo "Node.js/npm not found! Installing Node.js..."
    read -p "Press ENTER to continue installation..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# --- Firebase CLI install ---
if ! check_command firebase; then
    echo "Firebase CLI not found! Installing..."
    read -p "Press ENTER to install Firebase CLI via npm..."
    sudo npm install -g firebase-tools
fi

# --- FlutterFire CLI install ---
if ! check_command flutterfire; then
    echo "FlutterFire CLI not found! Installing..."
    read -p "Press ENTER to install FlutterFire CLI via dart..."
    dart pub global activate flutterfire_cli
fi

# --- Ensure flutterfire in PATH ---
export PATH="$PATH:$HOME/.pub-cache/bin"
echo "PATH updated to include FlutterFire CLI."

# --- User Inputs ---
read -p "Enter your Firebase project ID: " FIREBASE_PROJECT_ID
read -p "Enter your Android applicationId (leave empty if none): " ANDROID_APP_ID
read -p "Enter your iOS bundle ID (leave empty if none): " IOS_BUNDLE_ID

# --- Firebase login ---
echo "Please login to Firebase (browser will open)..."
firebase login

# --- Initialize Firebase project in current folder if needed ---
if [ ! -f "firebase.json" ]; then
    echo "Initializing Firebase project in this folder..."
    firebase init --project "$FIREBASE_PROJECT_ID" --force
fi

# --- Configure Android ---
if [ ! -z "$ANDROID_APP_ID" ]; then
    echo "Configuring Android..."
    flutterfire configure \
        --project "$FIREBASE_PROJECT_ID" \
        --android-package-name "$ANDROID_APP_ID" \
        --out lib/firebase_options.dart
fi

# --- Configure iOS ---
if [ ! -z "$IOS_BUNDLE_ID" ]; then
    echo "Configuring iOS..."
    flutterfire configure \
        --project "$FIREBASE_PROJECT_ID" \
        --ios-bundle-id "$IOS_BUNDLE_ID" \
        --out lib/firebase_options.dart
fi

echo "✅ Firebase setup completed successfully!"
echo "Import 'lib/firebase_options.dart' in your main.dart and initialize Firebase."
