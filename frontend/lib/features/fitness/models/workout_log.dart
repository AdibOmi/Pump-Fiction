import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/workout_logs_provider.dart';
import '../repositories/workout_log_repository.dart';

/// Public provider you can watch in the UI.
/// Usage: final logs = ref.watch(workoutLogsProvider);
final workoutLogsProvider =
    StateNotifierProvider<WorkoutLogsNotifier, List<WorkoutLog>>(
  (ref) {
    final repository = ref.watch(workoutLogRepositoryProvider);
    return WorkoutLogsNotifier(repository);
  },
);

final workoutLogRepositoryProvider = Provider<WorkoutLogRepository>((ref) {
  return WorkoutLogRepository();
});

/// Manages a persisted list of [WorkoutLog]s using backend API.
class WorkoutLogsNotifier extends StateNotifier<List<WorkoutLog>> {
  final WorkoutLogRepository _repository;

  WorkoutLogsNotifier(this._repository) : super(const []) {
    _load();
  }

  // --------------------------- Public API ---------------------------

  /// Load workout logs from backend
  Future<void> _load() async {
    try {
      final logs = await _repository.getAllWorkoutLogs();
      state = logs;
    } catch (e) {
      print('Error loading workout logs: $e');
      // Keep empty state on error
    }
  }

  /// Refresh workout logs from backend
  Future<void> refresh() async {
    await _load();
  }

  /// Insert or replace a full workout log by its [id].
  Future<void> upsert(WorkoutLog log) async {
    try {
      WorkoutLog savedLog;
      final existingIndex = state.indexWhere((w) => w.id == log.id);

      if (existingIndex >= 0) {
        // Update existing log
        savedLog = await _repository.updateWorkoutLog(log.id, log);
        final list = List<WorkoutLog>.from(state);
        list[existingIndex] = savedLog;
        _sortByDateDesc(list);
        state = list;
      } else {
        // Create new log
        savedLog = await _repository.createWorkoutLog(log);
        final list = List<WorkoutLog>.from(state);
        list.add(savedLog);
        _sortByDateDesc(list);
        state = list;
      }
    } catch (e) {
      print('Error upserting workout log: $e');
      rethrow;
    }
  }

  /// Remove a workout log by id.
  Future<void> delete(String logId) async {
    try {
      await _repository.deleteWorkoutLog(logId);
      state = [for (final w in state) if (w.id != logId) w];
    } catch (e) {
      print('Error deleting workout log: $e');
      rethrow;
    }
  }

  /// Remove all logs (useful for debugging).
  Future<void> clearAll() async {
    // Delete all logs from backend
    for (final log in state) {
      try {
        await _repository.deleteWorkoutLog(log.id);
      } catch (e) {
        print('Error deleting log ${log.id}: $e');
      }
    }
    state = const [];
  }

  // ---- Mutating helpers for exercises/sets inside a log ----
  // Note: These update the entire log in the backend

  /// Add a new [exercise] to the log with [logId].
  Future<void> addExercise(String logId, LoggedExercise exercise) async {
    final list = [...state];
    final i = list.indexWhere((w) => w.id == logId);
    if (i < 0) return;

    final updated = list[i].copyWith(
      exercises: [...list[i].exercises, exercise],
    );

    try {
      final savedLog = await _repository.updateWorkoutLog(logId, updated);
      list[i] = savedLog;
      state = list;
    } catch (e) {
      print('Error adding exercise: $e');
      rethrow;
    }
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
    final updated = list[i].copyWith(exercises: ex);

    try {
      final savedLog = await _repository.updateWorkoutLog(logId, updated);
      list[i] = savedLog;
      state = list;
    } catch (e) {
      print('Error updating exercise: $e');
      rethrow;
    }
  }

  /// Delete an exercise at [exerciseIndex] in the log with [logId].
  Future<void> deleteExercise(String logId, int exerciseIndex) async {
    final list = [...state];
    final i = list.indexWhere((w) => w.id == logId);
    if (i < 0) return;
    final ex = [...list[i].exercises];
    if (exerciseIndex < 0 || exerciseIndex >= ex.length) return;

    ex.removeAt(exerciseIndex);
    final updated = list[i].copyWith(exercises: ex);

    try {
      final savedLog = await _repository.updateWorkoutLog(logId, updated);
      list[i] = savedLog;
      state = list;
    } catch (e) {
      print('Error deleting exercise: $e');
      rethrow;
    }
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

    final updated = list[i].copyWith(exercises: ex);

    try {
      final savedLog = await _repository.updateWorkoutLog(logId, updated);
      list[i] = savedLog;
      state = list;
    } catch (e) {
      print('Error adding set: $e');
      rethrow;
    }
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
    final updated = list[i].copyWith(exercises: ex);

    try {
      final savedLog = await _repository.updateWorkoutLog(logId, updated);
      list[i] = savedLog;
      state = list;
    } catch (e) {
      print('Error updating set: $e');
      rethrow;
    }
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
    final updated = list[i].copyWith(exercises: ex);

    try {
      final savedLog = await _repository.updateWorkoutLog(logId, updated);
      list[i] = savedLog;
      state = list;
    } catch (e) {
      print('Error deleting set: $e');
      rethrow;
    }
  }

  /// Change the displayed day label (e.g., "Day 1" → "Push Day").
  Future<void> renameDayLabel(String logId, String newLabel) async {
    final list = [...state];
    final i = list.indexWhere((w) => w.id == logId);
    if (i < 0) return;

    final updated = list[i].copyWith(dayLabel: newLabel);

    try {
      final savedLog = await _repository.updateWorkoutLog(logId, updated);
      list[i] = savedLog;
      state = list;
    } catch (e) {
      print('Error renaming day label: $e');
      rethrow;
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
