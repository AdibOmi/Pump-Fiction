"""
User Profile Model
Stores extended user profile information separate from authentication
"""
from sqlalchemy import Column, Integer, String, Float, Enum as SQLEnum, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from ..core.database import Base
import enum
import uuid


class GenderEnum(str, enum.Enum):
    MALE = "male"
    FEMALE = "female"
    OTHER = "other"
    PREFER_NOT_TO_SAY = "prefer_not_to_say"


class FitnessGoalEnum(str, enum.Enum):
    STRENGTH = "strength"
    MUSCLE_GAIN = "muscle_gain"
    FAT_LOSS = "fat_loss"
    ENDURANCE = "endurance"
    GENERAL_FITNESS = "general_fitness"


class ExperienceLevelEnum(str, enum.Enum):
    BEGINNER = "beginner"
    INTERMEDIATE = "intermediate"
    ADVANCED = "advanced"


class NutritionGoalEnum(str, enum.Enum):
    CUT = "cut"
    BULK = "bulk"
    RECOMP = "recomp"
    MAINTAIN = "maintain"


class UserProfile(Base):
    __tablename__ = 'user_profiles'

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), unique=True, nullable=False)

    # Basic info
    full_name = Column(String, nullable=True)
    phone_number = Column(String, nullable=True)
    gender = Column(SQLEnum(GenderEnum, values_callable=lambda obj: [e.value for e in obj]), nullable=True)

    # Physical attributes
    weight_kg = Column(Float, nullable=True)
    height_cm = Column(Float, nullable=True)

    # Fitness preferences
    fitness_goal = Column(SQLEnum(FitnessGoalEnum, values_callable=lambda obj: [e.value for e in obj]), nullable=True)
    experience_level = Column(SQLEnum(ExperienceLevelEnum, values_callable=lambda obj: [e.value for e in obj]), nullable=True)
    training_frequency = Column(Integer, nullable=True)  # workouts per week
    nutrition_goal = Column(SQLEnum(NutritionGoalEnum, values_callable=lambda obj: [e.value for e in obj]), nullable=True)

    # Relationship
    user = relationship("User", back_populates="profile")
