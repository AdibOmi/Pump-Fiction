import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../journal/domain/journal_providers.dart';
import '../../../journal/domain/journal_models.dart';
import 'journal_session_detail_page.dart';

class JournalSessionsPage extends ConsumerWidget {
  const JournalSessionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(journalSessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (sessions) => sessions.isEmpty
            ? _EmptyState(onCreate: () => _showCreateDialog(context, ref))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: sessions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final s = sessions[i];
                  return _SessionTile(session: s);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Journal Session'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'e.g., Winter Bulk, Summer Cut, Prep Week',
              labelText: 'Session name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (name != null && name.isNotEmpty) {
      await ref.read(journalSessionsProvider.notifier).addSession(name);
    }
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});
  final JournalSession session;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: Theme.of(context).colorScheme.surface,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: session.coverImageBase64 == null
            ? Container(
                width: 56,
                height: 56,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.image_not_supported_outlined),
              )
            : Image.memory(
                _decodeDataUri(session.coverImageBase64!),
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              ),
      ),
      title: Text(
        session.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        'Created ${session.createdAt.toLocal().toString().split(".").first}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => JournalSessionDetailPage(session: session),
          ),
        );
      },
    );
  }

  static Uint8List _decodeDataUri(String dataUri) {
    final comma = dataUri.indexOf(',');
    final b64 = comma >= 0 ? dataUri.substring(comma + 1) : dataUri;
    return base64Decode(b64);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.book_outlined, size: 64),
          const SizedBox(height: 12),
          const Text('No journal sessions yet'),
          const SizedBox(height: 8),
          const Text('Track your cut, bulk, or competition prep'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Create your first session'),
          ),
        ],
      ),
    );
  }
}
