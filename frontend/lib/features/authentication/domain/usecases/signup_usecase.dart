import '../repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class SignupUseCase {
  final AuthRepository repository;
  SignupUseCase(this.repository);

  Future<TokenResponse> call(SignupRequest request) async {
    return repository.signup(request);
  }
}
