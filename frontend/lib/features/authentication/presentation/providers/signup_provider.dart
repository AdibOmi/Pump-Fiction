import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';

final signupProvider = StateNotifierProvider<SignupNotifier, AsyncValue<bool>>((
  ref,
) {
  return SignupNotifier(ref);

});
//hello from the other side
class SignupNotifier extends StateNotifier<AsyncValue<bool>> {
  final Ref ref;

  SignupNotifier(this.ref) : super(const AsyncValue.data(false));

  Future<void> signup({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    state = const AsyncValue.loading();

    try {
      await ref
          .read(authNotifierProvider.notifier)
          .signup(email, password, fullName, phone.isEmpty ? null : phone);

      state = const AsyncValue.data(true);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}
