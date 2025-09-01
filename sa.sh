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
# Update these variables with your release keystore info
RELEASE_KEYSTORE="android/app/my-release-key.jks"
RELEASE_ALIAS="my-key-alias"
RELEASE_STOREPASS="your_keystore_password"
RELEASE_KEYPASS="your_key_password"

echo "🔹 Release SHA1:"
if [ -f "$RELEASE_KEYSTORE" ]; then
    keytool -list -v -alias $RELEASE_ALIAS -keystore $RELEASE_KEYSTORE -storepass $RELEASE_STOREPASS -keypass $RELEASE_KEYPASS | grep SHA1 | awk '{print $2}'
else
    echo "❌ Release keystore not found at $RELEASE_KEYSTORE"
fi
echo "==============================="
