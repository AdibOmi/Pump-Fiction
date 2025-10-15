import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/workout_logs_provider.dart';
import '../state/routines_provider.dart';
import '../models/workout_log.dart';
import '../models/routine_models.dart';
// screen lives under lib/screens/
import '../../screens/exercise_progress_screen.dart';

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(workoutLogsProvider);
    final routines = ref.watch(routinesProvider);

    // Build the allow-list of exercise names from ALL saved routines
    final allowed = <String>{};
    for (final RoutinePlan r in routines) {
      for (final d in r.dayPlans) {
        for (final ex in d.exercises) {
          final n = ex.name.trim();
          if (n.isNotEmpty) allowed.add(n.toLowerCase());
        }
      }
    }

    // Only show exercises that are BOTH logged and present in routines
    final names = <String>{};
    for (final WorkoutLog l in logs) {
      for (final e in l.exercises) {
        final n = e.name.trim();
        if (n.isEmpty) continue;
        if (allowed.contains(n.toLowerCase())) {
          names.add(n);
        }
      }
    }

    final sortedNames = names.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: sortedNames.isEmpty
          ? Center(
              child: Text(
                routines.isEmpty
                    ? 'No routines found.\nCreate a routine to track progress.'
                    : 'No matching logs yet.\nLog workouts for exercises in your routines to see progress.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(.7),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sortedNames.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final name = sortedNames[i];
                return Card(
                  child: ListTile(
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Tap to view progress (set-weighted score)'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ExerciseProgressScreen(exerciseName: name),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
