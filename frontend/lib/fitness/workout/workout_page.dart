import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../routine/custom_routines_page.dart';
import '../state/routines_provider.dart';
import '../models/routine_models.dart';

class WorkoutPage extends ConsumerStatefulWidget {
  const WorkoutPage({super.key});

  @override
  ConsumerState<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends ConsumerState<WorkoutPage> {
  String? _selectedRoutineId;
  int _selectedDayIdx = 0;
  DateTime _selectedDate = DateTime.now();              // 👈 date state

  final Map<String, List<LoggedSet>> _logged = {};      // exercise key -> sets

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routines = ref.read(routinesProvider);
    final notifier = ref.read(routinesProvider.notifier);

    _selectedRoutineId ??=
        notifier.currentRoutineId ?? (routines.isNotEmpty ? routines.first.id : null);
    if (notifier.currentRoutineId == null && _selectedRoutineId != null) {
      notifier.setCurrent(_selectedRoutineId!);
    }
  }

  String _formatDate(DateTime d) =>
      MaterialLocalizations.of(context).formatFullDate(d); // no intl dep

  @override
  Widget build(BuildContext context) {
    final routines = ref.watch(routinesProvider);
    final notifier = ref.read(routinesProvider.notifier);

    if (routines.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout')),
        body: Center(
          child: FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CustomRoutinesPage()),
            ),
            child: const Text('Create a routine first'),
          ),
        ),
      );
    }

    final selected = routines.firstWhere(
      (r) => r.id == (_selectedRoutineId ?? notifier.currentRoutineId),
      orElse: () => routines.first,
    );

    final days = selected.dayPlans.where((d) => d.exercises.isNotEmpty).toList();
    if (days.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout')),
        body: const Center(child: Text('Your routine has no exercises yet.')),
      );
    }
    final currentDay = days[_selectedDayIdx];

    return Scaffold(
      appBar: AppBar(title: const Text("Log Today's workout")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Date picker
          Row(
            children: [
              Text('Workout date:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.event),
                label: Text(_formatDate(_selectedDate)),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Routine picker if > 1
          if (routines.length > 1) ...[
            Text('Pick your current routine', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selected.id,
              items: routines
                  .map((r) => DropdownMenuItem(
                        value: r.id,
                        child: Text(r.title.isEmpty ? '(Untitled)' : r.title),
                      ))
                  .toList(),
              onChanged: (id) {
                if (id == null) return;
                setState(() {
                  _selectedRoutineId = id;
                  _selectedDayIdx = 0;
                  _logged.clear();
                });
                notifier.setCurrent(id);
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
          ],

          Text('Which day are you training?', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(days.length, (i) {
                final selectedChip = i == _selectedDayIdx;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(days[i].label),
                    selected: selectedChip,
                    onSelected: (_) => setState(() {
                      _selectedDayIdx = i;
                      _logged.clear(); // reset log for new day
                    }),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),
          Text('${currentDay.label} — Exercises', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          ...List.generate(currentDay.exercises.length, (i) {
            final ex = currentDay.exercises[i];
            final key = '${currentDay.label}::$i';
            final sets = _logged[key] ?? [];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ex.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Target: ${ex.sets} sets • ${ex.minReps}-${ex.maxReps} reps'),
                    const SizedBox(height: 8),

                    if (sets.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Logged sets:'),
                          const SizedBox(height: 6),
                          ...List.generate(sets.length, (idx) {
                            final s = sets[idx];
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Text('#${idx + 1}'),
                              title: Text('Weight: ${s.weight}  •  Reps: ${s.reps}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => setState(() => _logged[key]!.removeAt(idx)),
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                        ],
                      ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _addSetDialog(key),
                        icon: const Icon(Icons.add),
                        label: const Text('Add set'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _finishWorkoutDialog(
              routineTitle: selected.title.isEmpty ? '(Untitled)' : selected.title,
              dayLabel: currentDay.label,
            ),
            icon: const Icon(Icons.check),
            label: const Text('Finish Workout'),
          ),
        ],
      ),
    );
  }

  Future<void> _addSetDialog(String key) async {
    final weightCtrl = TextEditingController();
    final repsCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.55,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Text('Add Set', style: Theme.of(context).textTheme.titleLarge)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: weightCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Weight'),
                    validator: (v) => (double.tryParse(v ?? '') != null) ? null : 'Enter weight',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: repsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Reps'),
                    validator: (v) => (int.tryParse(v ?? '') != null) ? null : 'Enter reps',
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        final set = LoggedSet(
                          weight: double.parse(weightCtrl.text),
                          reps: int.parse(repsCtrl.text),
                        );
                        setState(() => _logged.putIfAbsent(key, () => []).add(set));
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Add'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Build and show the readable log with date on top
  void _finishWorkoutDialog({required String routineTitle, required String dayLabel}) {
    final lines = <String>[];
    lines.add('Date: ${_formatDate(_selectedDate)}');     // 👈 date at top
    lines.add('Routine: $routineTitle');
    lines.add('Day: $dayLabel');
    lines.add('');

    if (_logged.isEmpty) {
      lines.add('(No sets logged)');
    } else {
      // group by exercise order key
      final keys = _logged.keys.toList()..sort();
      for (final key in keys) {
        final idx = int.tryParse(key.split('::').last) ?? 0;
        final sets = _logged[key]!;
        lines.add('Exercise ${idx + 1}:');
        for (var i = 0; i < sets.length; i++) {
          final s = sets[i];
          lines.add('  • Set ${i + 1}: ${s.weight} x ${s.reps}');
        }
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Workout Logged'),
        content: SingleChildScrollView(child: Text(lines.join('\n'))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}

class LoggedSet {
  final double weight;
  final int reps;
  LoggedSet({required this.weight, required this.reps});
}
