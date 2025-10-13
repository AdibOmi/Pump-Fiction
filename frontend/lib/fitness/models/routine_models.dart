import 'package:flutter/foundation.dart';

enum PlanMode { weekly, nDays }

class Exercise {
  final String name;
  final int sets;
  final int minReps;
  final int maxReps;

  Exercise({
    required this.name,
    required this.sets,
    required this.minReps,
    required this.maxReps,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'sets': sets,
        'reps': '$minReps-$maxReps',
      };
}

class DayPlan {
  final String label; // e.g., Sat, Sun, Day 1, Day 2
  final List<Exercise> exercises;

  DayPlan({required this.label, required List<Exercise> exercises})
      : exercises = List.of(exercises);

  DayPlan copyWith({String? label, List<Exercise>? exercises}) => DayPlan(
        label: label ?? this.label,
        exercises: exercises ?? List.of(this.exercises),
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };
}

class RoutinePlan {
  final String title;
  final PlanMode mode;
  final List<DayPlan> dayPlans;

  RoutinePlan({
    required this.title,
    required this.mode,
    required List<DayPlan> dayPlans,
  }) : dayPlans = List.of(dayPlans);

  RoutinePlan copyWith({
    String? title,
    PlanMode? mode,
    List<DayPlan>? dayPlans,
  }) =>
      RoutinePlan(
        title: title ?? this.title,
        mode: mode ?? this.mode,
        dayPlans: dayPlans ?? List.of(this.dayPlans),
      );

  String prettyPrint() {
    final buffer = StringBuffer();
    buffer.writeln('Title: $title');
    buffer.writeln('Mode: ${describeEnum(mode)}');
    for (final day in dayPlans.where((d) => d.exercises.isNotEmpty)) {
      buffer.writeln('- ${day.label}');
      for (final ex in day.exercises) {
        buffer.writeln('   • ${ex.name} — ${ex.sets} sets, ${ex.minReps}-${ex.maxReps} reps');
      }
    }
    return buffer.toString();
  }
}
