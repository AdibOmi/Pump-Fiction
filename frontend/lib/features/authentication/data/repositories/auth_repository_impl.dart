import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<UserModel> login(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<UserModel> signup(String email, String password) async {
    throw UnimplementedError();
  }
}
