import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/user_profile_model.dart';

class UserProfileRepository {
  final ApiClient _apiClient;

  UserProfileRepository(this._apiClient);

  /// Get current user's profile
  /// Returns null if profile doesn't exist
  Future<UserProfileModel?> getProfile() async {
    try {
      print('🔍 Calling API: ${ApiConstants.userProfile}');
      final response = await _apiClient.get(
        ApiConstants.userProfile,
      );

      print('✅ API Response Status: ${response.statusCode}');
      print('✅ API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final profile = UserProfileModel.fromJson(response.data);
        print('✅ Profile parsed successfully: ${profile.email}');
        return profile;
      }
      return null;
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.statusCode} - ${e.message}');
      print('❌ Response data: ${e.response?.data}');
      if (e.response?.statusCode == 404) {
        // Profile doesn't exist yet
        return null;
      }
      throw Exception('Failed to get profile: ${e.message}');
    } catch (e) {
      print('❌ Exception: $e');
      throw Exception('Failed to get profile: $e');
    }
  }

  /// Update user profile
  /// Creates profile if it doesn't exist
  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.userProfile,
        data: profile.toJson(),
      );

      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(response.data);
      } else {
        throw Exception('Update failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['detail'] ?? 'Failed to update profile');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Profile not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Update profile with partial data
  /// Only updates the fields that are provided
  Future<UserProfileModel> updateProfilePartial(Map<String, dynamic> data) async {
    try {
      Response<dynamic> response;
      try {
        response = await _apiClient.patch(
          ApiConstants.userProfile,
          data: data,
        );
      } on DioException catch (e) {
        // Some environments (older backend versions) might still expect PUT.
        if (e.response?.statusCode == 405) {
          response = await _apiClient.put(
            ApiConstants.userProfile,
            data: data,
          );
        } else {
          rethrow;
        }
      }

      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(response.data);
      } else {
        throw Exception('Update failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['detail'] ?? 'Failed to update profile');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Profile not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Create a new profile
  /// Throws exception if profile already exists
  Future<UserProfileModel> createProfile(UserProfileModel profile) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.userProfile,
        data: profile.toJson(),
      );

      if (response.statusCode == 201) {
        return UserProfileModel.fromJson(response.data);
      } else {
        throw Exception('Create failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['detail'] ?? 'Failed to create profile');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create profile: $e');
    }
  }

  /// Delete user profile
  Future<void> deleteProfile() async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.userProfile,
      );

      if (response.statusCode != 204) {
        throw Exception('Delete failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Profile not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete profile: $e');
    }
  }
}
