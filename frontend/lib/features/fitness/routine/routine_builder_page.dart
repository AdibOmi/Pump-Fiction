import 'package:flutter/material.dart';
import '../models/routine_models.dart';
import '../../../l10n/app_localizations.dart';

class RoutineBuilderPage extends StatefulWidget {
  const RoutineBuilderPage({super.key, this.initial});
  final RoutinePlan? initial;

  @override
  State<RoutineBuilderPage> createState() => _RoutineBuilderPageState();
}

class _RoutineBuilderPageState extends State<RoutineBuilderPage> {
  final _titleCtrl = TextEditingController();

  PlanMode _mode = PlanMode.weekly;
  int _nDays = 3;
  int _selectedDayIndex = 0;

  late RoutinePlan _plan;

  List<String> _getWeeklyLabels() {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.saturday,
      l10n.sunday,
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
    ];
  }

  String _getLocalizedDayLabel(int gIdx) {
    final originalLabel = _plan.dayPlans[gIdx].label;

    // If it's a weekly day (index 0-6), return localized version
    if (gIdx < 7) {
      final weeklyLabels = _getWeeklyLabels();
      return weeklyLabels[gIdx];
    }

    // For numbered days (Day 1, Day 2, etc.), keep the original or could localize "Day"
    return originalLabel;
  }

  @override
  void initState() {
    super.initState();
    // Initialize with default English labels, will be updated in build method
    final baseDays = [
      ...[
        'Sat',
        'Sun',
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
      ].map((l) => DayPlan(label: l, exercises: [])),
      ...List.generate(7, (i) => DayPlan(label: 'Day ${i + 1}', exercises: [])),
    ];

    if (widget.initial != null) {
      _plan = widget.initial!;
      _mode = _plan.mode;
      _titleCtrl.text = _plan.title;
      // ensure enough days
      if (_plan.dayPlans.length < baseDays.length) {
        _plan = _plan.copyWith(
          dayPlans: [
            ..._plan.dayPlans,
            ...baseDays.skip(_plan.dayPlans.length),
          ],
        );
      }
      // set nDays guess from labels if editing a number-of-days plan
      if (_mode == PlanMode.nDays) {
        _nDays = _plan.dayPlans
            .where((d) => d.label.toLowerCase().startsWith('day '))
            .length;
        if (_nDays == 0) _nDays = 3;
      }
    } else {
      _plan = RoutinePlan(title: '', mode: _mode, dayPlans: baseDays);
    }
  }

  List<DayPlan> get _visibleDays {
    if (_mode == PlanMode.weekly) return _plan.dayPlans.take(7).toList();
    return _plan.dayPlans.skip(7).take(_nDays).toList();
  }

  void _rebuildDaysForMode() {
    // adjust selected index within bounds
    if (_selectedDayIndex >= _visibleDays.length) _selectedDayIndex = 0;
    setState(() {});
  }

  Future<void> _renameDayDialog(int globalIdx) async {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController(text: _plan.dayPlans[globalIdx].label);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.renameDay),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(labelText: l10n.dayName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              _plan.dayPlans[globalIdx] = _plan.dayPlans[globalIdx].copyWith(
                label: ctrl.text.trim(),
              );
              setState(() {});
              Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _addExerciseDialog(DayPlan day) async {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    final setsCtrl = TextEditingController();
    final minCtrl = TextEditingController();
    final maxCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Form(
              key: formKey,
              child: ListView(
                children: [
                  Center(
                    child: Text(
                      l10n.addExercise,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.exerciseName,
                      hintText: 'e.g., Barbell Bench Press',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? l10n.required : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: setsCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: l10n.sets),
                          validator: (v) => (int.tryParse(v ?? '') ?? 0) > 0
                              ? null
                              : l10n.enterSets,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: minCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: l10n.minReps),
                          validator: (v) => (int.tryParse(v ?? '') ?? 0) > 0
                              ? null
                              : l10n.enterMin,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: maxCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: l10n.maxReps),
                          validator: (v) {
                            final max = int.tryParse(v ?? '');
                            final min = int.tryParse(minCtrl.text);
                            if (max == null || max <= 0) return l10n.enterMax;
                            if (min != null && max < min)
                              return l10n.maxMustBeGreaterThanMin;
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: const Icon(Icons.check),
                    label: Text(l10n.addExercise),
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      final ex = Exercise(
                        name: nameCtrl.text.trim(),
                        sets: int.parse(setsCtrl.text),
                        minReps: int.parse(minCtrl.text),
                        maxReps: int.parse(maxCtrl.text),
                      );
                      final idx = _plan.dayPlans.indexOf(day);
                      _plan.dayPlans[idx].exercises.add(ex);
                      setState(() {});
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _saveRoutineAndClose() {
    final plan = _plan.copyWith(title: _titleCtrl.text.trim(), mode: _mode);
    // ✅ Return the plan to previous screen & close
    Navigator.pop(context, plan);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final days = _visibleDays;
    final globalBase = _mode == PlanMode.weekly ? 0 : 7;
    final currentDay = days[_selectedDayIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createRoutine),
        actions: [
          TextButton(
            onPressed: _saveRoutineAndClose,
            child: Text(l10n.saveRoutine),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              labelText: l10n.routineTitle,
              hintText: 'e.g., Push Pull Legs Strength',
            ),
          ),
          const SizedBox(height: 16),

          // Mode selector
          Text(l10n.planType, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<PlanMode>(
            segments: [
              ButtonSegment(value: PlanMode.weekly, label: Text(l10n.weekly)),
              ButtonSegment(
                value: PlanMode.nDays,
                label: Text(l10n.numberOfDays),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (s) {
              _mode = s.first;
              _rebuildDaysForMode();
            },
          ),
          const SizedBox(height: 12),

          if (_mode == PlanMode.nDays) ...[
            TextFormField(
              initialValue: '$_nDays',
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.howManyDaysIsYourProgram,
              ),
              onChanged: (v) {
                final n = int.tryParse(v) ?? _nDays;
                _nDays = n.clamp(1, 14);
                _rebuildDaysForMode();
              },
            ),
            const SizedBox(height: 8),
          ],

          // Editable day chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(days.length, (i) {
                final selected = i == _selectedDayIndex;
                final gIdx = globalBase + i;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InputChip(
                    selected: selected,
                    label: Text(_getLocalizedDayLabel(gIdx)),
                    onPressed: () => setState(() => _selectedDayIndex = i),
                    onDeleted: () => _renameDayDialog(gIdx),
                    deleteIcon: const Icon(Icons.edit, size: 18),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          // Exercises of selected day
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_getLocalizedDayLabel(globalBase + _selectedDayIndex)} ${l10n.exercises}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton.icon(
                onPressed: () => _addExerciseDialog(currentDay),
                icon: const Icon(Icons.add),
                label: Text(l10n.addExerciseButton),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (currentDay.exercises.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(.4),
              ),
              child: Text(l10n.noExercisesYetTapAddExerciseToStart),
            )
          else
            Column(
              children: [
                for (int i = 0; i < currentDay.exercises.length; i++)
                  _ExerciseTile(
                    exercise: currentDay.exercises[i],
                    onDelete: () {
                      currentDay.exercises.removeAt(i);
                      setState(() {});
                    },
                  ),
              ],
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.exercise, required this.onDelete});
  final Exercise exercise;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(exercise.name),
        subtitle: Text(
          'Sets: ${exercise.sets}   Reps: ${exercise.minReps}-${exercise.maxReps}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
