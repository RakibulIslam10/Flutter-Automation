#!/bin/bash

# 🔹 Debug SHA1
DEBUG_KEYSTORE="$HOME/.android/debug.keystore"
DEBUG_ALIAS="androiddebugkey"
DEBUG_STOREPASS="android"
DEBUG_KEYPASS="android"

echo "==============================="
echo "🔹 Debug SHA1:"
if [ -f "$DEBUG_KEYSTORE" ]; then
    keytool -list -v -alias $DEBUG_ALIAS -keystore $DEBUG_KEYSTORE -storepass $DEBUG_STOREPASS -keypass $DEBUG_KEYPASS | grep SHA1 | awk '{print $2}'
else
    echo "❌ Debug keystore not found at $DEBUG_KEYSTORE"
fi
echo "==============================="

# 🔹 Release SHA1
RELEASE_KEYSTORE="android/app/my-release-key.jks"
RELEASE_ALIAS="my-key-alias"

# Check if release keystore exists
if [ ! -f "$RELEASE_KEYSTORE" ]; then
    echo "🛠️ Release keystore not found! Creating a new one..."
    read -p "Enter keystore password: " STOREPASS
    read -p "Enter key password: " KEYPASS
    keytool -genkey -v -keystore $RELEASE_KEYSTORE -alias $RELEASE_ALIAS -keyalg RSA -keysize 2048 -validity 10000 -storepass $STOREPASS -keypass $KEYPASS
else
    read -p "Enter keystore password: " STOREPASS
    read -p "Enter key password: " KEYPASS
fi

echo "==============================="
echo "🔹 Release SHA1:"
keytool -list -v -alias $RELEASE_ALIAS -keystore $RELEASE_KEYSTORE -storepass $STOREPASS -keypass $KEYPASS | grep SHA1 | awk '{print $2}'
echo "==============================="
