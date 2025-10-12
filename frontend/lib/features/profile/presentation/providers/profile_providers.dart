import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'profile_providers.g.dart';

@riverpod
String profileState(Ref ref) {
  return 'loading';
}
