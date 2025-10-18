import 'dart:io';
import 'package:dio/dio.dart';
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
            coverImagePath: e['cover_image_url'] as String?,
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
      coverImagePath: e['cover_image_url'] as String?,
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
            imagePath: e['image_url'] as String,
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
    final formData = FormData.fromMap({
      'weight': weight,
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });
    final res = await _api.post<Map<String, dynamic>>(
      '/journal/sessions/$sessionId/entries',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    final e = res.data!;
    return JournalEntry(
      id: (e['id']).toString(),
      sessionId: (e['session_id']).toString(),
      date: DateTime.parse(e['date'] as String),
      imagePath: e['image_url'] as String,
      weight: (e['weight'] as num?)?.toDouble(),
    );
  }
}
