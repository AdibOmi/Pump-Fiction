import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tracker_models.dart';
import 'tracker_repository.dart';

final trackersProvider =
    StateNotifierProvider<TrackersNotifier, List<Tracker>>(
  (ref) => TrackersNotifier(),
);

class TrackersNotifier extends StateNotifier<List<Tracker>> {
  final TrackerRepository _repository;

  TrackersNotifier({TrackerRepository? repository})
      : _repository = repository ?? TrackerRepository(),
        super(const []) {
    _load();
  }

  Future<void> addTracker({
    required String name,
    required String unit,
    double? goal,
  }) async {
    try {
      final tracker = await _repository.createTracker(
        name: name,
        unit: unit,
        goal: goal,
      );
      // Create a new list to ensure Riverpod detects the change
      final updatedList = List<Tracker>.from(state);
      updatedList.insert(0, tracker);
      state = updatedList;
      print('✅ Tracker added successfully: ${tracker.name}');
    } catch (e) {
      print('❌ Error adding tracker: $e');
      rethrow;
    }
  }

  Future<void> updateTracker(Tracker updated) async {
    try {
      final tracker = await _repository.updateTracker(updated);
      // Create a new list to ensure Riverpod detects the change
      final updatedList = state.map((t) => t.id == tracker.id ? tracker : t).toList();
      state = updatedList;
      print('✅ Tracker updated successfully: ${tracker.name}');
    } catch (e) {
      print('❌ Error updating tracker: $e');
      rethrow;
    }
  }

  Future<void> deleteTracker(String id) async {
    try {
      await _repository.deleteTracker(id);
      // Create a new list to ensure Riverpod detects the change
      final updatedList = state.where((t) => t.id != id).toList();
      state = updatedList;
      print('✅ Tracker deleted successfully');
    } catch (e) {
      print('❌ Error deleting tracker: $e');
      rethrow;
    }
  }

  Future<void> addEntry(String trackerId, TrackerEntry entry) async {
    try {
      final savedEntry = await _repository.addEntry(trackerId, entry);
      final list = [...state];
      final i = list.indexWhere((t) => t.id == trackerId);
      if (i < 0) return;
      list[i].entries.add(savedEntry);
      list[i].entries.sort((a, b) => b.date.compareTo(a.date)); // newest first
      state = list;
    } catch (e) {
      print('Error adding entry: $e');
      rethrow;
    }
  }

  Future<void> updateEntry(
    String trackerId,
    int index,
    TrackerEntry entry,
  ) async {
    try {
      final list = [...state];
      final i = list.indexWhere((t) => t.id == trackerId);
      if (i < 0) return;
      if (index < 0 || index >= list[i].entries.length) return;

      final entryId = list[i].entries[index].id;
      if (entryId == null) return;

      final updatedEntry = await _repository.updateEntry(trackerId, entryId, entry);
      list[i].entries[index] = updatedEntry;
      list[i].entries.sort((a, b) => b.date.compareTo(a.date));
      state = list;
    } catch (e) {
      print('Error updating entry: $e');
      rethrow;
    }
  }

  Future<void> deleteEntry(String trackerId, int index) async {
    try {
      final list = [...state];
      final i = list.indexWhere((t) => t.id == trackerId);
      if (i < 0) return;
      if (index < 0 || index >= list[i].entries.length) return;

      final entryId = list[i].entries[index].id;
      if (entryId == null) return;

      await _repository.deleteEntry(trackerId, entryId);
      list[i].entries.removeAt(index);
      state = list;
    } catch (e) {
      print('Error deleting entry: $e');
      rethrow;
    }
  }

  Future<void> _load() async {
    try {
      final trackers = await _repository.getTrackers();
      // ensure newest-first for entries
      for (final t in trackers) {
        t.entries.sort((a, b) => b.date.compareTo(a.date));
      }
      state = trackers;
    } catch (e) {
      print('Error loading trackers: $e');
      // Keep empty state on error
      state = const [];
    }
  }

  /// Refresh trackers from server
  Future<void> refresh() async {
    await _load();
  }
}
