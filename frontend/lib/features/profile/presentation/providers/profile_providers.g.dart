// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userProfileRepositoryHash() =>
    r'3b068c6b7efd0443104d69eda28eb95d0325555a';

/// See also [userProfileRepository].
@ProviderFor(userProfileRepository)
final userProfileRepositoryProvider =
    AutoDisposeProvider<UserProfileRepository>.internal(
      userProfileRepository,
      name: r'userProfileRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userProfileRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserProfileRepositoryRef =
    AutoDisposeProviderRef<UserProfileRepository>;
String _$userProfileHash() => r'82fa6cb46fd11511f9946902196861538dc9dab5';

/// See also [UserProfile].
@ProviderFor(UserProfile)
final userProfileProvider =
    AutoDisposeAsyncNotifierProvider<UserProfile, UserProfileModel?>.internal(
      UserProfile.new,
      name: r'userProfileProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userProfileHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UserProfile = AutoDisposeAsyncNotifier<UserProfileModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
