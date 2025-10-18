// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatSessionModel _$ChatSessionModelFromJson(Map<String, dynamic> json) =>
    ChatSessionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      lastMessageAt: DateTime.parse(json['last_message_at'] as String),
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ChatSessionModelToJson(ChatSessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'last_message_at': instance.lastMessageAt.toIso8601String(),
      'is_archived': instance.isArchived,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

ChatSessionDetailModel _$ChatSessionDetailModelFromJson(
  Map<String, dynamic> json,
) => ChatSessionDetailModel(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  title: json['title'] as String,
  lastMessageAt: DateTime.parse(json['last_message_at'] as String),
  isArchived: json['is_archived'] as bool? ?? false,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  messages: (json['messages'] as List<dynamic>)
      .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ChatSessionDetailModelToJson(
  ChatSessionDetailModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'title': instance.title,
  'last_message_at': instance.lastMessageAt.toIso8601String(),
  'is_archived': instance.isArchived,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'messages': instance.messages,
};

SendMessageResponse _$SendMessageResponseFromJson(Map<String, dynamic> json) =>
    SendMessageResponse(
      userMessage: ChatMessageModel.fromJson(
        json['user_message'] as Map<String, dynamic>,
      ),
      assistantMessage: ChatMessageModel.fromJson(
        json['assistant_message'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$SendMessageResponseToJson(
  SendMessageResponse instance,
) => <String, dynamic>{
  'user_message': instance.userMessage,
  'assistant_message': instance.assistantMessage,
};
