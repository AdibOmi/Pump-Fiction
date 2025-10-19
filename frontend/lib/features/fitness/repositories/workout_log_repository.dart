import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../state/workout_logs_provider.dart';

class WorkoutLogRepository {
  final ApiClient _apiClient;

  WorkoutLogRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get all workout logs for the current user
  Future<List<WorkoutLog>> getAllWorkoutLogs({int limit = 100}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.workoutLogs,
        queryParameters: {'limit': limit},
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => WorkoutLog.fromBackendJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get a specific workout log by ID
  Future<WorkoutLog> getWorkoutLog(String id) async {
    try {
      final response = await _apiClient.get(ApiConstants.workoutLog(id));
      return WorkoutLog.fromBackendJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create a new workout log
  Future<WorkoutLog> createWorkoutLog(WorkoutLog log) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.workoutLogs,
        data: log.toBackendJson(),
      );
      return WorkoutLog.fromBackendJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update an existing workout log
  Future<WorkoutLog> updateWorkoutLog(String id, WorkoutLog log) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.workoutLog(id),
        data: log.toBackendJson(),
      );
      return WorkoutLog.fromBackendJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete a workout log
  Future<void> deleteWorkoutLog(String id) async {
    try {
      await _apiClient.delete(ApiConstants.workoutLog(id));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get exercise history
  Future<Map<String, dynamic>> getExerciseHistory(String exerciseName) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.exerciseHistory(Uri.encodeComponent(exerciseName)),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get workout statistics
  Future<Map<String, dynamic>> getWorkoutStats() async {
    try {
      final response = await _apiClient.get(ApiConstants.workoutStats);
      return response.data as Map<String, dynamic>;
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
