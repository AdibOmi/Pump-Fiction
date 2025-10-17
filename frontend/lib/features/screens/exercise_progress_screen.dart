import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

// update the package name below if your app name isn't `frontend`
import '../fitness/state/workout_logs_provider.dart';
import '../fitness/state/routines_provider.dart';
import '../fitness/models/workout_log.dart';
import '../fitness/models/routine_models.dart';

class ExerciseProgressScreen extends ConsumerWidget {
  const ExerciseProgressScreen({super.key, required this.exerciseName});
  final String exerciseName;

  static const double _decay = 0.7;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logs = ref.watch(workoutLogsProvider);
    final routines = ref.watch(routinesProvider);

    // allow only exercises that still exist in saved routines
    final allow = <String>{};
    for (final r in routines) {
      for (final d in r.dayPlans) {
        for (final ex in d.exercises) {
          final n = ex.name.trim();
          if (n.isNotEmpty) allow.add(n.toLowerCase());
        }
      }
    }
    final key = exerciseName.trim().toLowerCase();
    final isAllowed = allow.contains(key);

    // date -> score & sets
    final Map<DateTime, double> scoreByDate = {};
    final Map<DateTime, List<LoggedSet>> setsByDate = {};
    for (final log in logs) {
      final matches = log.exercises
          .where((e) => e.name.trim().toLowerCase() == key)
          .toList();
      if (matches.isEmpty || !isAllowed) continue;

      final allSets = <LoggedSet>[];
      for (final e in matches) {
        allSets.addAll(e.sets);
      }

      double score = 0;
      for (var i = 0; i < allSets.length; i++) {
        score += (allSets[i].weight * allSets[i].reps) * _pow(_decay, i);
      }

      final day = DateTime(log.date.year, log.date.month, log.date.day);
      scoreByDate.update(day, (v) => v + score, ifAbsent: () => score);
      setsByDate.putIfAbsent(day, () => <LoggedSet>[]).addAll(allSets);
    }

    final points = scoreByDate.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Best day (by score)
    DateTime? bestDate;
    double bestScore = -1;
    for (final e in scoreByDate.entries) {
      if (e.value > bestScore) {
        bestScore = e.value;
        bestDate = e.key;
      }
    }
    final bestIndex = bestDate == null
        ? -1
        : points.indexWhere((e) => e.key == bestDate);
    final bestSets = bestDate == null
        ? const <LoggedSet>[]
        : (setsByDate[bestDate] ?? const <LoggedSet>[]);

    if (points.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(exerciseName)),
        body: Center(
          child: Text(
            isAllowed
                ? 'No logs yet for "$exerciseName".'
                : '“$exerciseName” is not in your current routines.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(.7),
            ),
          ),
        ),
      );
    }

    // Build spots
    final spots = <FlSpot>[];
    for (var i = 0; i < points.length; i++) {
      spots.add(FlSpot(i.toDouble(), points[i].value));
    }

    return Scaffold(
      appBar: AppBar(title: Text(exerciseName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score per Day (set-weighted: Σ weight×reps×${_decay.toStringAsFixed(2)}^setIndex)',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (points.length - 1).toDouble(),
                  minY: 0,
                  maxY: (() {
                    final m = points
                        .map((e) => e.value)
                        .fold<double>(0, (p, c) => c > p ? c : p);
                    return m == 0 ? 10.0 : m * 1.15;
                  })(),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (v, _) => Text(
                          v.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (val, _) {
                          final i = val.toInt();
                          if (i < 0 || i >= points.length)
                            return const SizedBox.shrink();
                          final d = points[i].key;
                          return Text(
                            '${d.month}/${d.day}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  // TOOLTIP: show that day's sets (no score)
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      // replaces tooltipBgColor
                        tooltipBgColor: theme.colorScheme.surface.withOpacity(0.95),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((t) {
                          final i = t.x.toInt();
                          final d = points[i].key;
                          final daySets = setsByDate[d] ?? const <LoggedSet>[];

                          final lines = <TextSpan>[
                            TextSpan(
                              text: '${_fmtDate(d)}\n',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            for (var s = 0; s < daySets.length; s++)
                              TextSpan(
                                text:
                                    'Set ${s + 1}:  ${_trim(daySets[s].weight)} × ${daySets[s].reps}\n',
                                style: const TextStyle(fontSize: 12),
                              ),
                          ];

                          // replaces LineTooltipItem.rich(...)
                          return LineTooltipItem(
                            '', // base text
                            const TextStyle(), // base style
                            children: lines, // your spans
                          );
                        }).toList();
                      },
                    ),
                  ),

                  lineBarsData: [
                    LineChartBarData(
                      isCurved: false,
                      barWidth: 3,
                      color: theme.colorScheme.primary,
                      spots: spots,
                      // Highlight best day dot
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          final isBest = index == bestIndex;
                          return FlDotCirclePainter(
                            radius: isBest ? 5.5 : 3.5,
                            color: isBest
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.primary,
                            strokeWidth: isBest ? 2 : 1,
                            strokeColor: theme.colorScheme.onSurface
                                .withOpacity(.6),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Best day summary (date + sets, no score)
            if (bestDate != null) ...[
              Text('Best Day', style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(_fmtDate(bestDate)),
              const SizedBox(height: 6),
              ...bestSets.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 2),
                  child: Text(
                    '• Set ${e.key + 1}:  Weight ${_trim(e.value.weight)}   Reps ${e.value.reps}',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// simple pow without importing dart:math to keep this file standalone
double _pow(double base, int n) {
  var r = 1.0;
  for (var i = 0; i < n; i++) {
    r *= base;
  }
  return r;
}

String _fmtDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _trim(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
