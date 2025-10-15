import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<TokenResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final tokenResponse = TokenResponse.fromJson(response.data);

        // Store tokens securely
        if (tokenResponse.accessToken != null) {
          await _apiClient.storage.write(
            key: ApiConstants.accessTokenKey,
            value: tokenResponse.accessToken!,
          );
        }
        if (tokenResponse.refreshToken != null) {
          await _apiClient.storage.write(
            key: ApiConstants.refreshTokenKey,
            value: tokenResponse.refreshToken!,
          );
        }

        // Store user data
        await _apiClient.storage.write(
          key: ApiConstants.userDataKey,
          value: jsonEncode(tokenResponse.user.toJson()),
        );

        return tokenResponse;
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['detail'] ?? 'Invalid credentials');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<TokenResponse> signup(SignupRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.signup,
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        final tokenResponse = TokenResponse.fromJson(response.data);

        // Store tokens securely if available (depends on email confirmation setting)
        if (tokenResponse.accessToken != null) {
          await _apiClient.storage.write(
            key: ApiConstants.accessTokenKey,
            value: tokenResponse.accessToken!,
          );
        }
        if (tokenResponse.refreshToken != null) {
          await _apiClient.storage.write(
            key: ApiConstants.refreshTokenKey,
            value: tokenResponse.refreshToken!,
          );
        }

        // Store user data
        await _apiClient.storage.write(
          key: ApiConstants.userDataKey,
          value: jsonEncode(tokenResponse.user.toJson()),
        );

        return tokenResponse;
      } else {
        throw Exception('Signup failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['detail'] ?? 'Registration failed');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Clear all stored data
      await _apiClient.storage.delete(key: ApiConstants.accessTokenKey);
      await _apiClient.storage.delete(key: ApiConstants.refreshTokenKey);
      await _apiClient.storage.delete(key: ApiConstants.userDataKey);
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final userDataString = await _apiClient.storage.read(
        key: ApiConstants.userDataKey,
      );
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await _apiClient.storage.read(
        key: ApiConstants.accessTokenKey,
      );
      return token != null;
    } catch (e) {
      return false;
    }
  }
}
