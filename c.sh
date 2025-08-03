#!/usr/bin/env bash

echo "📁 Creating YOUR CODE STRUCTURE..."

BASE_DIR="lib"

# Create necessary folders
mkdir -p "$BASE_DIR/core/api/services"
mkdir -p "$BASE_DIR/core/core/utils"

# Write api_request.dart file
cat > "$BASE_DIR/core/api/services/api_request.dart" <<EOF
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiRequest {
  static Future<Map<String, dynamic>> get(String url) async {
    final response = await http.get(Uri.parse(url));
    return json.decode(response.body);
  }
}
EOF

echo "✅ api_request.dart created"

# Write basic_import.dart file
cat > "$BASE_DIR/core/core/utils/basic_import.dart" <<EOF
export 'package:flutter/material.dart';
export 'custom_style.dart';
export 'dimensions.dart';
export 'package:get/get.dart';
export 'layout.dart';
export '../themes/token.dart';
export '../languages/strings.dart';
export 'package:flutter/services.dart';
export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:starting/initial.dart';
export 'package:starting/routes/routes.dart';
export 'package:starting/views/splash/controller/splash_controller.dart';
export 'dart:convert';
export 'package:starting/widgets/text_widget.dart';
export 'package:starting/core/utils/space.dart';
export 'package:flutter_svg/svg.dart';
export 'package:starting/widgets/custom_snackbar.dart';
EOF

echo "✅ basic_import.dart created"

# Write dimensions.dart file
cat > "$BASE_DIR/core/core/utils/dimensions.dart" <<EOF
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Dimensions {
  static double mobileScreenWidth = 575;
  static double tabletScreenWidth = 1100;

  static double paddingSize = 24.00.h;
  static double verticalSize = 24.00.h;
  static double horizontalSize = 24.00.w;
  static double defaultHorizontalSize = 16.00.w;

  static double buttonHeight = 56.00.h;
  static double inputBoxHeight = 56.00.h;
  static double appBarHeight = 38.h;

  static double iconSizeSmall = 8.00.h;
  static double iconSizeDefault = 16.00.h;
  static double iconSizeLarge = 24.00.h;

  static double radius = 10.00.r;

  static double heightSize = 10.00.h;
  static double widthSize = 10.00.w;
  static double spaceBetweenInputTitleAndBox = 8.h;
  static double spaceBetweenInputBox = 16.h;
  static double spaceSizeBetweenColumn = 16.00.w;

  static double displayLarge = 57.0.sp;
  static double displayMedium = 45.0.sp;
  static double displaySmall = 36.0.sp;

  static double headlineLarge = 32.0.sp;
  static double headlineMedium = 28.0.sp;
  static double headlineSmall = 24.0.sp;

  static double titleLarge = 22.0.sp;
  static double titleMedium = 16.0.sp;
  static double titleSmall = 14.0.sp;

  static double bodyLarge = 16.0.sp;
  static double bodyMedium = 14.0.sp;
  static double bodySmall = 12.0.sp;

  static double labelLarge = 14.0.sp;
  static double labelMedium = 12.0.sp;
  static double labelSmall = 11.0.sp;
}
EOF

echo "✅ dimensions.dart created"

# Write app_storage.dart file
cat > "$BASE_DIR/core/core/utils/app_storage.dart" <<EOF
import 'package:get_storage/get_storage.dart';
import 'app_storage_model.dart';

class AppStorage {
  static final GetStorage _storage = GetStorage();

  static const String tokenKey = 'token';
  static const String temporaryTokenKey = 'temporaryToken';
  static const String mobileCodeKey = 'mobileCode';
  static const String onboardSaveKey = 'onboardSave';
  static const String waitTimeKey = 'waitTime';
  static const String isLoggedInKey = 'isLoggedIn';
  static const String isEmailVerifiedKey = 'isEmailVerified';
  static const String isKycVerifiedKey = 'isKycVerified';
  static const String isSmsVerifiedKey = 'isSmsVerified';
  static const String kycStatusKey = 'isKycStatus';

  static Future<void> save({
    String? token,
    String? temporaryToken,
    String? mobileCode,
    bool? onboardSave,
    String? waitTime,
    bool? isLoggedIn,
    bool? isEmailVerified,
    bool? isKycVerified,
    bool? isSmsVerified,
    bool? isKycStatus,
  }) async {
    if (token != null) await _storage.write(tokenKey, token);
    if (temporaryToken != null) await _storage.write(temporaryTokenKey, temporaryToken);
    if (mobileCode != null) await _storage.write(mobileCodeKey, mobileCode);
    if (onboardSave != null) await _storage.write(onboardSaveKey, onboardSave);
    if (waitTime != null) await _storage.write(waitTimeKey, waitTime);
    if (isLoggedIn != null) await _storage.write(isLoggedInKey, isLoggedIn);
    if (isEmailVerified != null) await _storage.write(isEmailVerifiedKey, isEmailVerified);
    if (isKycVerified != null) await _storage.write(isKycVerifiedKey, isKycVerified);
    if (isSmsVerified != null) await _storage.write(isSmsVerifiedKey, isSmsVerified);
    if (isKycStatus != null) await _storage.write(kycStatusKey, isKycStatus);
  }

  static String get token => _storage.read(tokenKey) ?? '';
  static String get temporaryToken => _storage.read(temporaryTokenKey) ?? '';
  static String get mobileCode => _storage.read(mobileCodeKey) ?? '';
  static String get waitTime => _storage.read(waitTimeKey) ?? '01:00';
  static bool get isLoggedIn => _storage.read(isLoggedInKey) ?? false;
  static bool get onboardSave => _storage.read(onboardSaveKey) ?? false;
  static bool get isKycVerified => _storage.read(isKycVerifiedKey) ?? false;
  static bool get isEmailVerified => _storage.read(isEmailVerifiedKey) ?? false;
  static bool get isSmsVerified => _storage.read(isSmsVerifiedKey) ?? false;
  static bool get isKycStatus => _storage.read(kycStatusKey) ?? false;

  static AppStorageModel get common {
    return AppStorageModel(
      _storage.read(tokenKey) ?? '',
      _storage.read(onboardSaveKey) ?? false,
      _storage.read(waitTimeKey) ?? '01:00',
      _storage.read(isLoggedInKey) ?? false,
      _storage.read(isEmailVerifiedKey) ?? false,
      _storage.read(isKycVerifiedKey) ?? false,
      _storage.read(isSmsVerifiedKey) ?? false,
      _storage.read(kycStatusKey) ?? 0,
      temporaryToken: _storage.read(temporaryTokenKey) ?? '',
      mobileCode: _storage.read(mobileCodeKey) ?? '',
    );
  }
}
EOF

echo "✅ app_storage.dart created"

# Write app_storage_model.dart file
cat > "$BASE_DIR/core/core/utils/app_storage_model.dart" <<EOF
class AppStorageModel {
  final String token;
  final String temporaryToken;
  final String mobileCode;
  final bool onboardSave;
  final String waitTime;
  final bool isLoggedIn;
  final bool isEmailVerified;
  final bool isKycVerified;
  final bool isSmsVerified;
  final int kycStatus;

  AppStorageModel(
    this.token,
    this.onboardSave,
    this.waitTime,
    this.isLoggedIn,
    this.isEmailVerified,
    this.isKycVerified,
    this.isSmsVerified,
    this.kycStatus, {
    required this.temporaryToken,
    required this.mobileCode,
  });
}
EOF

echo "✅ app_storage_model.dart created"

echo "🚀 All files and structure created successfully!"
