import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../routine/custom_routines_page.dart';
import '../state/routines_provider.dart';
import '../state/workout_logs_provider.dart';
import '../models/routine_models.dart';
import '../models/workout_log.dart';

class WorkoutPage extends ConsumerStatefulWidget {
  const WorkoutPage({super.key});

  @override
  ConsumerState<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends ConsumerState<WorkoutPage> {
  String? _selectedRoutineId;
  int _selectedDayIdx = 0;
  DateTime _selectedDate = DateTime.now();

  // in-session log: exercise key -> sets
  final Map<String, List<LoggedSet>> _logged = {};
  // additional exercises for current day
  final List<Exercise> _additional = [];

  String _formatDate(DateTime d) =>
      MaterialLocalizations.of(context).formatFullDate(d);

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

  @override
  Widget build(BuildContext context) {
    print('💪 WorkoutPage: Building workout page...');
    final routines = ref.watch(routinesProvider);
    print('💪 WorkoutPage: Routines loaded: ${routines.length}');

    final notifier = ref.read(routinesProvider.notifier);
    final allLogs = ref.watch(workoutLogsProvider);

    if (routines.isEmpty) {
      print('💪 WorkoutPage: No routines found!');
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

    // Find the selected routine, or default to first routine with exercises
    var selected = routines.firstWhere(
      (r) => r.id == (_selectedRoutineId ?? notifier.currentRoutineId),
      orElse: () => routines.first,
    );

    // Check if selected routine has exercises, if not find one that does
    var selectedDays = selected.dayPlans.where((d) => d.exercises.isNotEmpty).toList();

    if (selectedDays.isEmpty) {
      print('💪 WorkoutPage: Selected routine "${selected.title}" has no exercises, finding one with exercises...');

      // Find first routine with exercises
      try {
        selected = routines.firstWhere(
          (r) => r.dayPlans.any((d) => d.exercises.isNotEmpty),
        );
        print('💪 WorkoutPage: Found routine with exercises: ${selected.title}');

        // Update the selected routine ID
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _selectedRoutineId = selected.id;
          });
          notifier.setCurrent(selected.id);
        });
      } catch (e) {
        // No routines with exercises found
        print('💪 WorkoutPage: No routines with exercises found!');
        return Scaffold(
          appBar: AppBar(title: const Text('Workout')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'All your routines are empty.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CustomRoutinesPage()),
                  ),
                  child: const Text('Add exercises to a routine'),
                ),
              ],
            ),
          ),
        );
      }
    }

    print('💪 WorkoutPage: Selected routine: ${selected.title}');
    print('💪 WorkoutPage: Total day plans in routine: ${selected.dayPlans.length}');

    for (var i = 0; i < selected.dayPlans.length; i++) {
      print('💪   Day ${i}: ${selected.dayPlans[i].label} - ${selected.dayPlans[i].exercises.length} exercises');
    }

    final days = selected.dayPlans.where((d) => d.exercises.isNotEmpty).toList();
    print('💪 WorkoutPage: Days with exercises: ${days.length}');
    print('💪 WorkoutPage: Showing workout UI with ${days.length} days');
    final currentDay = days[_selectedDayIdx];

    // FILTER: show only logs for the currently selected day
    final logsForSelectedDay =
        allLogs.where((l) => l.dayLabel == currentDay.label).toList();

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
                  _additional.clear();
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
                      _logged.clear();
                      _additional.clear();
                    }),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),
          Text('${currentDay.label} — Exercises', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          // Routine exercises
          ..._exerciseCards(currentDay.exercises, prefix: currentDay.label),

          // Additional exercises
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Additional exercises', style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                onPressed: _addAdditionalExerciseDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          if (_additional.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Optional: add movements not in your routine (warm-ups, accessories, etc.)',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(.7),
                ),
              ),
            )
          else
            ..._exerciseCards(_additional, prefix: 'additional'),

          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _finishWorkout(
              routineTitle: selected.title.isEmpty ? '(Untitled)' : selected.title,
              dayLabel: currentDay.label,
              dayExercises: currentDay.exercises, // pass to use real names
            ),
            icon: const Icon(Icons.check),
            label: const Text('Finish Workout'),
          ),

          // Recent workouts — filtered by selected day
          const SizedBox(height: 24),
          Text('Recent Workouts', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (logsForSelectedDay.isEmpty)
            Text('No workouts logged for ${currentDay.label} yet.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(.7),
                ))
          else
            ...logsForSelectedDay.map(
              (log) => _WorkoutLogCard(
                log: log,
                formatDate: _formatDate,
                onEdit: () => _editLog(log),
                onDelete: () => ref.read(workoutLogsProvider.notifier).remove(log.id),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<Widget> _exerciseCards(List<Exercise> exercises, {required String prefix}) {
    final isAdditional = prefix == 'additional';

    return List.generate(exercises.length, (i) {
      final ex = exercises[i];
      final key = '$prefix::$i';
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
              if (!isAdditional)
                Text('Target: ${ex.sets} sets • ${ex.minReps}-${ex.maxReps} reps'),
              if (!isAdditional) const SizedBox(height: 8),

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
    });
  }

  Future<void> _addAdditionalExerciseDialog() async {
    final nameCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    final repsCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Additional Exercise'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Exercise name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: weightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Weight'),
                      validator: (v) => (double.tryParse(v ?? '') != null) ? null : 'Enter weight',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: repsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Reps'),
                      validator: (v) => (int.tryParse(v ?? '') != null) ? null : 'Enter reps',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;

              final name = nameCtrl.text.trim();
              final weight = double.parse(weightCtrl.text);
              final reps = int.parse(repsCtrl.text);

              setState(() {
                _additional.add(Exercise(
                  name: name,
                  sets: 1,
                  minReps: reps,
                  maxReps: reps,
                ));
                final idx = _additional.length - 1;
                final key = 'additional::$idx';
                _logged[key] = [LoggedSet(weight: weight, reps: reps)];
              });

              Navigator.pop(context);
            },
            child: const Text('Add'),
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

  Future<void> _finishWorkout({
    required String routineTitle,
    required String dayLabel,
    required List<Exercise> dayExercises, // to use real names
  }) async {
    // Build logged exercises with proper names
    final List<LoggedExercise> loggedExercises = [];
    final allKeys = _logged.keys.toList()..sort();

    for (final k in allKeys) {
      String name;
      if (k.startsWith('additional')) {
        final idx = int.parse(k.split('::').last);
        name = _additional[idx].name;
      } else {
        final idx = int.parse(k.split('::').last);
        name = (idx >= 0 && idx < dayExercises.length)
            ? dayExercises[idx].name
            : 'Exercise ${idx + 1}';
      }
      loggedExercises.add(
        LoggedExercise(name: name, sets: List.of(_logged[k]!)),
      );
    }

    // Persist
    final log = WorkoutLog(
      date: _selectedDate,
      routineTitle: routineTitle,
      dayLabel: dayLabel,
      exercises: loggedExercises,
    );
    await ref.read(workoutLogsProvider.notifier).add(log);

    // Reset inputs for this day
    setState(() {
      _logged.clear();
      _additional.clear();
    });

    // Show summary
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Workout Logged'),
        content: SingleChildScrollView(
          child: Text(_readableLog(log)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  String _readableLog(WorkoutLog log) {
    final lines = <String>[];
    lines.add('Date: ${_formatDate(log.date)}');
    lines.add('');
    for (final e in log.exercises) {
      lines.add(e.name + ':');
      for (var i = 0; i < e.sets.length; i++) {
        final s = e.sets[i];
        lines.add('  • Set ${i + 1}: ${s.weight} x ${s.reps}');
      }
    }
    return lines.join('\n');
  }

  Future<void> _editLog(WorkoutLog log) async {
    // Build controllers for each set
    final controllers = <TextEditingController>[];
    for (final e in log.exercises) {
      for (final s in e.sets) {
        controllers.add(TextEditingController(text: s.weight.toString()));
        controllers.add(TextEditingController(text: s.reps.toString()));
      }
    }

    await showDialog(
      context: context,
      builder: (_) {
        int cIndex = 0;
        return AlertDialog(
          title: Text('Edit • ${_formatDate(log.date)}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final e in log.exercises) ...[
                  Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  ...e.sets.asMap().entries.map((entry) {
                    final i = entry.key;
                    final weightCtrl = controllers[cIndex++];
                    final repsCtrl = controllers[cIndex++];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          SizedBox(width: 56, child: Text('Set ${i + 1}:')),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: weightCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Weight'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: repsCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Reps'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                // rebuild the log from controllers
                int idx = 0;
                final newExercises = <LoggedExercise>[];
                for (final e in log.exercises) {
                  final sets = <LoggedSet>[];
                  for (var i = 0; i < e.sets.length; i++) {
                    final w = double.tryParse(controllers[idx++].text) ?? e.sets[i].weight;
                    final r = int.tryParse(controllers[idx++].text) ?? e.sets[i].reps;
                    sets.add(LoggedSet(weight: w, reps: r));
                  }
                  newExercises.add(LoggedExercise(name: e.name, sets: sets));
                }
                final updated = WorkoutLog(
                  id: log.id,
                  date: log.date,
                  routineTitle: log.routineTitle,
                  dayLabel: log.dayLabel,
                  exercises: newExercises,
                );
                await ref.read(workoutLogsProvider.notifier).update(updated);
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _WorkoutLogCard extends StatelessWidget {
  const _WorkoutLogCard({
    required this.log,
    required this.formatDate,
    required this.onEdit,
    required this.onDelete,
  });

  final WorkoutLog log;
  final String Function(DateTime) formatDate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date on top only
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    formatDate(log.date),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Edit',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 20),
                      tooltip: 'Delete',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Full workout (exercise + sets)
            ...log.exercises.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      ...e.sets.asMap().entries.map((entry) {
                        final i = entry.key;
                        final s = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(left: 12, bottom: 2),
                          child: Text('• Set ${i + 1}:  Weight ${s.weight}   Reps ${s.reps}'),
                        );
                      }),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
