import 'dart:convert';
import 'dart:io';
import '../../../../core/network/api_client.dart';
import '../../journal/domain/journal_models.dart';

class JournalRepository {
  final ApiClient _api = ApiClient();

  Future<List<JournalSession>> getSessions() async {
    final res = await _api.get<List<dynamic>>('/journal/sessions');
    final list = res.data ?? [];
    return list
        .map(
          (e) => JournalSession(
            id: (e['id']).toString(),
            name: e['name'] as String,
            createdAt: DateTime.parse(e['created_at'] as String),
            coverImageBase64: e['cover_image_base64'] as String?,
          ),
        )
        .toList();
  }

  Future<JournalSession> createSession(String name) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/journal/sessions',
      data: {'name': name},
    );
    final e = res.data!;
    return JournalSession(
      id: (e['id']).toString(),
      name: e['name'] as String,
      createdAt: DateTime.parse(e['created_at'] as String),
      coverImageBase64: e['cover_image_base64'] as String?,
    );
  }

  Future<List<JournalEntry>> getEntries(String sessionId) async {
    final res = await _api.get<Map<String, dynamic>>(
      '/journal/sessions/$sessionId/entries',
    );
    final list = (res.data?['entries'] as List? ?? []);
    return list
        .map(
          (e) => JournalEntry(
            id: (e['id']).toString(),
            sessionId: (e['session_id']).toString(),
            date: DateTime.parse(e['date'] as String),
            imageBase64: e['image_base64'] as String,
            weight: (e['weight'] as num?)?.toDouble(),
          ),
        )
        .toList();
  }

  Future<JournalEntry> addEntry({
    required String sessionId,
    required File file,
    double? weight,
  }) async {
    final bytes = await file.readAsBytes();
    final mime = _inferMimeType(file.path);
    final dataUri = 'data:$mime;base64,${base64Encode(bytes)}';
    final payload = {
      'image_base64': dataUri,
      if (weight != null) 'weight': weight,
    };
    final res = await _api.post<Map<String, dynamic>>(
      '/journal/sessions/$sessionId/entries',
      data: payload,
    );
    final e = res.data!;
    return JournalEntry(
      id: (e['id']).toString(),
      sessionId: (e['session_id']).toString(),
      date: DateTime.parse(e['date'] as String),
      imageBase64: e['image_base64'] as String,
      weight: (e['weight'] as num?)?.toDouble(),
    );
  }

  String _inferMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}
