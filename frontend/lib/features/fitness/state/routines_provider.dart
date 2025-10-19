import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine_models.dart';
import '../repositories/routine_repository.dart';

class RoutinesNotifier extends StateNotifier<List<RoutinePlan>> {
  final RoutineRepository _repository;

  RoutinesNotifier(this._repository) : super([]) {
    _load(); // Load routines from backend on startup
  }

  String? currentRoutineId;

  // ----- Load routines from backend -----
  Future<void> _load() async {
    try {
      print('🔄 RoutinesNotifier: Loading routines from backend...');
      final routines = await _repository.getAllRoutines(includeArchived: false);
      print('✅ RoutinesNotifier: Loaded ${routines.length} routines');
      for (var routine in routines) {
        print('   - ${routine.title}: ${routine.dayPlans.length} days, ${routine.dayPlans.first.exercises.length} exercises');
      }
      state = routines;
      print('✅ RoutinesNotifier: State updated with ${state.length} routines');
    } catch (e) {
      print('❌ Error loading routines: $e');
      // Keep empty state on error
    }
  }

  // Refresh routines from backend
  Future<void> refresh() async {
    await _load();
  }

  // ----- mutations -----
  Future<void> add(RoutinePlan plan) async {
    try {
      // 🐛 DEBUG: Check what we're sending
      print('📤 Sending routine to backend:');
      print('Title: ${plan.title}');
      print('DayPlans count: ${plan.dayPlans.length}');
      for (var i = 0; i < plan.dayPlans.length; i++) {
        print('  Day $i (${plan.dayPlans[i].label}): ${plan.dayPlans[i].exercises.length} exercises');
      }
      final json = plan.toBackendJson();
      print('📦 Backend JSON:');
      print('  title: ${json['title']}');
      print('  day_selected: ${json['day_selected']}');
      print('  exercises: ${json['exercises']}');

      final createdRoutine = await _repository.createRoutine(plan);
      // Use explicit list creation for reliable state update
      final updatedList = List<RoutinePlan>.from(state);
      updatedList.insert(0, createdRoutine);
      state = updatedList;
    } catch (e) {
      print('Error adding routine: $e');
      rethrow;
    }
  }

  Future<void> update(RoutinePlan plan) async {
    try {
      final updatedRoutine = await _repository.updateRoutine(plan.id, plan);
      state = [
        for (final p in state) if (p.id == plan.id) updatedRoutine else p,
      ];
    } catch (e) {
      print('Error updating routine: $e');
      rethrow;
    }
  }

  Future<void> remove(String id) async {
    try {
      await _repository.deleteRoutine(id);
      state = [for (final p in state) if (p.id != id) p];
      if (currentRoutineId == id) currentRoutineId = null;
    } catch (e) {
      print('Error removing routine: $e');
      rethrow;
    }
  }

  Future<void> archive(String id, bool isArchived) async {
    try {
      final archivedRoutine = await _repository.archiveRoutine(id, isArchived);
      if (isArchived) {
        // Remove from list when archived
        state = [for (final p in state) if (p.id != id) p];
      } else {
        // Add back to list when unarchived
        state = [archivedRoutine, ...state];
      }
    } catch (e) {
      print('Error archiving routine: $e');
      rethrow;
    }
  }

  void setCurrent(String id) {
    currentRoutineId = id;
    // TODO: Persist current routine selection to backend or local storage if needed
  }

  RoutinePlan? get current =>
      state.where((p) => p.id == currentRoutineId).cast<RoutinePlan?>().firstOrNull;
}

final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  return RoutineRepository();
});

final routinesProvider =
    StateNotifierProvider<RoutinesNotifier, List<RoutinePlan>>((ref) {
  final repository = ref.watch(routineRepositoryProvider);
  return RoutinesNotifier(repository);
});
