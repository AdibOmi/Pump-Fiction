import '../repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class SignupUseCase {
  final AuthRepository repository;
  SignupUseCase(this.repository);

  Future<UserModel> call(String email, String password) async {
    return repository.signup(email, password);
  }
}
