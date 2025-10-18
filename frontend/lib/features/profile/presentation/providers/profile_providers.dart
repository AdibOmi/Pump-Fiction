import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../data/models/user_profile_model.dart';

part 'profile_providers.g.dart';

// Repository Provider
@riverpod
UserProfileRepository userProfileRepository(Ref ref) {
  final apiClient = ApiClient();
  return UserProfileRepository(apiClient);
}

// User Profile Provider
@riverpod
class UserProfile extends _$UserProfile {
  @override
  Future<UserProfileModel?> build() async {
    final repository = ref.watch(userProfileRepositoryProvider);
    try {
      print('📱 Fetching user profile...');
      final profile = await repository.getProfile();
      print('📱 Profile fetched: ${profile?.email}, ${profile?.fullName}');
      return profile;
    } catch (e) {
      print('❌ Error fetching profile: $e');
      // Return null if profile doesn't exist or there's an error
      return null;
    }
  }

  /// Refresh the profile data
  Future<void> refresh() async {
    state = const AsyncLoading();
    final repository = ref.read(userProfileRepositoryProvider);
    try {
      final profile = await repository.getProfile();
      state = AsyncData(profile);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Update the entire profile
  Future<void> updateProfile(UserProfileModel profile) async {
    final repository = ref.read(userProfileRepositoryProvider);
    try {
      final updatedProfile = await repository.updateProfile(profile);
      state = AsyncData(updatedProfile);
    } catch (e) {
      rethrow;
    }
  }

  /// Update profile with partial data
  /// Only updates the fields that are provided
  Future<void> updateProfilePartial(Map<String, dynamic> data) async {
    final repository = ref.read(userProfileRepositoryProvider);
    try {
      final updatedProfile = await repository.updateProfilePartial(data);
      state = AsyncData(updatedProfile);
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new profile
  Future<void> createProfile(UserProfileModel profile) async {
    final repository = ref.read(userProfileRepositoryProvider);
    try {
      final newProfile = await repository.createProfile(profile);
      state = AsyncData(newProfile);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete the profile
  Future<void> deleteProfile() async {
    final repository = ref.read(userProfileRepositoryProvider);
    try {
      await repository.deleteProfile();
      state = const AsyncData(null);
    } catch (e) {
      rethrow;
    }
  }
}

// Loading state for profile operations
final isUpdatingProfileProvider = StateProvider<bool>((ref) => false);
