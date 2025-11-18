#!/usr/bin/env bash
set -euo pipefail

echo "📁 Creating YOUR CODE API METHOD..."

BASE_DIR="lib/core/api/services"

# ✅ Ensure the directory exists
mkdir -p "$BASE_DIR"

# ✅ Write the ApiRequest class
cat > "$BASE_DIR/api_request.dart" <<'EOF'
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../utils/app_storage.dart';
import '../../utils/basic_import.dart';
import '../end_point/api_end_points.dart';

class ApiRequest {
  /// Header generator
  static Future<Map<String, String>> _bearerHeaderInfo([String? token]) async {
    final authToken = token ?? AppStorage.token;
    return {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.contentTypeHeader: "application/json",
      if (authToken.isNotEmpty)
        HttpHeaders.authorizationHeader: "Bearer $authToken",
    };
  }

  static void printBody(Map<String, dynamic> body) {
    body.forEach((key, value) {
      log("🔹 '$key': '$value'");
    });
    log('╚════════════════════════════════════════════════════════════════════════════════════════════');
  }

  static void printUrl(String url) {
    log('╔════════════════════════════════════════════════════════════════════════════════════════════');
    log("📍 'End Point': '$url'");
  }

  /// POST REQUEST
  static Future<R> post<R>({
    required R Function(Map<String, dynamic>) fromJson,
    required String endPoint,
    required RxBool isLoading,
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParams,
    bool showSuccessSnackBar = false,
    Function(R result)? onSuccess,
  }) async {
    try {
      isLoading.value = true;
      log('|📤|---------[ 📦 POST REQUEST STARTED ]---------|📤|');

      final uri = Uri.parse('${ApiEndPoints.baseUrl}$endPoint')
          .replace(queryParameters: queryParams);
      printUrl(uri.toString());
      printBody(body);

      final response = await http
          .post(uri, headers: await _bearerHeaderInfo(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 120));

      log('|✅|---------[ ✅ POST REQUEST COMPLETED ]---------|✅|');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final result = fromJson(json);
        if (showSuccessSnackBar) {
          final successMessage = json['message'] ?? Strings.requestCompletedSuccessfully;
          CustomSnackBar.success(title: Strings.success, message: successMessage);
        }
        if (onSuccess != null) onSuccess(result);
        return result;
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Something went wrong!';
        log('❌ Error: $errorMessage');
        CustomSnackBar.error(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('🐞 ERROR: ${e.toString()}');
      throw Exception(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// GET REQUEST
  static Future<R> get<R>({
    required R Function(Map<String, dynamic>) fromJson,
    required String endPoint,
    required RxBool isLoading,
    String? id,
    Map<String, dynamic>? queryParams,
    bool showSuccessSnackBar = false,
    bool showResponse = false,
    Function(R result)? onSuccess,
  }) async {
    try {
      isLoading.value = true;
      log('|📥|---------[ 🌐 GET REQUEST STARTED ]---------|📥|');

      String fullUrl = '${ApiEndPoints.baseUrl}$endPoint';
      if (id != null && id.isNotEmpty) fullUrl += '/$id';
      final uri = Uri.parse(fullUrl).replace(
        queryParameters: queryParams?.map((k, v) => MapEntry(k, v.toString())),
      );
      printUrl(uri.toString());

      final response = await http.get(uri, headers: await _bearerHeaderInfo())
          .timeout(const Duration(seconds: 120));

      if (showResponse) {
        try {
          final prettyJson = const JsonEncoder.withIndent('  ').convert(jsonDecode(response.body));
          log('|📤| RESPONSE BODY |📤|');
          log(prettyJson);
        } catch (_) {
          log('|📤| RESPONSE (raw) |📤|: ${response.body}');
        }
      }

      log('|✅|---------[ ✅ GET REQUEST COMPLETED ]---------|✅|');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final result = fromJson(json);
        if (showSuccessSnackBar) {
          final successMessage = json['message'] ?? Strings.requestCompletedSuccessfully;
          CustomSnackBar.success(title: Strings.success, message: successMessage);
        }
        if (onSuccess != null) onSuccess(result);
        return result;
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Something went wrong!';
        log('❌ Error: $errorMessage');
        CustomSnackBar.error(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('🐞 ERROR: ${e.toString()}');
      throw Exception(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Add PATCH, PUT, DELETE, multiMultipartRequest, toggleFavorite methods here
  // (You can copy them from your existing script)
}
EOF

echo "✅ ApiRequest.dart created successfully!"
