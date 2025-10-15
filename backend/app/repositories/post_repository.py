from sqlalchemy.orm import Session, joinedload
from sqlalchemy import desc
from typing import List, Optional
from ..models.post_model import Post, PostPhoto
from ..models.user_model import User
from ..schemas.post_schema import PostCreate, PostUpdate


class PostRepository:
    def __init__(self, db: Session):
        self.db = db
    
    async def create_post(self, post_data: PostCreate, user_id: int) -> Post:
        """Create a new post"""
        db_post = Post(
            user_id=user_id,
            content=post_data.content
        )
        self.db.add(db_post)
        self.db.commit()
        self.db.refresh(db_post)
        return db_post
    
    async def add_photos_to_post(self, post_id: int, photos: List[dict]) -> List[PostPhoto]:
        """Add photos to a post"""
        db_photos = []
        for i, photo in enumerate(photos):
            db_photo = PostPhoto(
                post_id=post_id,
                photo_url=photo['url'],
                photo_path=photo['path'],
                is_primary=(i == 0)  # First photo is primary
            )
            self.db.add(db_photo)
            db_photos.append(db_photo)
        
        self.db.commit()
        for photo in db_photos:
            self.db.refresh(photo)
        return db_photos
    
    async def get_post_by_id(self, post_id: int) -> Optional[Post]:
        """Get a post by ID with photos and user info"""
        return self.db.query(Post).options(
            joinedload(Post.photos),
            joinedload(Post.user)
        ).filter(Post.id == post_id, Post.is_active == True).first()
    
    async def get_posts_by_user(self, user_id: int, skip: int = 0, limit: int = 20) -> List[Post]:
        """Get posts by user ID with pagination"""
        return self.db.query(Post).options(
            joinedload(Post.photos),
            joinedload(Post.user)
        ).filter(
            Post.user_id == user_id,
            Post.is_active == True
        ).order_by(desc(Post.created_at)).offset(skip).limit(limit).all()
    
    async def get_all_posts(self, skip: int = 0, limit: int = 20) -> List[Post]:
        """Get all posts with pagination"""
        return self.db.query(Post).options(
            joinedload(Post.photos),
            joinedload(Post.user)
        ).filter(Post.is_active == True).order_by(desc(Post.created_at)).offset(skip).limit(limit).all()
    
    async def update_post(self, post_id: int, post_data: PostUpdate, user_id: int) -> Optional[Post]:
        """Update a post (only by the owner)"""
        db_post = self.db.query(Post).filter(
            Post.id == post_id,
            Post.user_id == user_id,
            Post.is_active == True
        ).first()
        
        if not db_post:
            return None
        
        update_data = post_data.dict(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_post, key, value)
        
        self.db.commit()
        self.db.refresh(db_post)
        return db_post
    
    async def delete_post(self, post_id: int, user_id: int) -> bool:
        """Soft delete a post (only by the owner)"""
        db_post = self.db.query(Post).filter(
            Post.id == post_id,
            Post.user_id == user_id,
            Post.is_active == True
        ).first()
        
        if not db_post:
            return False
        
        db_post.is_active = False
        self.db.commit()
        return True
    
    async def count_user_posts(self, user_id: int) -> int:
        """Count total posts for a user"""
        return self.db.query(Post).filter(
            Post.user_id == user_id,
            Post.is_active == True
        ).count()
    
    async def count_all_posts(self) -> int:
        """Count total active posts"""
        return self.db.query(Post).filter(Post.is_active == True).count()