// Dio HTTP client with interceptors — Leandro Perez — SonhoLab
// Handles:
//   • Bearer token injection on every request
//   • Automatic token refresh on 401 (single retry)
//   • Request / response logging in debug mode
//   • Consistent error transformation into exceptions

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_clean_starter/core/error/exceptions.dart';
import 'package:flutter_clean_starter/core/network/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key used to persist the access token in [SharedPreferences].
const String kAccessTokenKey = 'access_token';

/// Key used to persist the refresh token in [SharedPreferences].
const String kRefreshTokenKey = 'refresh_token';

/// Creates and configures a [Dio] instance ready for production use.
///
/// Inject this via Riverpod so it can be easily overridden in tests.
Dio buildDioClient(SharedPreferences prefs) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: ApiEndpoints.connectTimeout,
      receiveTimeout: ApiEndpoints.receiveTimeout,
      sendTimeout: ApiEndpoints.sendTimeout,
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        HttpHeaders.acceptHeader: ContentType.json.mimeType,
      },
    ),
  );

  // Order matters: auth interceptor first, then logger.
  dio.interceptors.addAll([
    _AuthInterceptor(dio: dio, prefs: prefs),
    if (kDebugMode) _LoggingInterceptor(),
  ]);

  return dio;
}

// ---------------------------------------------------------------------------
// Auth interceptor
// ---------------------------------------------------------------------------

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor({required this.dio, required this.prefs});

  final Dio dio;
  final SharedPreferences prefs;

  bool _isRefreshing = false;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final token = prefs.getString(kAccessTokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only attempt refresh for 401 responses, but not on the refresh endpoint
    // itself (to avoid infinite loops).
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains(ApiEndpoints.refreshToken) &&
        !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = prefs.getString(kRefreshTokenKey);
        if (refreshToken == null) {
          _isRefreshing = false;
          handler.next(err);
          return;
        }

        // Attempt token refresh.
        final refreshResponse = await dio.post<Map<String, dynamic>>(
          ApiEndpoints.refreshToken,
          data: {'refresh_token': refreshToken},
          options: Options(extra: {'skipAuth': true}),
        );

        final newAccessToken =
            refreshResponse.data?['access_token'] as String?;
        final newRefreshToken =
            refreshResponse.data?['refresh_token'] as String?;

        if (newAccessToken != null) {
          await prefs.setString(kAccessTokenKey, newAccessToken);
        }
        if (newRefreshToken != null) {
          await prefs.setString(kRefreshTokenKey, newRefreshToken);
        }

        // Retry original request with the new token.
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final response = await dio.fetch<dynamic>(retryOptions);
        _isRefreshing = false;
        handler.resolve(response);
      } on DioException catch (e) {
        _isRefreshing = false;
        handler.next(e);
      }
    } else {
      handler.next(err);
    }
  }
}

// ---------------------------------------------------------------------------
// Logging interceptor (debug only)
// ---------------------------------------------------------------------------

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint(
      '[DIO] --> ${options.method} ${options.uri}\n'
      '       Headers: ${options.headers}\n'
      '       Data: ${options.data}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    debugPrint(
      '[DIO] <-- ${response.statusCode} ${response.requestOptions.uri}\n'
      '       Data: ${response.data}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '[DIO] ERR ${err.response?.statusCode} '
      '${err.requestOptions.uri}: ${err.message}',
    );
    handler.next(err);
  }
}

// ---------------------------------------------------------------------------
// DioClient facade — thin wrapper used by data sources
// ---------------------------------------------------------------------------

/// Thin facade around [Dio] that converts [DioException]s into typed
/// [ServerException] / [NetworkException] / [AuthException].
class DioClient {
  const DioClient({required this.dio});

  final Dio dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get<T>(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await dio.post<T>(path, data: data, options: options);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await dio.put<T>(path, data: data, options: options);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    Options? options,
  }) async {
    try {
      return await dio.delete<T>(path, options: options);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Exception _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = _extractMessage(e.response?.data) ??
            e.response?.statusMessage ??
            'Unknown server error';
        if (statusCode == 401 || statusCode == 403) {
          return AuthException(message: message, statusCode: statusCode);
        }
        return ServerException(message: message, statusCode: statusCode);
      case DioExceptionType.cancel:
        return ServerException(message: 'Request was cancelled.', statusCode: 0);
      case DioExceptionType.badCertificate:
        return const NetworkException(message: 'SSL certificate error.');
      case DioExceptionType.unknown:
        return NetworkException(message: e.message ?? 'Unknown network error.');
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return (data['message'] ?? data['error'])?.toString();
    }
    return null;
  }
}
