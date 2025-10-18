import 'dart:convert';

class JournalSession {
  final String id;
  final String name;
  final DateTime createdAt;

  /// Optional cover image path (first entry image)
  final String? coverImagePath;

  const JournalSession({
    required this.id,
    required this.name,
    required this.createdAt,
    this.coverImagePath,
  });

  JournalSession copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    String? coverImagePath,
  }) => JournalSession(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    coverImagePath: coverImagePath ?? this.coverImagePath,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'coverImagePath': coverImagePath,
  };

  factory JournalSession.fromJson(Map<String, dynamic> json) => JournalSession(
    id: json['id'] as String,
    name: json['name'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    coverImagePath: json['coverImagePath'] as String?,
  );
}

class JournalEntry {
  final String id;
  final String sessionId;
  final DateTime date;
  final String imagePath; // local path for now
  final double? weight;

  const JournalEntry({
    required this.id,
    required this.sessionId,
    required this.date,
    required this.imagePath,
    this.weight,
  });

  JournalEntry copyWith({
    String? id,
    String? sessionId,
    DateTime? date,
    String? imagePath,
    double? weight,
  }) => JournalEntry(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    date: date ?? this.date,
    imagePath: imagePath ?? this.imagePath,
    weight: weight ?? this.weight,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'sessionId': sessionId,
    'date': date.toIso8601String(),
    'imagePath': imagePath,
    'weight': weight,
  };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'] as String,
    sessionId: json['sessionId'] as String,
    date: DateTime.parse(json['date'] as String),
    imagePath: json['imagePath'] as String,
    weight: (json['weight'] as num?)?.toDouble(),
  );

  static String encodeList(List<JournalEntry> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<JournalEntry> decodeList(String raw) => (jsonDecode(raw) as List)
      .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
      .toList();
}

String makeId(String prefix) {
  final d = DateTime.now();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${prefix}_${d.year}-${two(d.month)}-${two(d.day)}T${two(d.hour)}${two(d.minute)}${two(d.second)}${d.millisecond}';
}
