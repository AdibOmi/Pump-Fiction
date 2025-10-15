from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime
from ..core.database import Base


class Post(Base):
    __tablename__ = 'posts'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    content = Column(Text, nullable=True)  # Text content of the post
    image_url = Column(String, nullable=True)  # URL to image in Supabase storage
    image_path = Column(String, nullable=True)  # Storage path for the image
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationship to user and photos
    user = relationship("User", back_populates="posts")
    photos = relationship("PostPhoto", back_populates="post", cascade="all, delete-orphan")


class PostPhoto(Base):
    __tablename__ = 'post_photos'
    
    id = Column(Integer, primary_key=True, index=True)
    post_id = Column(Integer, ForeignKey('posts.id'), nullable=False)
    photo_url = Column(String, nullable=False)
    photo_path = Column(String, nullable=False)
    is_primary = Column(Boolean, default=False)  # If this is the main photo
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationship to post
    post = relationship("Post", back_populates="photos")