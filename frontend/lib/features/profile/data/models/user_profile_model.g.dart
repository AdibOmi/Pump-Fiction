// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileModel _$UserProfileModelFromJson(Map<String, dynamic> json) =>
    UserProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      fitnessGoal: $enumDecodeNullable(
        _$FitnessGoalEnumMap,
        json['fitness_goal'],
      ),
      experienceLevel: $enumDecodeNullable(
        _$ExperienceLevelEnumMap,
        json['experience_level'],
      ),
      trainingFrequency: (json['training_frequency'] as num?)?.toInt(),
      nutritionGoal: $enumDecodeNullable(
        _$NutritionGoalEnumMap,
        json['nutrition_goal'],
      ),
    );

Map<String, dynamic> _$UserProfileModelToJson(UserProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'email': instance.email,
      'full_name': instance.fullName,
      'phone_number': instance.phoneNumber,
      'gender': _$GenderEnumMap[instance.gender],
      'weight_kg': instance.weightKg,
      'height_cm': instance.heightCm,
      'fitness_goal': _$FitnessGoalEnumMap[instance.fitnessGoal],
      'experience_level': _$ExperienceLevelEnumMap[instance.experienceLevel],
      'training_frequency': instance.trainingFrequency,
      'nutrition_goal': _$NutritionGoalEnumMap[instance.nutritionGoal],
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.other: 'other',
  Gender.preferNotToSay: 'prefer_not_to_say',
};

const _$FitnessGoalEnumMap = {
  FitnessGoal.strength: 'strength',
  FitnessGoal.muscleGain: 'muscle_gain',
  FitnessGoal.fatLoss: 'fat_loss',
  FitnessGoal.endurance: 'endurance',
  FitnessGoal.generalFitness: 'general_fitness',
};

const _$ExperienceLevelEnumMap = {
  ExperienceLevel.beginner: 'beginner',
  ExperienceLevel.intermediate: 'intermediate',
  ExperienceLevel.advanced: 'advanced',
};

const _$NutritionGoalEnumMap = {
  NutritionGoal.cut: 'cut',
  NutritionGoal.bulk: 'bulk',
  NutritionGoal.recomp: 'recomp',
  NutritionGoal.maintain: 'maintain',
};
