import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/models/chat_session_model.dart';
import '../../data/models/chat_message_model.dart';

part 'chat_providers.g.dart';

// Repository Provider
@riverpod
ChatRepository chatRepository(Ref ref) {
  final apiClient = ApiClient();
  return ChatRepositoryImpl(apiClient);
}

// Sessions List Provider
@riverpod
class ChatSessions extends _$ChatSessions {
  @override
  Future<List<ChatSessionModel>> build({bool isArchived = false}) async {
    final repository = ref.watch(chatRepositoryProvider);
    return await repository.getSessions(isArchived: isArchived);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final repository = ref.read(chatRepositoryProvider);
    try {
      final sessions = await repository.getSessions(isArchived: false);
      state = AsyncData(sessions);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<ChatSessionModel> createSession({String? title}) async {
    final repository = ref.read(chatRepositoryProvider);
    try {
      final session = await repository.createSession(title: title);
      await refresh();
      return session;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSession(String sessionId) async {
    final repository = ref.read(chatRepositoryProvider);
    try {
      await repository.deleteSession(sessionId);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> archiveSession(String sessionId) async {
    final repository = ref.read(chatRepositoryProvider);
    try {
      await repository.archiveSession(sessionId);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }
}

// Current Session Detail Provider
@riverpod
class CurrentChatSession extends _$CurrentChatSession {
  String? _sessionId;

  @override
  Future<ChatSessionDetailModel?> build(String? sessionId) async {
    _sessionId = sessionId;
    if (sessionId == null) return null;

    final repository = ref.watch(chatRepositoryProvider);
    return await repository.getSessionDetail(sessionId);
  }

  Future<void> refresh() async {
    if (_sessionId == null) return;

    state = const AsyncLoading();
    final repository = ref.read(chatRepositoryProvider);
    try {
      final session = await repository.getSessionDetail(_sessionId!);
      state = AsyncData(session);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> sendMessage(String content) async {
    if (_sessionId == null) return;

    final repository = ref.read(chatRepositoryProvider);
    try {
      await repository.sendMessage(_sessionId!, content);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }
}

// Loading state for message sending
final isSendingMessageProvider = StateProvider<bool>((ref) => false);
