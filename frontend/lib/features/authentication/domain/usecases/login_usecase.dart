import '../repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<TokenResponse> call(LoginRequest request) async {
    return repository.login(request);
  }
}
