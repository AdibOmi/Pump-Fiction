// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessageModel _$ChatMessageModelFromJson(Map<String, dynamic> json) =>
    ChatMessageModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      role: $enumDecode(_$ChatRoleEnumMap, json['role']),
      content: json['content'] as String,
      tokensUsed: (json['tokens_used'] as num?)?.toInt(),
      modelVersion: json['model_version'] as String?,
      safetyFlag: json['safety_flag'] as bool? ?? false,
      disclaimerShown: json['disclaimer_shown'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ChatMessageModelToJson(ChatMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'session_id': instance.sessionId,
      'role': _$ChatRoleEnumMap[instance.role]!,
      'content': instance.content,
      'tokens_used': instance.tokensUsed,
      'model_version': instance.modelVersion,
      'safety_flag': instance.safetyFlag,
      'disclaimer_shown': instance.disclaimerShown,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$ChatRoleEnumMap = {
  ChatRole.user: 'user',
  ChatRole.assistant: 'assistant',
  ChatRole.system: 'system',
};
