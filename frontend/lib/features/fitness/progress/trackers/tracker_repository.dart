import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import 'tracker_models.dart';

class TrackerRepository {
  final ApiClient _apiClient;

  TrackerRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get all trackers for the current user
  Future<List<Tracker>> getTrackers() async {
    try {
      final response = await _apiClient.get(ApiConstants.trackers);

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Tracker.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get a specific tracker by ID
  Future<Tracker> getTracker(int id) async {
    try {
      final response = await _apiClient.get(ApiConstants.tracker(id));
      return Tracker.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create a new tracker
  Future<Tracker> createTracker({
    required String name,
    required String unit,
    double? goal,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.trackers,
        data: {
          'name': name,
          'unit': unit,
          if (goal != null) 'goal': goal,
        },
      );
      return Tracker.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update an existing tracker
  Future<Tracker> updateTracker(Tracker tracker) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.tracker(int.parse(tracker.id.replaceAll(RegExp(r'[^0-9]'), ''))),
        data: {
          'name': tracker.name,
          'unit': tracker.unit,
          if (tracker.goal != null) 'goal': tracker.goal,
        },
      );
      return Tracker.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete a tracker
  Future<void> deleteTracker(String id) async {
    try {
      await _apiClient.delete(
        ApiConstants.tracker(int.parse(id.replaceAll(RegExp(r'[^0-9]'), ''))),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Add an entry to a tracker
  Future<TrackerEntry> addEntry(String trackerId, TrackerEntry entry) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.trackerEntries(int.parse(trackerId.replaceAll(RegExp(r'[^0-9]'), ''))),
        data: entry.toJson(),
      );
      return TrackerEntry.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update an entry
  Future<TrackerEntry> updateEntry(
    String trackerId,
    int entryId,
    TrackerEntry entry,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.trackerEntry(
          int.parse(trackerId.replaceAll(RegExp(r'[^0-9]'), '')),
          entryId,
        ),
        data: entry.toJson(),
      );
      return TrackerEntry.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete an entry
  Future<void> deleteEntry(String trackerId, int entryId) async {
    try {
      await _apiClient.delete(
        ApiConstants.trackerEntry(
          int.parse(trackerId.replaceAll(RegExp(r'[^0-9]'), '')),
          entryId,
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('detail')) {
        return data['detail'].toString();
      }
      return 'Server error: ${e.response!.statusCode}';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    }
    return 'Network error: ${e.message}';
  }
}
