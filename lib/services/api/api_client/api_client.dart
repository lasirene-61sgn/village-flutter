import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  late final Dio _dio;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // ------------------ INIT ------------------
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "https://villagea.lasirene.xyz/",
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getToken();
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  // ------------------ TOKEN ------------------
  Future<String> _getToken() async {
    final prefs = await _prefs;
    final isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    final token = prefs.getString("token") ?? "";
    print(token ?? '');
    return isLoggedIn && token.isNotEmpty ? token : "";
  }

  // ------------------ GET ------------------
  Future<dynamic> get({
    String? endpoint,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.get(
        endpoint ?? '',
        queryParameters: query,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleDioError(e);
    }
  }

  // ------------------ POST ------------------
  Future<dynamic> post({
    String? endpoint,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.post(
        endpoint ?? '',
        data: body ?? {},
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleDioError(e);
    }
  }

  // ------------------ PUT (JSON) ------------------
  Future<dynamic> put({
    String? endpoint,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.put(
        endpoint ?? '',
        data: body ?? {},
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleDioError(e);
    }
  }

  // ------------------ DELETE ------------------
  Future<dynamic> delete({
    String? endpoint,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint ?? '',
        data: body,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleDioError(e);
    }
  }

  // ------------------ HEADER LESS POST ------------------
  Future<dynamic> headerLessPost({
    String? endpoint,
    Map<String, dynamic>? body,
  }) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: _dio.options.baseUrl,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      final response = await dio.post(
        endpoint ?? '',
        data: body ?? {},
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleDioError(e);
    }
  }

  // ------------------ POST WITH FILES ------------------
  Future<dynamic> postWithFiles({
    String? endpoint,
    Map<String, dynamic>? fields,
    Map<String, dynamic>? files,
  }) async {
    try {
      final formData = FormData();
        print("this is a files$files");
      fields?.forEach((k, v) {
        if (v != null) {
          formData.fields.add(MapEntry(k, v.toString()));
        }
      });

      _attachFiles(formData, files);

      final response = await _dio.post(
        endpoint ?? '',
        data: formData,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleDioError(e);
    }
  }

  // ------------------ PUT WITH FILES ------------------
  Future<dynamic> putWithFiles({
    String? endpoint,
    Map<String, dynamic>? fields,
    Map<String, dynamic>? files,
  }) async {
    try {
      final formData = FormData();

      print("this is a files$files");
      fields?.forEach((k, v) {
        if (v != null) {
          formData.fields.add(MapEntry(k, v.toString()));
        }
      });

      _attachFiles(formData, files);

      final response = await _dio.put(
        endpoint ?? '',
        data: formData,
      );
      return _handleResponse(response);
    } catch (e) {
      print("profile error :${e.toString()}");
      return _handleDioError(e);
    }
  }

  // ------------------ FILE HELPER ------------------
  void _attachFiles(FormData formData, Map<String, dynamic>? files) {
    if (files == null) return;

    files.forEach((key, value) {
      if (value == null) return;

      final list = value is List ? value : [value];

      for (final item in list) {
        // FIX: Handle standard dart:io File objects
        if (item is File) {
          final path = item.path;
          final fileName = path.split('/').last;
          final mime = lookupMimeType(path) ?? 'image/jpeg';

          formData.files.add(
            MapEntry(
              key,
              MultipartFile.fromFileSync(
                path,
                filename: fileName,
                contentType: MediaType.parse(mime),
              ),
            ),
          );
        }
        // Keep existing PlatformFile support
        else if (item is PlatformFile) {
          final mime = lookupMimeType(item.name) ?? 'application/octet-stream';

          if (kIsWeb && item.bytes != null) {
            formData.files.add(
              MapEntry(
                key,
                MultipartFile.fromBytes(
                  item.bytes!,
                  filename: item.name,
                  contentType: MediaType.parse(mime),
                ),
              ),
            );
          } else if (!kIsWeb && item.path != null) {
            formData.files.add(
              MapEntry(
                key,
                MultipartFile.fromFileSync(
                  item.path!,
                  filename: item.name,
                  contentType: MediaType.parse(mime),
                ),
              ),
            );
          }
        }
      }
    });
  }

  // ------------------ RESPONSE HANDLER ------------------
// Inside api_client.dart

  dynamic _handleResponse(Response response) {
    final status = response.statusCode ?? 0;
    final responseData = response.data;

    // 1. Success (200 - 299)
    if (status >= 200 && status < 300) {
      return {
        "status": 1,
        "message": responseData['message'] ?? "Success", // Extract success message
        "data": responseData,
      };
    }

    // 2. Unauthenticated
    if (status == 401) {
      return {
        "status": 2,
        "message": "Session expired. Please login again.",
      };
    }

    // 3. Errors (400, 422, 500, etc.)
    // Often Laravel errors are in responseData['message']
    return {
      "status": 0,
      "message": responseData is Map ? (responseData['message'] ?? "Something went wrong") : "Unexpected error",
    };
  }

  // ------------------ ERROR HANDLER ------------------
  dynamic _handleDioError(dynamic error) {
    if (error is DioException) {
      final response = error.response;
      return {
        "status": 0,
        "message": response?.data ?? error.message,
      };
    }

    return {
      "status": 0,
      "message": "Unexpected error occurred",
    };
  }
}
