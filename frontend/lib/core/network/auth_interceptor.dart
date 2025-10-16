import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  final Dio dio;

  AuthInterceptor({required this.storage, required this.dio});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add access token to requests if available
    final token = await storage.read(key: ApiConstants.accessTokenKey);
    if (token != null) {
      options.headers[ApiConstants.authorization] =
          '${ApiConstants.bearer} $token';
    }

    // Set content type
    options.headers['Content-Type'] = ApiConstants.contentType;

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry original request with new token
          final token = await storage.read(key: ApiConstants.accessTokenKey);
          final options = err.requestOptions;
          options.headers[ApiConstants.authorization] =
              '${ApiConstants.bearer} $token';

          try {
            final response = await dio.fetch(options);
            return handler.resolve(response);
          } catch (e) {
            // If retry fails, proceed with original error
            return handler.next(err);
          }
        }
      } catch (e) {
        // Refresh failed, clear tokens and proceed with error
        await _clearTokens();
      }
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await storage.read(
        key: ApiConstants.refreshTokenKey,
      );
      if (refreshToken == null) return false;

      final response = await dio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Content-Type': ApiConstants.contentType}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await storage.write(
          key: ApiConstants.accessTokenKey,
          value: data['access_token'],
        );
        await storage.write(
          key: ApiConstants.refreshTokenKey,
          value: data['refresh_token'],
        );
        return true;
      }
    } catch (e) {
      // Refresh failed
    }

    return false;
  }

  Future<void> _clearTokens() async {
    await storage.delete(key: ApiConstants.accessTokenKey);
    await storage.delete(key: ApiConstants.refreshTokenKey);
    await storage.delete(key: ApiConstants.userDataKey);
  }
}
