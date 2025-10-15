from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


class PostPhotoBase(BaseModel):
    photo_url: str
    photo_path: str
    is_primary: bool = False


class PostPhotoCreate(PostPhotoBase):
    pass


class PostPhotoResponse(PostPhotoBase):
    id: int
    post_id: int
    created_at: datetime
    
    class Config:
        from_attributes = True


class PostBase(BaseModel):
    content: Optional[str] = None


class PostCreate(PostBase):
    photos: Optional[List[str]] = []  # List of base64 encoded images or file paths


class PostUpdate(BaseModel):
    content: Optional[str] = None
    is_active: Optional[bool] = None


class PostResponse(PostBase):
    id: int
    user_id: int
    image_url: Optional[str] = None
    image_path: Optional[str] = None
    is_active: bool
    created_at: datetime
    updated_at: datetime
    photos: List[PostPhotoResponse] = []
    
    class Config:
        from_attributes = True


class PostWithUser(PostResponse):
    user: dict  # We'll include basic user info
    
    class Config:
        from_attributes = True


class PostListResponse(BaseModel):
    posts: List[PostWithUser]
    total: int
    page: int
    page_size: int
    total_pages: int