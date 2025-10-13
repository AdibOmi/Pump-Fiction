import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine_models.dart';

class RoutinesNotifier extends StateNotifier<List<RoutinePlan>> {
  RoutinesNotifier() : super([]);

  String? currentRoutineId;

  void add(RoutinePlan plan) {
    state = [...state, plan];
  }

  void update(RoutinePlan plan) {
    state = [
      for (final p in state) if (p.id == plan.id) plan else p,
    ];
  }

  void remove(String id) {
    state = [for (final p in state) if (p.id != id) p];
    if (currentRoutineId == id) currentRoutineId = null;
  }

  void setCurrent(String id) => currentRoutineId = id;

  RoutinePlan? get current =>
      state.where((p) => p.id == currentRoutineId).cast<RoutinePlan?>().firstOrNull;
}

final routinesProvider =
    StateNotifierProvider<RoutinesNotifier, List<RoutinePlan>>((ref) => RoutinesNotifier());
