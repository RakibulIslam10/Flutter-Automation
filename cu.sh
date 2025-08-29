#!/usr/bin/env bash

echo "📁 Creating YOUR CODE STRUCTURE..."

BASE_DIR="lib"

# Create necessary directories first
mkdir -p "$BASE_DIR/core/utils"

# basic_import.dart
cat > "$BASE_DIR/core/utils/basic_import.dart" <<EOF
export 'package:flutter/material.dart';
export 'custom_style.dart';
export 'dimensions.dart';
export 'package:get/get.dart';
export 'layout.dart';
export 'dart:convert';
export 'package:flutter_svg/svg.dart';
export 'package:flutter/services.dart';
export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:get_storage/get_storage.dart';


// add those widgets
// export '../themes/token.dart';
// export '../languages/strings.dart';
// export 'package:starting/routes/routes.dart';
// export 'package:starting/widgets/text_widget.dart';
// export 'package:starting/core/utils/space.dart';
// export 'package:starting/widgets/custom_snackbar.dart';


EOF

echo "✅ basic_import.dart created"

# dimensions.dart
cat > "$BASE_DIR/core/utils/dimensions.dart" <<EOF
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

# app_storage.dart
cat > "$BASE_DIR/core/utils/app_storage.dart" <<EOF
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

# app_storage_model.dart
cat > "$BASE_DIR/core/utils/app_storage_model.dart" <<EOF
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

# space.dart
cat > "$BASE_DIR/core/utils/space.dart" <<EOF
import 'package:flutter/material.dart';
import 'dimensions.dart';

class Space {
  static SizeHeightModel height = SizeHeightModel(
    btnInputTitleAndBox:
        SizedBox(height: Dimensions.spaceBetweenInputTitleAndBox),
    betweenInputBox: SizedBox(height: Dimensions.spaceBetweenInputBox),
    v5: SizedBox(height: Dimensions.heightSize * 0.5),
    v10: SizedBox(height: Dimensions.heightSize),
    v15: SizedBox(height: Dimensions.heightSize * 1.5),
    v20: SizedBox(height: Dimensions.heightSize * 2),
    v25: SizedBox(height: Dimensions.heightSize * 2.5),
    v30: SizedBox(height: Dimensions.heightSize * 3),
    v40: SizedBox(height: Dimensions.heightSize * 4),
  );

  static SizeWidthModel width = SizeWidthModel(
    v5: SizedBox(width: Dimensions.widthSize * 0.5),
    v10: SizedBox(width: Dimensions.widthSize),
    v15: SizedBox(width: Dimensions.widthSize * 1.5),
    v20: SizedBox(width: Dimensions.widthSize * 2),
    v25: SizedBox(width: Dimensions.widthSize * 2.5),
    v30: SizedBox(width: Dimensions.widthSize * 3),
    v40: SizedBox(width: Dimensions.widthSize * 4),
  );
}

class SizeHeightModel {
  final SizedBox btnInputTitleAndBox;
  final SizedBox betweenInputBox;
  final SizedBox v5;
  final SizedBox v10;
  final SizedBox v15;
  final SizedBox v20;
  final SizedBox v25;
  final SizedBox v30;
  final SizedBox v40;

  SizedBox add(double value) => SizedBox(height: value);

  SizeHeightModel({
    required this.btnInputTitleAndBox,
    required this.betweenInputBox,
    required this.v5,
    required this.v10,
    required this.v15,
    required this.v20,
    required this.v25,
    required this.v30,
    required this.v40,
  });
}

class SizeWidthModel {
  final SizedBox v5;
  final SizedBox v10;
  final SizedBox v15;
  final SizedBox v20;
  final SizedBox v25;
  final SizedBox v30;
  final SizedBox v40;

  SizedBox add(double value) => SizedBox(width: value);

  SizeWidthModel({
    required this.v5,
    required this.v10,
    required this.v15,
    required this.v20,
    required this.v25,
    required this.v30,
    required this.v40,
  });
}

MainAxisAlignment mainStart = MainAxisAlignment.start;
MainAxisAlignment mainCenter = MainAxisAlignment.center;
MainAxisAlignment mainEnd = MainAxisAlignment.end;
MainAxisAlignment mainSpaceBet = MainAxisAlignment.spaceBetween;
MainAxisSize mainMax = MainAxisSize.max;
MainAxisSize mainMin = MainAxisSize.min;
CrossAxisAlignment crossStart = CrossAxisAlignment.start;
CrossAxisAlignment crossCenter = CrossAxisAlignment.center;
CrossAxisAlignment crossEnd = CrossAxisAlignment.end;
CrossAxisAlignment crossStretch = CrossAxisAlignment.stretch;

// Floating Action Button Location
FloatingActionButtonLocation centerDocked =
    FloatingActionButtonLocation.centerDocked;
FloatingActionButtonLocation centerFloat =
    FloatingActionButtonLocation.centerFloat;
EOF

echo "✅ space.dart created"

# layout.dart
cat > "$BASE_DIR/core/utils/layout.dart" <<EOF
import 'package:flutter/material.dart';
import 'dimensions.dart';

class Layout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const Layout({super.key, required this.mobile, this.tablet, this.desktop});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < Dimensions.mobileScreenWidth) {
          return mobile;
        } else if (constraints.maxWidth < Dimensions.tabletScreenWidth) {
          // return tablet ?? mobile; =>>  use this for tablet
          return mobile;
        } else {
          return desktop ?? mobile;
        }
      },
    );
  }
}
EOF

echo "✅ layout.dart created"

# extensions.dart
cat > "$BASE_DIR/core/utils/extensions.dart" <<EOF
import 'package:flutter/material.dart';
import 'package:get/get.dart';

extension SupperEdgeInsets on num {
  /// EdgeInsets
  EdgeInsets get edgeHorizontal => EdgeInsets.symmetric(horizontal: toDouble());
  EdgeInsets get edgeVertical => EdgeInsets.symmetric(vertical: toDouble());
  EdgeInsets get edgeTop => EdgeInsets.only(top: toDouble());
  EdgeInsets get edgeBottom => EdgeInsets.only(bottom: toDouble());
  EdgeInsets get edgeLeft => EdgeInsets.only(left: toDouble());
  EdgeInsets get edgeRight => EdgeInsets.only(right: toDouble());

  /// BorderRadius
  BorderRadius get radiusEx => BorderRadius.circular(toDouble());
  BorderRadius get radiusTopEx => BorderRadius.only(
    topLeft: Radius.circular(toDouble()),
    topRight: Radius.circular(toDouble()),
  );
}
EOF

echo "✅ extensions.dart created"

# custom_style.dart
cat > "$BASE_DIR/core/utils/custom_style.dart" <<EOF
import 'package:flutter/material.dart';
import 'dimensions.dart';

class CustomStyle {
  static TextStyle displayLarge = TextStyle(fontSize: Dimensions.displayLarge);
  static TextStyle displayMedium =
      TextStyle(fontSize: Dimensions.displayMedium);
  static TextStyle displaySmall = TextStyle(fontSize: Dimensions.displaySmall);
  static TextStyle headlineLarge =
      TextStyle(fontSize: Dimensions.headlineLarge);
  static TextStyle headlineMedium =
      TextStyle(fontSize: Dimensions.headlineMedium);
  static TextStyle headlineSmall =
      TextStyle(fontSize: Dimensions.headlineSmall);
  static TextStyle titleLarge = TextStyle(fontSize: Dimensions.titleLarge);
  static TextStyle titleMedium = TextStyle(fontSize: Dimensions.titleMedium);
  static TextStyle titleSmall = TextStyle(fontSize: Dimensions.titleSmall);
  static TextStyle bodyLarge = TextStyle(fontSize: Dimensions.bodyLarge);
  static TextStyle bodyMedium = TextStyle(fontSize: Dimensions.bodyMedium);
  static TextStyle bodySmall = TextStyle(fontSize: Dimensions.bodySmall);
  static TextStyle labelLarge = TextStyle(fontSize: Dimensions.labelLarge);
  static TextStyle labelMedium = TextStyle(fontSize: Dimensions.labelMedium);
  static TextStyle labelSmall = TextStyle(fontSize: Dimensions.labelSmall);
}
EOF

echo "✅ custom_style.dart created"

echo "🚀 All files and structure created successfully!"
