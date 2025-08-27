#!/usr/bin/env bash

# --------------------------
# Flutter Firebase Setup CLI
# --------------------------

echo "🚀 Starting Firebase Setup..."

# Project name prompt
read -p "📌 Enter your Firebase Project ID: " FIREBASE_PROJECT_ID

# Platforms selection
echo "Select platforms to configure:"
echo "1) Android"
echo "2) iOS"
echo "3) Both"
read -p "Enter 1, 2 or 3: " PLATFORM

# FlutterFire configure command
case $PLATFORM in
  1)
    flutterfire configure --project $FIREBASE_PROJECT_ID --android
    ;;
  2)
    flutterfire configure --project $FIREBASE_PROJECT_ID --ios
    ;;
  3)
    flutterfire configure --project $FIREBASE_PROJECT_ID --android --ios
    ;;
  *)
    echo "❌ Invalid option"
    exit 1
    ;;
esac

echo "✅ Firebase Setup Completed!"
