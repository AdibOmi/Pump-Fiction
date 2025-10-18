import 'package:json_annotation/json_annotation.dart';

part 'chat_message_model.g.dart';

enum ChatRole {
  @JsonValue('user')
  user,
  @JsonValue('assistant')
  assistant,
  @JsonValue('system')
  system,
}

@JsonSerializable()
class ChatMessageModel {
  final String id;
  @JsonKey(name: 'session_id')
  final String sessionId;
  final ChatRole role;
  final String content;
  @JsonKey(name: 'tokens_used')
  final int? tokensUsed;
  @JsonKey(name: 'model_version')
  final String? modelVersion;
  @JsonKey(name: 'safety_flag')
  final bool safetyFlag;
  @JsonKey(name: 'disclaimer_shown')
  final bool disclaimerShown;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    this.tokensUsed,
    this.modelVersion,
    this.safetyFlag = false,
    this.disclaimerShown = false,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);
}
