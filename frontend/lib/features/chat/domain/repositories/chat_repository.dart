import '../../data/models/chat_session_model.dart';
import '../../data/models/chat_message_model.dart';

abstract class ChatRepository {
  Future<ChatSessionModel> createSession({String? title});
  Future<List<ChatSessionModel>> getSessions({bool isArchived = false});
  Future<ChatSessionDetailModel> getSessionDetail(String sessionId);
  Future<SendMessageResponse> sendMessage(String sessionId, String content);
  Future<void> deleteSession(String sessionId);
  Future<void> archiveSession(String sessionId);
}
