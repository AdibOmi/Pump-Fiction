import 'package:json_annotation/json_annotation.dart';

part 'user_profile_model.g.dart';

/// Gender enum
enum Gender {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
  @JsonValue('other')
  other,
  @JsonValue('prefer_not_to_say')
  preferNotToSay,
}

/// Fitness goal enum
enum FitnessGoal {
  @JsonValue('strength')
  strength,
  @JsonValue('muscle_gain')
  muscleGain,
  @JsonValue('fat_loss')
  fatLoss,
  @JsonValue('endurance')
  endurance,
  @JsonValue('general_fitness')
  generalFitness,
}

/// Experience level enum
enum ExperienceLevel {
  @JsonValue('beginner')
  beginner,
  @JsonValue('intermediate')
  intermediate,
  @JsonValue('advanced')
  advanced,
}

/// Nutrition goal enum
enum NutritionGoal {
  @JsonValue('cut')
  cut,
  @JsonValue('bulk')
  bulk,
  @JsonValue('recomp')
  recomp,
  @JsonValue('maintain')
  maintain,
}

/// User profile model
@JsonSerializable()
class UserProfileModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String email;

  // Basic info
  @JsonKey(name: 'full_name')
  final String? fullName;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final Gender? gender;

  // Physical attributes
  @JsonKey(name: 'weight_kg')
  final double? weightKg;
  @JsonKey(name: 'height_cm')
  final double? heightCm;

  // Fitness preferences
  @JsonKey(name: 'fitness_goal')
  final FitnessGoal? fitnessGoal;
  @JsonKey(name: 'experience_level')
  final ExperienceLevel? experienceLevel;
  @JsonKey(name: 'training_frequency')
  final int? trainingFrequency;
  @JsonKey(name: 'nutrition_goal')
  final NutritionGoal? nutritionGoal;

  UserProfileModel({
    required this.id,
    required this.userId,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.gender,
    this.weightKg,
    this.heightCm,
    this.fitnessGoal,
    this.experienceLevel,
    this.trainingFrequency,
    this.nutritionGoal,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // Create a mutable copy so we can normalise incoming payload discrepancies.
    final normalised = Map<String, dynamic>.from(json);

    final resolvedUserId = _resolveUserId(json);
    normalised['user_id'] = resolvedUserId;

    // Some responses only include `name`; prefer backend value when available.
    normalised['full_name'] = normalised['full_name'] ?? normalised['name'];

    return _$UserProfileModelFromJson(normalised);
  }

  static String _resolveUserId(Map<String, dynamic> json) {
    final dynamic raw = json['user_id'] ?? json['userId'] ?? json['id'];
    if (raw is String && raw.isNotEmpty) {
      return raw;
    }
    throw const FormatException('Profile payload missing required user identifier');
  }

  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);

  UserProfileModel copyWith({
    String? id,
    String? userId,
    String? email,
    String? fullName,
    String? phoneNumber,
    Gender? gender,
    double? weightKg,
    double? heightCm,
    FitnessGoal? fitnessGoal,
    ExperienceLevel? experienceLevel,
    int? trainingFrequency,
    NutritionGoal? nutritionGoal,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      trainingFrequency: trainingFrequency ?? this.trainingFrequency,
      nutritionGoal: nutritionGoal ?? this.nutritionGoal,
    );
  }
}

/// Extension methods for enums to get display strings
extension GenderExtension on Gender {
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
      case Gender.preferNotToSay:
        return 'Prefer not to say';
    }
  }
}

extension FitnessGoalExtension on FitnessGoal {
  String get displayName {
    switch (this) {
      case FitnessGoal.strength:
        return 'Strength';
      case FitnessGoal.muscleGain:
        return 'Muscle Gain';
      case FitnessGoal.fatLoss:
        return 'Fat Loss';
      case FitnessGoal.endurance:
        return 'Endurance';
      case FitnessGoal.generalFitness:
        return 'General Fitness';
    }
  }
}

extension ExperienceLevelExtension on ExperienceLevel {
  String get displayName {
    switch (this) {
      case ExperienceLevel.beginner:
        return 'Beginner';
      case ExperienceLevel.intermediate:
        return 'Intermediate';
      case ExperienceLevel.advanced:
        return 'Advanced';
    }
  }
}

extension NutritionGoalExtension on NutritionGoal {
  String get displayName {
    switch (this) {
      case NutritionGoal.cut:
        return 'Cut (Lose Weight)';
      case NutritionGoal.bulk:
        return 'Bulk (Gain Weight)';
      case NutritionGoal.recomp:
        return 'Recomp (Body Recomposition)';
      case NutritionGoal.maintain:
        return 'Maintain Weight';
    }
  }
}
