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
        'minReps': minReps,
        'maxReps': maxReps,
      };

  factory Exercise.fromJson(Map<String, dynamic> j) => Exercise(
        name: j['name'] as String,
        sets: j['sets'] as int,
        minReps: j['minReps'] as int,
        maxReps: j['maxReps'] as int,
      );
}

class DayPlan {
  final String label; // e.g., Sat / Day 1 / Push
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

  factory DayPlan.fromJson(Map<String, dynamic> j) => DayPlan(
        label: j['label'] as String,
        exercises: (j['exercises'] as List<dynamic>)
            .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class RoutinePlan {
  final String id;
  final String title;
  final PlanMode mode;
  final List<DayPlan> dayPlans;

  RoutinePlan({
    String? id,
    required this.title,
    required this.mode,
    required List<DayPlan> dayPlans,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        dayPlans = List.of(dayPlans);

  RoutinePlan copyWith({
    String? id,
    String? title,
    PlanMode? mode,
    List<DayPlan>? dayPlans,
  }) =>
      RoutinePlan(
        id: id ?? this.id,
        title: title ?? this.title,
        mode: mode ?? this.mode,
        dayPlans: dayPlans ?? List.of(this.dayPlans),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'mode': describeEnum(mode),
        'dayPlans': dayPlans.map((d) => d.toJson()).toList(),
      };

  factory RoutinePlan.fromJson(Map<String, dynamic> j) => RoutinePlan(
        id: j['id'] as String?,
        title: j['title'] as String,
        mode: (j['mode'] as String) == 'weekly' ? PlanMode.weekly : PlanMode.nDays,
        dayPlans: (j['dayPlans'] as List<dynamic>)
            .map((d) => DayPlan.fromJson(d as Map<String, dynamic>))
            .toList(),
      );

  String prettyPrint() {
    final buffer = StringBuffer();
    buffer.writeln('Title: $title');
    for (final day in dayPlans.where((d) => d.exercises.isNotEmpty)) {
      buffer.writeln('- ${day.label}');
      for (final ex in day.exercises) {
        buffer.writeln('   • ${ex.name} — ${ex.sets} sets, ${ex.minReps}-${ex.maxReps} reps');
      }
    }
    return buffer.toString();
  }
}
