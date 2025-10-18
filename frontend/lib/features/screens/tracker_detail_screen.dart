import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../fitness/progress/trackers/tracker_provider.dart';
import '../fitness/progress/trackers/tracker_models.dart';

class TrackerDetailScreen extends ConsumerStatefulWidget {
  const TrackerDetailScreen({super.key, required this.trackerId});
  final String trackerId;

  @override
  ConsumerState<TrackerDetailScreen> createState() => _TrackerDetailScreenState();
}

class _TrackerDetailScreenState extends ConsumerState<TrackerDetailScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _valueCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final trackers = ref.watch(trackersProvider);
    final notifier = ref.read(trackersProvider.notifier);
    final tracker = trackers.firstWhere((t) => t.id == widget.trackerId);

    // Sort entries oldest->newest for plotting
    final entries = [...tracker.entries]..sort((a, b) => a.date.compareTo(b.date));
    final points = List.generate(entries.length, (i) => FlSpot(i.toDouble(), entries[i].value));

    // Compute y-range with padding
    double? minY;
    double? maxY;
    if (entries.isNotEmpty) {
      final minVal = entries.map((e) => e.value).reduce((a, b) => a < b ? a : b);
      final maxVal = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
      final padMin = (minVal.abs() * 0.1) + 1;
      final padMax = (maxVal.abs() * 0.1) + 1;
      minY = minVal - padMin;
      maxY = maxVal + padMax;

      // Make sure goal is visible if present
      if (tracker.goal != null) {
        minY = minY < tracker.goal! ? minY : tracker.goal! - 1;
        maxY = maxY > tracker.goal! ? maxY : tracker.goal! + 1;
      }
    }

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(tracker.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Graph always visible
          SizedBox(
            height: 260,
            child: entries.isEmpty
                ? Center(
                    child: Text(
                      'No data yet.\nAdd your first entry below.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.onSurface.withOpacity(.7)),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (points.length - 1).toDouble(),
                      minY: minY,
                      maxY: maxY,
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0)),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (val, _) {
                              final i = val.toInt();
                              if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                              final d = entries[i].date;
                              return Text('${d.month}/${d.day}', style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(show: true),

                      // ➕ Subtle goal line
                      extraLinesData: tracker.goal == null
                          ? const ExtraLinesData()
                          : ExtraLinesData(horizontalLines: [
                              HorizontalLine(
                                y: tracker.goal!,
                                color: cs.primary.withOpacity(0.35),
                                strokeWidth: 2,
                                dashArray: [6, 4],
                                label: HorizontalLineLabel(
                                  show: true,
                                  alignment: Alignment.topRight,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: cs.onSurface.withOpacity(.6),
                                  ),
                                  labelResolver: (_) => 'Goal: ${_trimZero(tracker.goal!)} ${tracker.unit}',
                                ),
                              ),
                            ]),

                      lineBarsData: [
                        LineChartBarData(
                          isCurved: false,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          spots: points,
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 12),

          // Goal text (kept)
          if (tracker.goal != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Goal: ${_trimZero(tracker.goal!)} ${tracker.unit}'),
            ),

          // Entry form (date + value)
          Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.event),
                label: Text(_fmtDate(_selectedDate)),
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
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _valueCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Value (${tracker.unit})',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () async {
                  final val = double.tryParse(_valueCtrl.text.trim());
                  if (val == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter a valid number')),
                    );
                    return;
                  }
                  await notifier.addEntry(
                    tracker.id,
                    TrackerEntry(date: _selectedDate, value: val),
                  );
                  _valueCtrl.clear();
                  setState(() {}); // refresh chart
                },
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text('Entries', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),

          if (tracker.entries.isEmpty)
            Text(
              'No entries yet.',
              style: TextStyle(color: cs.onSurface.withOpacity(.7)),
            )
          else
            ...tracker.entries.asMap().entries.map((e) {
              final i = e.key; // newest-first from provider
              final ent = e.value;
              final dateStr = _fmtDate(ent.date);

              // ➕ Icon color based on comparison with goal
              Color? iconColor;
              if (tracker.goal != null) {
                iconColor = (ent.value >= tracker.goal!) ? Colors.green : Colors.redAccent;
              }

              return Card(
                child: ListTile(
                  leading: Icon(Icons.timeline, color: iconColor),
                  title: Text('$dateStr — ${_trimZero(ent.value)} ${tracker.unit}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editEntryDialog(context, ref, tracker, i),
                      ),
                      // ➕ Delete buttons tinted red
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => ref.read(trackersProvider.notifier).deleteEntry(tracker.id, i),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _editEntryDialog(
    BuildContext context,
    WidgetRef ref,
    Tracker tracker,
    int index,
  ) async {
    final ent = tracker.entries[index];
    final date = ent.date;
    final ctrl = TextEditingController(text: ent.value.toString());
    DateTime picked = date;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Entry'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.event),
                  label: Text(_fmtDate(picked)),
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: picked,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (d != null) setDialogState(() => picked = d);
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Value (${tracker.unit})'),
                  validator: (v) => (double.tryParse(v ?? '') != null) ? null : 'Enter a number',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final val = double.parse(ctrl.text);
                await ref.read(trackersProvider.notifier).updateEntry(
                      tracker.id,
                      index,
                      TrackerEntry(date: picked, value: val),
                    );
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                setState(() {}); // refresh chart
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Neater display for doubles: drop trailing ".0" when possible.
  static String _trimZero(double v) {
    final s = v.toStringAsFixed(2);
    if (s.endsWith('.00')) return s.substring(0, s.length - 3);
    if (s.endsWith('0')) return s.substring(0, s.length - 1);
    return s;
  }
}
