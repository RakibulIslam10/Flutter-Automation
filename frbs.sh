#!/usr/bin/env bash

echo "🚀 Starting Firebase Setup..."

# Platforms selection
echo "Select platforms to configure:"
echo "1) Android"
echo "2) iOS"
echo "3) Both"

read -p "Enter your choice: " platform_choice

case $platform_choice in
    1)
        flutterfire configure --project YOUR_PROJECT_ID --android
        ;;
    2)
        flutterfire configure --project YOUR_PROJECT_ID --ios
        ;;
    3)
        flutterfire configure --project YOUR_PROJECT_ID --android --ios
        ;;
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

echo "✅ Firebase Setup Completed!"
