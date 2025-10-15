// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$apiClientHash() => r'a0eb8837fc3cfc2ac414f9bdd23761e2186e929e';

/// See also [apiClient].
@ProviderFor(apiClient)
final apiClientProvider = AutoDisposeProvider<ApiClient>.internal(
  apiClient,
  name: r'apiClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$apiClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ApiClientRef = AutoDisposeProviderRef<ApiClient>;
String _$authRepositoryHash() => r'a6da9d223264a2d6bc781f91c9fe6ca5d017e738';

/// See also [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$loginUseCaseHash() => r'cbfd4200f40c132516f20f942ae9d825a31e2515';

/// See also [loginUseCase].
@ProviderFor(loginUseCase)
final loginUseCaseProvider = AutoDisposeProvider<LoginUseCase>.internal(
  loginUseCase,
  name: r'loginUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$loginUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LoginUseCaseRef = AutoDisposeProviderRef<LoginUseCase>;
String _$signupUseCaseHash() => r'27e1de0b7da056b5ef6e147520f921a37ce49d23';

/// See also [signupUseCase].
@ProviderFor(signupUseCase)
final signupUseCaseProvider = AutoDisposeProvider<SignupUseCase>.internal(
  signupUseCase,
  name: r'signupUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$signupUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SignupUseCaseRef = AutoDisposeProviderRef<SignupUseCase>;
String _$isAuthenticatedHash() => r'a2fbe6e585c4869a5817900837a9e284cb6716dd';

/// See also [isAuthenticated].
@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = AutoDisposeProvider<bool>.internal(
  isAuthenticated,
  name: r'isAuthenticatedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAuthenticatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAuthenticatedRef = AutoDisposeProviderRef<bool>;
String _$authNotifierHash() => r'133c8992ddf09b5f63442ff3ba5ec2d8b6da2138';

/// See also [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AuthNotifier, UserModel?>.internal(
      AuthNotifier.new,
      name: r'authNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthNotifier = AutoDisposeAsyncNotifier<UserModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
