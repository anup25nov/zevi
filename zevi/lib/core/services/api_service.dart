import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../main.dart'; // To access global navigator for redirection if needed

class ApiService {
  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    final baseUrl = dotenv.env['API_URL'] ?? 'https://api.zevi.app';
    
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      _AuthInterceptor(_storage),
      _ErrorInterceptor(dio, _storage),
      if (dotenv.env['APP_ENV'] == 'dev') LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  _AuthInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  _ErrorInterceptor(this._dio, this._storage);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Unauthorized: Clear token and redirect to sign-in
      await _storage.delete(key: 'auth_token');
      // In a real app, you'd trigger a router redirect here
      // For now, we assume the UI listens to auth state changes
    } else if (err.response?.statusCode == 429) {
      // Rate limited
      debugPrint('Rate limited: Slow down');
    } else if (err.response?.statusCode != null && err.response!.statusCode! >= 500) {
      // Server error: Retry once
      if (err.requestOptions.extra['retried'] != true) {
        err.requestOptions.extra['retried'] = true;
        try {
          final response = await _dio.request(
            err.requestOptions.path,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
            options: Options(
              method: err.requestOptions.method,
              headers: err.requestOptions.headers,
              extra: err.requestOptions.extra,
            ),
          );
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      }
    }
    return handler.next(err);
  }
}

final apiServiceProvider = ApiService();
