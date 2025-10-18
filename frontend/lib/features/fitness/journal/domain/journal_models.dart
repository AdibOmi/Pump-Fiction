import 'dart:convert';

class JournalSession {
  final String id;
  final String name;
  final DateTime createdAt;

  /// Optional cover image path (first entry image)
  final String? coverImageBase64;

  const JournalSession({
    required this.id,
    required this.name,
    required this.createdAt,
    this.coverImageBase64,
  });

  JournalSession copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    String? coverImageBase64,
  }) => JournalSession(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    coverImageBase64: coverImageBase64 ?? this.coverImageBase64,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'coverImageBase64': coverImageBase64,
  };

  factory JournalSession.fromJson(Map<String, dynamic> json) => JournalSession(
    id: json['id'] as String,
    name: json['name'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    coverImageBase64: json['coverImageBase64'] as String?,
  );
}

class JournalEntry {
  final String id;
  final String sessionId;
  final DateTime date;
  final String imageBase64; // data URI base64 image
  final double? weight;

  const JournalEntry({
    required this.id,
    required this.sessionId,
    required this.date,
    required this.imageBase64,
    this.weight,
  });

  JournalEntry copyWith({
    String? id,
    String? sessionId,
    DateTime? date,
    String? imageBase64,
    double? weight,
  }) => JournalEntry(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    date: date ?? this.date,
    imageBase64: imageBase64 ?? this.imageBase64,
    weight: weight ?? this.weight,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'sessionId': sessionId,
    'date': date.toIso8601String(),
    'imageBase64': imageBase64,
    'weight': weight,
  };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'] as String,
    sessionId: json['sessionId'] as String,
    date: DateTime.parse(json['date'] as String),
    imageBase64: json['imageBase64'] as String,
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
