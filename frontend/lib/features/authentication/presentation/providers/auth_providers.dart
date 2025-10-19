import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../data/models/user_model.dart';

part 'auth_providers.g.dart';

// API Client Provider
@riverpod
ApiClient apiClient(Ref ref) {
  return ApiClient();
}

// Repository Provider
@riverpod
AuthRepository authRepository(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepositoryImpl(apiClient);
}

// Use Cases Providers
@riverpod
LoginUseCase loginUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
}

@riverpod
SignupUseCase signupUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignupUseCase(repository);
}

// Auth State Provider
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<UserModel?> build() async {
    final repository = ref.watch(authRepositoryProvider);
    return await repository.getCurrentUser();
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncLoading();

    try {
      final loginUseCase = ref.read(loginUseCaseProvider);
      final request = LoginRequest(email: email, password: password);
      final response = await loginUseCase(request);

      if (response.message != null) {
        // Email confirmation required
        state = AsyncError(Exception(response.message!), StackTrace.current);
        return false;
      }

      state = AsyncData(response.user);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      // Do not rethrow so callers can handle UI without triggering external retries
      return false;
    }
  }

  Future<void> signup(
    String email,
    String password,
    String fullName,
    String? phoneNumber,
  ) async {
    state = const AsyncLoading();

    try {
      final signupUseCase = ref.read(signupUseCaseProvider);
      final request = SignupRequest(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      final response = await signupUseCase(request);

      if (response.message != null) {
        // Email confirmation required
        throw Exception(response.message!);
      }

      state = AsyncData(response.user);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
}

// Helper provider to check if user is authenticated
@riverpod
bool isAuthenticated(Ref ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.maybeWhen(data: (user) => user != null, orElse: () => false);
}
