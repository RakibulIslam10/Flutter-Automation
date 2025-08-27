#!/usr/bin/env bash

echo "📁 Creating YOUR CODE HELPERS..."

BASE_DIR="lib"

# Create helpers directory if not exists
mkdir -p "$BASE_DIR/core/helpers"

# HELPERS CODE WRITE
cat > "$BASE_DIR/core/helpers/helpers.dart" <<EOF
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import '../utils/basic_import.dart';

class Validators {
  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!GetUtils.isEmail(value)) return 'Enter a valid email';
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPasswordValidator(String? value, String? password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  static String? nameValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your name';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Only alphabetic characters and spaces are allowed';
    }
    return null;
  }

  static String? phoneNumberValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your phone number';
    if (!RegExp(r'^(?:\\+88|88)?01[1-9]\\d{8}\$').hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? dateOfBirthValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your date of birth';
    }
    try {
      DateFormat('yyyy-MM-dd').parseStrict(value);
    } catch (e) {
      return 'Please enter a valid date in the format yyyy-MM-dd';
    }
    return null;
  }

  static void launchDialer(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar("Error", "Could not open dialer");
    }
  }

  static Future<File> getProfileImageFile({
    required Rx<File?> pickedImage,
    required String? apiImageUrl,
    required RxBool isLoading,
    String defaultAssetPath = 'assets/logo/default_avatar.jpg',
    String cachedFileName = 'cached_profile.jpg',
    String defaultFileName = 'default_avatar.jpg',
  }) async {
    if (pickedImage.value != null) {
      return pickedImage.value!;
    }

    if (apiImageUrl != null && apiImageUrl.isNotEmpty) {
      try {
        isLoading.value = true;
        final response = await http.get(Uri.parse(apiImageUrl));
        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final cachedPath = '\${tempDir.path}/\$cachedFileName';
          final file = File(cachedPath);
          await file.writeAsBytes(response.bodyBytes);
          return file;
        }
      } catch (e) {
        // Optional: log or handle error
      } finally {
        isLoading.value = false;
      }
    }

    final byteData = await rootBundle.load(defaultAssetPath);
    final tempDir = await getTemporaryDirectory();
    final file = File('\${tempDir.path}/\$defaultFileName');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
  }
}
EOF

echo "✅ helpers.dart created"

# network_controller.dart
cat > "$BASE_DIR/core/helpers/network_controller.dart" <<EOF
*/import '../utils/basic_import.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  RxBool isConnected = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initConnectivityCheck();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _initConnectivityCheck() async {
    var result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final newStatus = result != ConnectivityResult.none;

    if (isConnected.value != newStatus) {
      isConnected.value = newStatus;

      if (!newStatus) {
        CustomSnackBar.error('❌ No Internet Connection');
      } else {
        CustomSnackBar.success(
          title: '✅ Internet Restored',
          message: "Your internet connection has been restored.",
        );
      }
    }
  }
}/*
EOF

echo "✅ network_controller.dart created"

echo "🚀 Code Writing successfully!"
