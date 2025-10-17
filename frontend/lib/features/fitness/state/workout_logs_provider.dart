import 'dart:convert';
//import 'package:flutter/foundation.dart';

/// Represents a single set within an exercise (e.g., 100 kg × 6 reps).
class LoggedSet {
  final double weight;
  final int reps;

  const LoggedSet({
    required this.weight,
    required this.reps,
  });

  LoggedSet copyWith({
    double? weight,
    int? reps,
  }) {
    return LoggedSet(
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
    );
  }

  Map<String, dynamic> toJson() => {
        'weight': weight,
        'reps': reps,
      };

  factory LoggedSet.fromJson(Map<String, dynamic> json) => LoggedSet(
        weight: (json['weight'] as num).toDouble(),
        reps: (json['reps'] as num).toInt(),
      );

  @override
  String toString() => 'LoggedSet(weight: $weight, reps: $reps)';
}

/// Represents an exercise (like Bench Press) and all its sets.
class LoggedExercise {
  final String name;
  final List<LoggedSet> sets;

  const LoggedExercise({
    required this.name,
    required this.sets,
  });

  LoggedExercise copyWith({
    String? name,
    List<LoggedSet>? sets,
  }) {
    return LoggedExercise(
      name: name ?? this.name,
      sets: sets ?? this.sets,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'sets': sets.map((s) => s.toJson()).toList(),
      };

  factory LoggedExercise.fromJson(Map<String, dynamic> json) => LoggedExercise(
        name: (json['name'] as String).trim(),
        sets: (json['sets'] as List)
            .map((e) => LoggedSet.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  String toString() => 'LoggedExercise(name: $name, sets: $sets)';
}

/// Represents one full workout log for a given date and routine day.
class WorkoutLog {
  final String id;
  final DateTime date;
  final String? routineTitle;
  final String? dayLabel;
  final List<LoggedExercise> exercises;

  WorkoutLog({
    String? id,
    required this.date,
    this.routineTitle,
    this.dayLabel,
    required this.exercises,
  }) : id = id ?? _makeId(date);

  WorkoutLog copyWith({
    String? id,
    DateTime? date,
    String? dayLabel,
    List<LoggedExercise>? exercises,
  }) {
    return WorkoutLog(
      id: id ?? this.id,
      date: date ?? this.date,
      dayLabel: dayLabel ?? this.dayLabel,
      exercises: exercises ?? this.exercises,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'dayLabel': dayLabel,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory WorkoutLog.fromJson(Map<String, dynamic> json) => WorkoutLog(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        dayLabel: json['dayLabel'] as String?,
        exercises: (json['exercises'] as List)
            .map((e) => LoggedExercise.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  static String encodeList(List<WorkoutLog> logs) =>
      jsonEncode(logs.map((e) => e.toJson()).toList());

  static List<WorkoutLog> decodeList(String raw) =>
      (jsonDecode(raw) as List)
          .map((e) => WorkoutLog.fromJson(e as Map<String, dynamic>))
          .toList();

  /// Generates a unique ID (e.g., log_2025-10-17_141022).
  // internal id generator used when id is not provided
  static String _makeId([DateTime? date]) {
    final d = date ?? DateTime.now();
    return 'log_${d.year}-${_two(d.month)}-${_two(d.day)}T${_two(d.hour)}${_two(d.minute)}${_two(d.second)}';
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  @override
  String toString() =>
      'WorkoutLog(id: $id, date: $date, dayLabel: $dayLabel, exercises: $exercises)';
}