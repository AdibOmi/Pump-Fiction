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

  // Backend JSON conversion (with position and day_label)
  Map<String, dynamic> toBackendJson(int position, String dayLabel) => {
        'title': name,
        'sets': sets,
        'min_reps': minReps,
        'max_reps': maxReps,
        'position': position,
        'day_label': dayLabel,  // NEW: Include which day this belongs to
      };

  factory Exercise.fromBackendJson(Map<String, dynamic> j) => Exercise(
        name: j['title'] as String,
        sets: j['sets'] as int,
        minReps: j['min_reps'] as int,
        maxReps: j['max_reps'] as int,
        // Note: day_label is used for grouping, not stored in Exercise model
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
  final bool isArchived;

  RoutinePlan({
    String? id,
    required this.title,
    required this.mode,
    required List<DayPlan> dayPlans,
    this.isArchived = false,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        dayPlans = List.of(dayPlans);

  RoutinePlan copyWith({
    String? id,
    String? title,
    PlanMode? mode,
    List<DayPlan>? dayPlans,
    bool? isArchived,
  }) =>
      RoutinePlan(
        id: id ?? this.id,
        title: title ?? this.title,
        mode: mode ?? this.mode,
        dayPlans: dayPlans ?? List.of(this.dayPlans),
        isArchived: isArchived ?? this.isArchived,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'mode': mode.name,
        'dayPlans': dayPlans.map((d) => d.toJson()).toList(),
        'isArchived': isArchived,
      };

  factory RoutinePlan.fromJson(Map<String, dynamic> j) => RoutinePlan(
        id: j['id'] as String?,
        title: j['title'] as String,
        mode: (j['mode'] as String) == 'weekly' ? PlanMode.weekly : PlanMode.nDays,
        dayPlans: (j['dayPlans'] as List<dynamic>)
            .map((d) => DayPlan.fromJson(d as Map<String, dynamic>))
            .toList(),
        isArchived: j['isArchived'] as bool? ?? false,
      );

  // Backend JSON conversion - collect ALL exercises from ALL days with day labels
  Map<String, dynamic> toBackendJson() {
    // Collect all exercises from all day plans with their day labels
    final allExercises = <Map<String, dynamic>>[];
    int position = 0;

    // Get all days that have exercises
    final daysWithExercises = dayPlans.where((day) => day.exercises.isNotEmpty).toList();

    // Build day_selected string (e.g., "Sat, Sun, Mon")
    final dayLabels = daysWithExercises.map((day) => day.label).join(', ');

    // Collect all exercises from all days with their day label
    for (final day in dayPlans) {
      for (final exercise in day.exercises) {
        allExercises.add(exercise.toBackendJson(position, day.label));  // Pass day label!
        position++;
      }
    }

    return {
      'title': title,
      'day_selected': dayLabels.isEmpty ? 'Not set' : dayLabels,
      'is_archived': isArchived,
      'exercises': allExercises,
    };
  }

  factory RoutinePlan.fromBackendJson(Map<String, dynamic> j) {
    // Convert backend RoutineHeader to frontend RoutinePlan
    print('🔧 fromBackendJson called for: ${j['title']}');
    print('   Raw exercises data: ${j['exercises']}');
    
    final exercisesJson = (j['exercises'] as List<dynamic>?) ?? [];
    print('   Total exercises in JSON: ${exercisesJson.length}');

    // Group exercises by day_label
    final Map<String, List<Exercise>> exercisesByDay = {};
    
    for (var exJson in exercisesJson) {
      final exercise = Exercise.fromBackendJson(exJson as Map<String, dynamic>);
      final dayLabel = exJson['day_label'] as String? ?? 'Day 1';
      
      print('   Exercise: ${exercise.name} -> Day: $dayLabel');
      
      if (!exercisesByDay.containsKey(dayLabel)) {
        exercisesByDay[dayLabel] = [];
      }
      exercisesByDay[dayLabel]!.add(exercise);
    }

    print('   Grouped into ${exercisesByDay.length} days');

    // Create DayPlan for each unique day_label
    final dayPlans = exercisesByDay.entries.map((entry) {
      print('   Creating DayPlan: ${entry.key} with ${entry.value.length} exercises');
      return DayPlan(
        label: entry.key,
        exercises: entry.value,
      );
    }).toList();

    // If no exercises, create one empty day with the day_selected label
    if (dayPlans.isEmpty) {
      dayPlans.add(DayPlan(
        label: j['day_selected'] as String? ?? 'Day 1',
        exercises: [],
      ));
    }

    return RoutinePlan(
      id: j['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: j['title'] as String,
      mode: PlanMode.nDays, // Default to nDays mode from backend
      dayPlans: dayPlans,
      isArchived: j['is_archived'] as bool? ?? false,
    );
  }

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
