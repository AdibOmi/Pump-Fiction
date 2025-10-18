import 'package:json_annotation/json_annotation.dart';
import 'chat_message_model.dart';

part 'chat_session_model.g.dart';

@JsonSerializable()
class ChatSessionModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String title;
  @JsonKey(name: 'last_message_at')
  final DateTime lastMessageAt;
  @JsonKey(name: 'is_archived')
  final bool isArchived;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  ChatSessionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.lastMessageAt,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatSessionModelToJson(this);
}

@JsonSerializable()
class ChatSessionDetailModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String title;
  @JsonKey(name: 'last_message_at')
  final DateTime lastMessageAt;
  @JsonKey(name: 'is_archived')
  final bool isArchived;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final List<ChatMessageModel> messages;

  ChatSessionDetailModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.lastMessageAt,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  factory ChatSessionDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatSessionDetailModelToJson(this);
}

@JsonSerializable()
class SendMessageResponse {
  @JsonKey(name: 'user_message')
  final ChatMessageModel userMessage;
  @JsonKey(name: 'assistant_message')
  final ChatMessageModel assistantMessage;

  SendMessageResponse({
    required this.userMessage,
    required this.assistantMessage,
  });

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$SendMessageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SendMessageResponseToJson(this);
}
