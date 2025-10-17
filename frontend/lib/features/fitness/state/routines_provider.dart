import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/routine_models.dart';

class RoutinesNotifier extends StateNotifier<List<RoutinePlan>> {
  RoutinesNotifier() : super([]) {
    _load(); // fire-and-forget load on startup
  }

  String? currentRoutineId;

  static const _kRoutinesKey = 'fitness_routines_v1';
  static const _kCurrentKey  = 'fitness_current_routine_id_v1';

  // ----- mutations -----
  void add(RoutinePlan plan) {
    state = [...state, plan];
    _persist();
  }

  void update(RoutinePlan plan) {
    state = [
      for (final p in state) if (p.id == plan.id) plan else p,
    ];
    _persist();
  }

  void remove(String id) {
    state = [for (final p in state) if (p.id != id) p];
    if (currentRoutineId == id) currentRoutineId = null;
    _persist();
  }

  void setCurrent(String id) {
    currentRoutineId = id;
    _persist();
  }

  RoutinePlan? get current =>
      state.where((p) => p.id == currentRoutineId).cast<RoutinePlan?>().firstOrNull;

  // ----- persistence -----
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.map((p) => p.toJson()).toList();
    await prefs.setString(_kRoutinesKey, jsonEncode(jsonList));
    if (currentRoutineId != null) {
      await prefs.setString(_kCurrentKey, currentRoutineId!);
    } else {
      await prefs.remove(_kCurrentKey);
    }
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kRoutinesKey);
    final current = prefs.getString(_kCurrentKey);

    if (raw != null) {
      final list = (jsonDecode(raw) as List<dynamic>)
          .map((e) => RoutinePlan.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    }
    currentRoutineId = current;
  }
}

final routinesProvider =
    StateNotifierProvider<RoutinesNotifier, List<RoutinePlan>>((ref) => RoutinesNotifier());
