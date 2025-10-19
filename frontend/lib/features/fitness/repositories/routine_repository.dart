import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/routine_models.dart';

class RoutineRepository {
  final ApiClient _apiClient;

  RoutineRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get all routines for the current user
  Future<List<RoutinePlan>> getAllRoutines({bool includeArchived = false}) async {
    try {
      print('📥 RoutineRepository: Fetching routines from ${ApiConstants.routines}...');
      print('   Include archived: $includeArchived');

      final response = await _apiClient.get(
        ApiConstants.routines,
        queryParameters: {'include_archived': includeArchived},
      );

      print('📦 RoutineRepository: Backend response received');
      print('   Status code: ${response.statusCode}');
      print('   Data type: ${response.data.runtimeType}');
      print('   Data: ${response.data}');

      if (response.data is List) {
        final routines = (response.data as List)
            .map((json) {
              print('🔍 Parsing routine: ${json['title']}');
              print('   Exercises in response: ${json['exercises']?.length ?? 0}');
              final routine = RoutinePlan.fromBackendJson(json as Map<String, dynamic>);
              print('   Exercises after parsing: ${routine.dayPlans.first.exercises.length}');
              return routine;
            })
            .toList();
        print('✅ Total routines loaded: ${routines.length}');
        return routines;
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get a specific routine by ID with full details
  Future<RoutinePlan> getRoutine(String id) async {
    try {
      final response = await _apiClient.get(ApiConstants.routine(id));
      return RoutinePlan.fromBackendJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create a new routine
  Future<RoutinePlan> createRoutine(RoutinePlan routine) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.routines,
        data: routine.toBackendJson(),
      );
      return RoutinePlan.fromBackendJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update an existing routine
  Future<RoutinePlan> updateRoutine(String id, RoutinePlan routine) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.routine(id),
        data: routine.toBackendJson(),
      );
      return RoutinePlan.fromBackendJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete a routine
  Future<void> deleteRoutine(String id) async {
    try {
      await _apiClient.delete(ApiConstants.routine(id));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Archive or unarchive a routine
  Future<RoutinePlan> archiveRoutine(String id, bool isArchived) async {
    try {
      final response = await _apiClient.patch(
        ApiConstants.routineArchive(id),
        queryParameters: {'is_archived': isArchived},
      );
      return RoutinePlan.fromBackendJson(response.data as Map<String, dynamic>);
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
