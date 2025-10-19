import 'dart:convert';

class TrackerEntry {
  TrackerEntry({
    this.id,
    required this.date,
    required this.value,
  });

  int? id; // ID from the backend (null for new entries)
  DateTime date;
  double value;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'date': date.toIso8601String(),
        'value': value,
      };

  factory TrackerEntry.fromJson(Map<String, dynamic> json) => TrackerEntry(
        id: json['id'] as int?,
        date: DateTime.parse(json['date'] as String),
        value: (json['value'] as num).toDouble(),
      );
}

class Tracker {
  Tracker({
    required this.id,
    required this.name,
    required this.unit,
    this.goal,
    List<TrackerEntry>? entries,
  }) : entries = entries ?? [];

  String id; // Store as string for compatibility with existing code (converted from int)
  String name;
  String unit; // e.g. kg, cm, bpm
  double? goal;
  List<TrackerEntry> entries;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unit': unit,
        if (goal != null) 'goal': goal,
        'entries': entries.map((e) => e.toJson()).toList(),
      };

  factory Tracker.fromJson(Map<String, dynamic> json) => Tracker(
        id: json['id'].toString(), // Convert int ID from backend to string
        name: (json['name'] as String).trim(),
        unit: (json['unit'] as String).trim(),
        goal: (json['goal'] as num?)?.toDouble(),
        entries: (json['entries'] as List<dynamic>?)
                ?.map((e) => TrackerEntry.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  static String encodeList(List<Tracker> list) =>
      jsonEncode(list.map((t) => t.toJson()).toList());

  static List<Tracker> decodeList(String raw) =>
      (jsonDecode(raw) as List<dynamic>)
          .map((e) => Tracker.fromJson(e as Map<String, dynamic>))
          .toList();
}
