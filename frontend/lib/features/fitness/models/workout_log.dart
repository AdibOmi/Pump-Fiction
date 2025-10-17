import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../state/workout_logs_provider.dart';

/// Public provider you can watch in the UI.
/// Usage: final logs = ref.watch(workoutLogsProvider);
final workoutLogsProvider =
    StateNotifierProvider<WorkoutLogsNotifier, List<WorkoutLog>>(
  (ref) => WorkoutLogsNotifier(),
);

/// Manages a persisted list of [WorkoutLog]s.
///
/// Storage format:
/// - SharedPreferences key [_kLogsKey] holds a JSON array of WorkoutLog objects.
class WorkoutLogsNotifier extends StateNotifier<List<WorkoutLog>> {
  WorkoutLogsNotifier() : super(const []) {
    _load();
  }

  static const String _kLogsKey = 'workout_logs_v1';

  // --------------------------- Public API ---------------------------

  /// Insert or replace a full workout log by its [id].
  Future<void> upsert(WorkoutLog log) async {
    final list = [...state];
    final i = list.indexWhere((w) => w.id == log.id);
    if (i >= 0) {
      list[i] = log;
    } else {
      list.add(log);
    }
    _sortByDateDesc(list);
    state = list;
    await _persist();
  }

  /// Remove a workout log by id.
  Future<void> delete(String logId) async {
    state = [for (final w in state) if (w.id != logId) w];
    await _persist();
  }

  /// Remove all logs (useful for debugging).
  Future<void> clearAll() async {
    state = const [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLogsKey);
  }

  // ---- Mutating helpers for exercises/sets inside a log ----

  /// Add a new [exercise] to the log with [logId].
  Future<void> addExercise(String logId, LoggedExercise exercise) async {
    final list = [...state];
    final i = list.indexWhere((w) => w.id == logId);
    if (i < 0) return;
    final updated = list[i].copyWith(
      exercises: [...list[i].exercises, exercise],
    );
    list[i] = updated;
    state = list;
    await _persist();
  }

  /// Replace an exercise at [exerciseIndex] in the log with [logId].
  Future<void> updateExercise(
    String logId,
    int exerciseIndex,
    LoggedExercise exercise,
  ) async {
    final list = [...state];
    final i = list.indexWhere((w) => w.id == logId);
    if (i < 0) return;
    final ex = [...list[i].exercises];
    if (exerciseIndex < 0 || exerciseIndex >= ex.length) return;
    ex[exerciseIndex] = exercise;
    list[i] = list[i].copyWith(exercises: ex);
    state = list;
    await _persist();
  }

  /// Delete an exercise at [exerciseIndex] in the log with [logId].
  Future<void> deleteExercise(String logId, int exerciseIndex) async {
    final list = [...state];
    final i = list.indexWhere((w) => w.id == logId);
    if (i < 0) return;
    final ex = [...list[i].exercises];
    if (exerciseIndex < 0 || exerciseIndex >= ex.length) return;
    ex.removeAt(exerciseIndex);
    list[i] = list[i].copyWith(exercises: ex);
    state = list;
    await _persist();
  }

  /// Append a [set] to an exercise within a log.
  Future<void> addSet(
    String logId,
    int exerciseIndex,
    LoggedSet set,
  ) async {
    final list = [...state];
    final i = list.indexWhere((w) => w.id == logId);
    if (i < 0) return;
    final ex = [...list[i].exercises];
    if (exerciseIndex < 0 || exerciseIndex >= ex.length) return;

    final sets = [...ex[exerciseIndex].sets, set];
    ex[exerciseIndex] = ex[exerciseIndex].copyWith(sets: sets);

    list[i] = list[i].copyWith(exercises: ex);
    state = list;
    await _persist();
  }

  /// Replace a set at [setIndex] in an exercise within a log.
  Future<void> updateSet(
    String logId,
    int exerciseIndex,
    int setIndex,
    LoggedSet set,
  ) async {
    final list = [...state];
    final i = list.indexWhere((w) => w.id == logId);
    if (i < 0) return;
    final ex = [...list[i].exercises];
    if (exerciseIndex < 0 || exerciseIndex >= ex.length) return;

    final sets = [...ex[exerciseIndex].sets];
    if (setIndex < 0 || setIndex >= sets.length) return;
    sets[setIndex] = set;

    ex[exerciseIndex] = ex[exerciseIndex].copyWith(sets: sets);
    list[i] = list[i].copyWith(exercises: ex);
    state = list;
    await _persist();
  }

  /// Remove a set at [setIndex] in an exercise within a log.
  Future<void> deleteSet(
    String logId,
    int exerciseIndex,
    int setIndex,
  ) async {
    final list = [...state];
    final i = list.indexWhere((w) => w.id == logId);
    if (i < 0) return;
    final ex = [...list[i].exercises];
    if (exerciseIndex < 0 || exerciseIndex >= ex.length) return;

    final sets = [...ex[exerciseIndex].sets];
    if (setIndex < 0 || setIndex >= sets.length) return;
    sets.removeAt(setIndex);

    ex[exerciseIndex] = ex[exerciseIndex].copyWith(sets: sets);
    list[i] = list[i].copyWith(exercises: ex);
    state = list;
    await _persist();
  }

  /// Change the displayed day label (e.g., "Day 1" → "Push Day").
  Future<void> renameDayLabel(String logId, String newLabel) async {
    final list = [...state];
    final i = list.indexWhere((w) => w.id == logId);
    if (i < 0) return;
    list[i] = list[i].copyWith(dayLabel: newLabel);
    state = list;
    await _persist();
  }

  // -------------------------- Persistence --------------------------

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(state.map((w) => w.toJson()).toList());
      await prefs.setString(_kLogsKey, json);
    } catch (e, st) {
      if (kDebugMode) {
        // Don't throw in production; just log for debug.
        // ignore: avoid_print
        print('WorkoutLogsNotifier._persist error: $e\n$st');
      }
    }
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kLogsKey);
      if (raw == null) return;

      final decoded = (jsonDecode(raw) as List)
          .map((e) => WorkoutLog.fromJson(e as Map<String, dynamic>))
          .toList();

      _sortByDateDesc(decoded);
      state = decoded;
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('WorkoutLogsNotifier._load error: $e\n$st');
      }
    }
  }

  void _sortByDateDesc(List<WorkoutLog> list) {
    list.sort((a, b) => b.date.compareTo(a.date));
  }

  // Convenience wrappers to match older API usages
  Future<void> add(WorkoutLog log) => upsert(log);

  Future<void> update(WorkoutLog log) => upsert(log);

  Future<void> remove(String id) => delete(id);
}