import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'auth_providers.g.dart';

@riverpod
String authState(Ref ref) {
  // placeholder auth state
  return 'unauthenticated';
}
