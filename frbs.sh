#!/bin/bash

# Firebase CLI এবং FlutterFire CLI check
if ! command -v firebase &> /dev/null
then
    echo "Firebase CLI not found! Please install it first: https://firebase.google.com/docs/cli"
    exit
fi

if ! command -v flutterfire &> /dev/null
then
    echo "FlutterFire CLI not found! Installing..."
    dart pub global activate flutterfire_cli
fi

echo "=== Firebase Flutter Setup Automation ==="

# User Input
read -p "Enter your Firebase project ID: " FIREBASE_PROJECT_ID
read -p "Enter your iOS bundle ID (leave empty if not iOS): " IOS_BUNDLE_ID
read -p "Enter your Android applicationId (leave empty if not Android): " ANDROID_APP_ID

# Firebase login
echo "Logging into Firebase..."
firebase login

# Add Firebase project
echo "Selecting Firebase project..."
firebase use "$FIREBASE_PROJECT_ID"

# Android setup
if [ ! -z "$ANDROID_APP_ID" ]; then
    echo "Setting up Android..."
    flutterfire configure --project "$FIREBASE_PROJECT_ID" --android-package "$ANDROID_APP_ID" --out lib/firebase_options.dart
fi

# iOS setup
if [ ! -z "$IOS_BUNDLE_ID" ]; then
    echo "Setting up iOS..."
    flutterfire configure --project "$FIREBASE_PROJECT_ID" --ios-bundle-id "$IOS_BUNDLE_ID" --out lib/firebase_options.dart
fi

echo "Firebase setup completed successfully!"
