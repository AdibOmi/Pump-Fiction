import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
// Local file saving removed; images are uploaded to backend.

import '../../../journal/domain/journal_models.dart';
import '../../../journal/domain/journal_providers.dart';
import '../widgets/poster_card.dart';

class JournalSessionDetailPage extends ConsumerWidget {
  const JournalSessionDetailPage({super.key, required this.session});
  final JournalSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalEntriesProvider(session.id));

    return Scaffold(
      appBar: AppBar(title: Text(session.name)),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (entries) => entries.isEmpty
            ? _EmptyEntries(onAdd: () => _addEntry(context, ref))
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.65,
                ),
                itemCount: entries.length,
                itemBuilder: (context, i) {
                  final e = entries[i];
                  return PosterCard(
                    imagePath: e.imagePath,
                    title: _formatDate(e.date),
                    weight: e.weight,
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addEntry(context, ref),
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Future<void> _addEntry(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    // Ask for weight
    final weight = await _askForWeight(context);

    // Send to backend
    final repo = ref.read(journalRepositoryProvider);
    await repo.addEntry(
      sessionId: session.id,
      file: File(picked.path),
      weight: weight,
    );
    // refresh
    ref.invalidate(journalEntriesProvider(session.id));
  }

  Future<double?> _askForWeight(BuildContext context) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter weight (kg)'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: 'e.g., 82.5'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (value == null || value.isEmpty) return null;
    final parsed = double.tryParse(value);
    return parsed;
  }

  String _formatDate(DateTime d) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _EmptyEntries extends StatelessWidget {
  const _EmptyEntries({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.photo_size_select_actual_outlined, size: 64),
          const SizedBox(height: 12),
          const Text('No entries yet'),
          const SizedBox(height: 8),
          const Text('Add today\'s photo and weight to track progress'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Add Entry'),
          ),
        ],
      ),
    );
  }
}
