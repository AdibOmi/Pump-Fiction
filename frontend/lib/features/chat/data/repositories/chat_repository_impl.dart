import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/chat_session_model.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ApiClient _apiClient;

  ChatRepositoryImpl(this._apiClient);

  @override
  Future<ChatSessionModel> createSession({String? title}) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.aiChatSessions,
        data: {'title': title ?? 'New Chat'},
      );

      if (response.statusCode == 201) {
        return ChatSessionModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create session: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('Authentication required. Please log in again.');
      }
      throw Exception('Network error: ${e.response?.data?['detail'] ?? e.message}');
    } catch (e) {
      throw Exception('Failed to create session: $e');
    }
  }

  @override
  Future<List<ChatSessionModel>> getSessions({bool isArchived = false}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.aiChatSessions,
        queryParameters: {'is_archived': isArchived},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Handle empty list or null response
        if (data == null || (data is List && data.isEmpty)) {
          return [];
        }

        if (data is! List) {
          throw Exception('Invalid response format: expected list, got ${data.runtimeType}');
        }

        return data.map((json) => ChatSessionModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to get sessions: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // No sessions found, return empty list
      }
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('Authentication required. Please log in again.');
      }
      throw Exception('Network error: ${e.response?.data?['detail'] ?? e.message}');
    } catch (e) {
      if (e.toString().contains('type \'Null\' is not a subtype')) {
        return []; // Handle null data gracefully
      }
      throw Exception('Failed to get sessions: $e');
    }
  }

  @override
  Future<ChatSessionDetailModel> getSessionDetail(String sessionId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.aiChatSession(sessionId),
      );

      if (response.statusCode == 200) {
        return ChatSessionDetailModel.fromJson(response.data);
      } else {
        throw Exception('Failed to get session detail: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Session not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get session detail: $e');
    }
  }

  @override
  Future<SendMessageResponse> sendMessage(
      String sessionId, String content) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.aiChatSendMessage(sessionId),
        data: {'content': content},
      );

      if (response.statusCode == 201) {
        return SendMessageResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Session not found');
      }
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('Authentication required. Please log in again.');
      }
      if (e.response?.statusCode == 500) {
        throw Exception('AI service error: ${e.response?.data?['detail'] ?? 'Please try again later'}');
      }
      throw Exception('Network error: ${e.response?.data?['detail'] ?? e.message}');
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.aiChatSession(sessionId),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete session: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Session not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete session: $e');
    }
  }

  @override
  Future<void> archiveSession(String sessionId) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.aiChatArchive(sessionId),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to archive session: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Session not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to archive session: $e');
    }
  }
}
