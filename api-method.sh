#!/usr/bin/env bash

echo "📁 Creating Custom API Method..."

BASE_DIR="lib"
mkdir -p "$BASE_DIR/core/api/services"
touch "$BASE_DIR/core/api/services/api_request.dart"

echo "✅ Folder created. Writing Dart code..."

cat <<"EOF" > "$BASE_DIR/core/api/services/api_request.dart"
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:starting/core/api/end_point/api_end_points.dart';
import '../../helpers/network_controller.dart';
import '../../utils/app_storage.dart';
import '../../utils/basic_import.dart';

enum HttpMethod { get, post, put, patch, delete }

class ApiRequest {
  static Future<R> request<R>({
    required HttpMethod method,
    required R Function(Map<String, dynamic>) fromJson,
    required String endPoint,
    required RxBool isLoading,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool showSuccessSnackBar = false,
    Function(R result)? onSuccess,
  }) async {
    try {
      isLoading.value = true;
      _checkInternetConnection();
      final headers = await _bearerHeaderInfo();
      const timeoutDuration = Duration(seconds: 120);

      log(
        '|📤|---------[ 🌐 REQUEST STARTED - ${method.name.toUpperCase()} ]---------|📤|',
      );

      Uri uri = Uri.parse('${ApiEndPoints.baseUrl}$endPoint');

      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
        log('🔗 With Params: ${uri.toString()}');
      }

      if (body != null) printBodyLineByLine(body);

      late http.Response response;

      switch (method) {
        case HttpMethod.get:
          response = await http
              .get(uri, headers: headers)
              .timeout(timeoutDuration);
          break;
        case HttpMethod.post:
          response = await http
              .post(uri, headers: headers, body: jsonEncode(body))
              .timeout(timeoutDuration);
          break;
        case HttpMethod.put:
          response = await http
              .put(uri, headers: headers, body: jsonEncode(body))
              .timeout(timeoutDuration);
          break;
        case HttpMethod.patch:
          response = await http
              .patch(uri, headers: headers, body: jsonEncode(body))
              .timeout(timeoutDuration);
          break;
        case HttpMethod.delete:
          response = await http
              .delete(uri, headers: headers, body: jsonEncode(body))
              .timeout(timeoutDuration);
          break;
      }

      log('|✅|---------[ ✅ REQUEST COMPLETED ]---------|✅|');
      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final result = fromJson(json);

        final successMessage =
            json['message'] ?? Strings.requestCompletedSuccessfully;
        if (showSuccessSnackBar) {
          CustomSnackBar.success(
            title: Strings.success,
            message: successMessage,
          );
        }
        if (onSuccess != null) onSuccess(result);
        return result;
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Something went wrong!';
        log('❌ Error: $errorMessage');
        CustomSnackBar.error(errorMessage);
        throw errorMessage;
      }
    } catch (e) {
      isLoading.value = false;
      log('🐞🐞🐞 UNHANDLED ERROR: ${e.toString()}');
      throw e.toString();
    }
  }

  /// =========================================================== ✅ POST Request =========================================================== ///
  static Future<R> post<R>({
    required R Function(Map<String, dynamic>) fromJson,
    required String endPoint,
    required RxBool isLoading,
    required Map<String, dynamic> body,
    bool showSuccessSnackBar = false,
    Function(R result)? onSuccess,
  }) async {
    try {
      isLoading.value = true;
      _checkInternetConnection();
      final headers = await _bearerHeaderInfo();
      log('|📤|---------[ 📦 POST REQUEST STARTED ]---------|📤|');

      printEndPointLog(endPoint);
      printBodyLineByLine(body);

      final response = await http
          .post(
            Uri.parse('${ApiEndPoints.baseUrl}$endPoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 120));

      log('|✅|---------[ ✅ POST REQUEST COMPLETED ]---------|✅|');

      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final result = fromJson(json);
        final successMessage =
            json['message'] ?? Strings.requestCompletedSuccessfully;
        if (showSuccessSnackBar)
          CustomSnackBar.success(
            title: Strings.success,
            message: successMessage,
          );
        if (onSuccess != null) onSuccess(result);
        return result;
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Something went wrong!';
        log('❌ Error: $errorMessage');
        CustomSnackBar.error(errorMessage);
        throw errorMessage;
      }
    } catch (e) {
      isLoading.value = false;
      log('🐞🐞🐞 UNHANDLED ERROR: ${e.toString()}');
      throw e.toString();
    }
  }

  /// =========================================================== ✅ GET Request =========================================================== ///
  static Future<T> get<T>({
    required String endPoint,
    required RxBool isLoading,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, String>? queryParams,
    bool showSuccessSnackBar = false,
    Function(T result)? onSuccess,
  }) async {
    try {
      isLoading.value = true;
      _checkInternetConnection();

      final headers = await _bearerHeaderInfo();

      log('|🚀🚀🚀|---------[📦📦📦 GET REQUEST STARTED ]---------|🚀🚀🚀|');

      Uri uri = Uri.parse('${ApiEndPoints.baseUrl}$endPoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
        printEndPointLog(uri.toString());
      }

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 120));

      log('|✅|---------[ ✅ GET REQUEST COMPLETED ]---------|✅|');

      isLoading.value = false;

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        final result = fromJson(json);
        final successMessage =
            json['message'] ?? Strings.requestCompletedSuccessfully;
        if (showSuccessSnackBar)
          CustomSnackBar.success(
            title: Strings.success,
            message: successMessage,
          );

        if (onSuccess != null) onSuccess(result);
        return result;
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Something went wrong!';
        log('❌ Error: $errorMessage');
        CustomSnackBar.error(errorMessage);
        throw errorMessage;
      }
    } catch (e) {
      isLoading.value = false;
      log('🐞🐞🐞 UNHANDLED ERROR: ${e.toString()}');
      throw e.toString();
    }
  }

  /// ======================================================== ✅ Multipart POST Method ========================================================= ///
  static Future<R> multiMultipartRequest<R>({
    required String endPoint,
    required RxBool isLoading,
    required String method,
    required Map<String, String> body,
    required Map<String, File> files,
    required R Function(Map<String, dynamic>) fromJson,
    bool showSuccessSnackBar = false,
    Function(R result)? onSuccess,
  }) async {
    try {
      isLoading.value = true;

      await _checkInternetConnection();

      final headers = await _bearerHeaderInfo();
      final uri = Uri.parse('${ApiEndPoints.baseUrl}$endPoint');

      // 🟡 Debugging Info
      log('📤 MULTIPART REQUEST STARTED');
      log('🔗 Method     : $method');
      log('🔗 URL        : $uri');
      log('📦 Body       : $body');
      log('🖼️ Files      : ${files.map((k, v) => MapEntry(k, v.path))}');
      log('📑 Headers    : $headers');

      final request = http.MultipartRequest(method, uri);
      request.headers.addAll(headers);

      request.fields.addAll(body);

      for (var entry in files.entries) {
        final file = entry.value;
        final mimeType =
            lookupMimeType(file.path) ?? 'application/octet-stream';

        log('🧪 MIME TYPE for ${entry.key}: $mimeType');

        request.files.add(
          await http.MultipartFile.fromPath(
            entry.key,
            file.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 120),
      );
      final response = await http.Response.fromStream(streamedResponse);

      isLoading.value = false;

      log('📬 RESPONSE STATUS: ${response.statusCode}');
      log('📬 RESPONSE BODY  : ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final result = fromJson(json);

        if (showSuccessSnackBar) {
          final successMessage =
              json['message'] ?? Strings.requestCompletedSuccessfully;
          CustomSnackBar.success(
            title: Strings.success,
            message: successMessage,
          );
        }

        if (onSuccess != null) onSuccess(result);
        return result;
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Something went wrong!';
        log('❌ Error: $errorMessage');
        CustomSnackBar.error(errorMessage);
        throw errorMessage;
      }
    } catch (e) {
      isLoading.value = false;
      log('🐞 UNHANDLED ERROR: ${e.toString()}');
      throw e.toString();
    }
  }

  /// Handle update profile process
  // Future<UpdateProfileModel?> updateProfile() async {
  //   isLoading.value = true;
  //
  //   final imageUrl = profileController.myProfileInfo.value?.data.profileImg;
  //   final profileImage = await Helpers.getProfileImageFile(
  //     pickedImage: selectedProfileImg,
  //     apiImageUrl: imageUrl,
  //     isLoading: isLoading,
  //   );
  //
  //   final result = await ApiRequest.multiMultipartRequest(
  //     endPoint: ApiEndPoints.updateProfile,
  //     reqType: 'PATCH',
  //     isLoading: isLoading,
  //     body: {
  //       'firstName': firstNameController.text.trim(),
  //       'lastName': lastNameController.text.trim(),
  //       'email': emailController.text.trim(),
  //       'dateOfBirth': selectedDate.value,
  //     },
  //     files: {'profile_image': profileImage},
  //     fromJson: UpdateProfileModel.fromJson,
  //     showSuccessSnackBar: true,
  //     onSuccess: (_) => Get.offAllNamed(Routes.navigationScreen),
  //   );
  //
  //   isLoading.value = false;
  //
  //   return result;
  // }

  /// ✅=======================================================================================================================

  /// ✅ Header Generator
  static Future<Map<String, String>> _bearerHeaderInfo() async {
    final token = AppStorage.token;
    return {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.contentTypeHeader: "application/json",
      if (token.isNotEmpty) HttpHeaders.authorizationHeader: "Bearer $token",
    };
  }

  /// ✅ Check Internet Connection
  static Future<bool> _checkInternetConnection() async {
    final networkController = Get.find<NetworkController>();
    if (!networkController.isConnected.value) {
      // ✅ Show popup dialog
      // Get.toNamed(noInterNetPageDesign)
      Get.defaultDialog(
        title: "ইন্টারনেট নাই",
        middleText: "দয়া করে আপনার ইন্টারনেট কানেকশন চেক করুন।",
        textConfirm: "ঠিক আছে",
        onConfirm: () => Get.back(),
      );
      return false;
    }
    return true;
  }

  static void printBodyLineByLine(Map<String, dynamic> body) {
    body.forEach((key, value) {
      log("🔹 '$key': '$value'");
    });
  }

  static void printEndPointLog(String endPoint) {
    log("📍 'End Point': '${ApiEndPoints.baseUrl}$endPoint'");
  }
}
EOF

echo "✅ Dart file written to: $BASE_DIR/core/api/services/api_request.dart"
