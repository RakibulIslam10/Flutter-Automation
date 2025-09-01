#!/bin/bash
KEYSTORE="android/app/my-release-key.jks"
ALIAS="my-key-alias"
STOREPASS="your_keystore_password"
KEYPASS="your_key_password"

keytool -list -v -keystore $KEYSTORE -alias $ALIAS -storepass $STOREPASS -keypass $KEYPASS | grep SHA1 | awk '{print $2}'
