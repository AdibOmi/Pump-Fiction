import '../repositories/profile_repository.dart';
import '../../data/models/profile_model.dart';

class GetProfileUseCase {
  final ProfileRepository repository;
  GetProfileUseCase(this.repository);

  Future<ProfileModel> call(String userId) async {
    return repository.getProfile(userId);
  }
}
