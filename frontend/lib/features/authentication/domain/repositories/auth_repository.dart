import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<TokenResponse> login(LoginRequest request);
  Future<TokenResponse> signup(SignupRequest request);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<bool> isLoggedIn();
}
