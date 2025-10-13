import 'package:flutter/material.dart';
import '../models/routine_models.dart';
import 'routine_builder_page.dart';

class CustomRoutinesPage extends StatefulWidget {
  const CustomRoutinesPage({super.key});

  @override
  State<CustomRoutinesPage> createState() => _CustomRoutinesPageState();
}

class _CustomRoutinesPageState extends State<CustomRoutinesPage> {
  final List<RoutinePlan> _routines = [];

  Future<void> _createRoutine() async {
    final result = await Navigator.of(context).push<RoutinePlan>(
      MaterialPageRoute(builder: (_) => const RoutineBuilderPage()),
    );
    if (result != null) {
      setState(() => _routines.add(result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Routine saved')),
      );
    }
  }

  Future<void> _editRoutine(int index) async {
    final result = await Navigator.of(context).push<RoutinePlan>(
      MaterialPageRoute(builder: (_) => RoutineBuilderPage(initial: _routines[index])),
    );
    if (result != null) {
      setState(() => _routines[index] = result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Routine updated')),
      );
    }
  }

  void _deleteRoutine(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete routine?'),
        content: Text('This will remove "${_routines[index].title}".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _routines.removeAt(index));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Routine deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Programs')),
      body: _routines.isEmpty
          ? Center(
              child: FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Text('Add New Routine', style: TextStyle(fontSize: 16)),
                ),
                onPressed: _createRoutine,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _routines.length,
              itemBuilder: (context, i) => _RoutineCard(
                plan: _routines[i],
                onEdit: () => _editRoutine(i),
                onDelete: () => _deleteRoutine(i),
              ),
            ),
      floatingActionButton: _routines.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _createRoutine,
              icon: const Icon(Icons.add),
              label: const Text('Add Routine'),
            ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.plan, required this.onEdit, required this.onDelete});
  final RoutinePlan plan;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    // Build a readable summary WITHOUT mode
    final summary = StringBuffer()
      ..writeln('Title: ${plan.title.trim().isEmpty ? '(Untitled)' : plan.title}');
    for (final day in plan.dayPlans.where((d) => d.exercises.isNotEmpty)) {
      summary.writeln('- ${day.label}');
      for (final ex in day.exercises) {
        summary.writeln('  • ${ex.name} — ${ex.sets} sets, ${ex.minReps}-${ex.maxReps} reps');
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.title.trim().isEmpty ? '(Untitled)' : plan.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              summary.toString(),
              style: TextStyle(
                height: 1.35,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.8),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
