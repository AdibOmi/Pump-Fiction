import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tracker_provider.dart';
import 'tracker_models.dart';
import '../../../screens/tracker_detail_screen.dart';

class TrackersPage extends ConsumerWidget {
  const TrackersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackers = ref.watch(trackersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Trackers')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => _addOrEditTracker(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add tracker'),
            ),
          ),
          const SizedBox(height: 12),
          if (trackers.isEmpty)
            Text(
              'No trackers yet. Add one to get started.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.7),
              ),
            )
          else
            ...trackers.map((t) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.track_changes),
                    title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text([
                      'Unit: ${t.unit}',
                      if (t.goal != null) 'Goal: ${t.goal}',
                      if (t.entries.isNotEmpty)
                        'Last: ${t.entries.first.value} on ${_fmtDate(t.entries.first.date)}',
                    ].join('  •  ')),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit),
                          onPressed: () => _addOrEditTracker(context, ref, tracker: t),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => ref.read(trackersProvider.notifier).deleteTracker(t.id),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TrackerDetailScreen(trackerId: t.id)),
                      );
                    },
                  ),
                )),
        ],
      ),
    );
  }

  Future<void> _addOrEditTracker(BuildContext context, WidgetRef ref, {Tracker? tracker}) async {
    final isEdit = tracker != null;
    final nameCtrl = TextEditingController(text: tracker?.name ?? '');
    final unitCtrl = TextEditingController(text: tracker?.unit ?? '');
    final goalCtrl = TextEditingController(text: tracker?.goal?.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Tracker' : 'Add Tracker'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Tracker Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: unitCtrl,
                decoration: const InputDecoration(labelText: 'Unit (e.g. kg, bpm)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: goalCtrl,
                decoration: const InputDecoration(labelText: 'Goal (optional)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final name = nameCtrl.text.trim();
              final unit = unitCtrl.text.trim();
              final goal = (goalCtrl.text.trim().isEmpty) ? null : double.tryParse(goalCtrl.text.trim());

              try {
                if (isEdit) {
                  final updated = Tracker(
                    id: tracker!.id,
                    name: name,
                    unit: unit,
                    goal: goal,
                    entries: tracker.entries,
                  );
                  await ref.read(trackersProvider.notifier).updateTracker(updated);
                } else {
                  await ref.read(trackersProvider.notifier).addTracker(
                        name: name,
                        unit: unit,
                        goal: goal,
                      );
                }
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              } catch (e) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(isEdit ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
