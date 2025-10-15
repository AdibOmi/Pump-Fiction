import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  @JsonKey(name: 'full_name')
  final String fullName;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final String role;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    required this.role,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonSerializable()
class SignupRequest {
  final String email;
  final String password;
  @JsonKey(name: 'full_name')
  final String fullName;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  SignupRequest({
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
  });

  factory SignupRequest.fromJson(Map<String, dynamic> json) => _$SignupRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SignupRequestToJson(this);
}

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class TokenResponse {
  @JsonKey(name: 'access_token')
  final String? accessToken;
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  @JsonKey(name: 'token_type')
  final String tokenType;
  @JsonKey(name: 'expires_in')
  final int expiresIn;
  final UserModel user;
  final String? message;

  TokenResponse({
    this.accessToken,
    this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
    this.message,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) => _$TokenResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TokenResponseToJson(this);
}
