import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/journal_repository.dart';
import 'journal_models.dart';

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository();
});

final journalSessionsProvider =
    StateNotifierProvider<
      JournalSessionsNotifier,
      AsyncValue<List<JournalSession>>
    >((ref) {
      return JournalSessionsNotifier(ref);
    });

class JournalSessionsNotifier
    extends StateNotifier<AsyncValue<List<JournalSession>>> {
  JournalSessionsNotifier(this.ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref ref;

  Future<void> _load() async {
    try {
      final list = await ref.read(journalRepositoryProvider).getSessions();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addSession(String name) async {
    final created = await ref
        .read(journalRepositoryProvider)
        .createSession(name);
    final current = state.value ?? [];
    state = AsyncValue.data([created, ...current]);
  }
}

final journalEntriesProvider =
    FutureProvider.family<List<JournalEntry>, String>((ref, sessionId) async {
      return ref.read(journalRepositoryProvider).getEntries(sessionId);
    });

final journalEntriesControllerProvider =
    Provider.family<JournalEntriesController, String>((ref, sessionId) {
      return JournalEntriesController(ref, sessionId);
    });

class JournalEntriesController {
  final Ref ref;
  final String sessionId;
  JournalEntriesController(this.ref, this.sessionId);

  Future<void> addEntry(JournalEntry entry) async {
    // With backend API, creation is handled in repository; caller should refresh provider.
  }
}
