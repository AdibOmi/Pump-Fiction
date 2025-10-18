import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tracker_models.dart';

final trackersProvider =
    StateNotifierProvider<TrackersNotifier, List<Tracker>>(
  (ref) => TrackersNotifier(),
);

class TrackersNotifier extends StateNotifier<List<Tracker>> {
  TrackersNotifier() : super(const []) {
    _load();
  }

  static const _kKey = 'custom_trackers_v1';

  Future<void> addTracker({
    required String name,
    required String unit,
    double? goal,
  }) async {
    final t = Tracker(
      id: _makeId(),
      name: name,
      unit: unit,
      goal: goal,
      entries: [],
    );
    state = [t, ...state];
    await _persist();
  }

  Future<void> updateTracker(Tracker updated) async {
    state = [
      for (final t in state) if (t.id == updated.id) updated else t,
    ];
    await _persist();
  }

  Future<void> deleteTracker(String id) async {
    state = [for (final t in state) if (t.id != id) t];
    await _persist();
  }

  Future<void> addEntry(String trackerId, TrackerEntry entry) async {
    final list = [...state];
    final i = list.indexWhere((t) => t.id == trackerId);
    if (i < 0) return;
    list[i].entries.add(entry);
    list[i].entries.sort((a, b) => b.date.compareTo(a.date)); // newest first
    state = list;
    await _persist();
  }

  Future<void> updateEntry(
    String trackerId,
    int index,
    TrackerEntry entry,
  ) async {
    final list = [...state];
    final i = list.indexWhere((t) => t.id == trackerId);
    if (i < 0) return;
    if (index < 0 || index >= list[i].entries.length) return;
    list[i].entries[index] = entry;
    list[i].entries.sort((a, b) => b.date.compareTo(a.date));
    state = list;
    await _persist();
  }

  Future<void> deleteEntry(String trackerId, int index) async {
    final list = [...state];
    final i = list.indexWhere((t) => t.id == trackerId);
    if (i < 0) return;
    if (index < 0 || index >= list[i].entries.length) return;
    list[i].entries.removeAt(index);
    state = list;
    await _persist();
  }

  Future<void> clearAll() async {
    state = const [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, Tracker.encodeList(state));
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null) return;
    final list = Tracker.decodeList(raw);
    // ensure newest-first for entries
    for (final t in list) {
      t.entries.sort((a, b) => b.date.compareTo(a.date));
    }
    state = list;
  }

  String _makeId() {
    final d = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    String six(int n) => n.toString().padLeft(6, '0');
    return 'trk_${d.year}-${two(d.month)}-${two(d.day)}_${two(d.hour)}${two(d.minute)}${two(d.second)}_${six(d.microsecond)}';
  }
}
