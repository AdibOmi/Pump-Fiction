import 'package:flutter_riverpod/flutter_riverpod.dart';

// Controls global font scale for the app (page-level). Value is a double scale factor.
final fontScaleProvider = StateProvider<double>((ref) => 1.0);
