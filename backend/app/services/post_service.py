import base64
import uuid
from typing import List, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, UploadFile
import io
from ..repositories.post_repository import PostRepository
from ..models.post_model import Post
from ..schemas.post_schema import PostCreate, PostUpdate, PostResponse, PostWithUser, PostListResponse
from ..core.supabase_client import get_supabase_client
import math


class PostService:
    def __init__(self, db: Session):
        self.db = db
        self.post_repository = PostRepository(db)
        self.supabase = get_supabase_client()
        self.storage_bucket = "post-photos"  # Create this bucket in Supabase
    
    async def create_post(self, post_data: PostCreate, user_id: int) -> PostWithUser:
        """Create a new post with photos"""
        try:
            # Create the post first
            post = await self.post_repository.create_post(post_data, user_id)
            
            # Upload photos if provided
            uploaded_photos = []
            if post_data.photos:
                uploaded_photos = await self._upload_photos(post_data.photos, post.id)
                await self.post_repository.add_photos_to_post(post.id, uploaded_photos)
            
            # Get the complete post with photos and user info
            complete_post = await self.post_repository.get_post_by_id(post.id)
            return self._convert_to_post_with_user(complete_post)
            
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to create post: {str(e)}")
    
    async def upload_photos_for_post(self, files: List[UploadFile], post_id: int, user_id: int) -> List[dict]:
        """Upload photos from files for an existing post"""
        try:
            # Verify post belongs to user
            post = await self.post_repository.get_post_by_id(post_id)
            if not post or post.user_id != user_id:
                raise HTTPException(status_code=404, detail="Post not found or not authorized")
            
            # Upload files
            uploaded_photos = []
            for file in files:
                if not file.content_type.startswith('image/'):
                    raise HTTPException(status_code=400, detail=f"File {file.filename} is not an image")
                
                # Read file content
                content = await file.read()
                
                # Generate unique filename
                file_extension = file.filename.split('.')[-1] if '.' in file.filename else 'jpg'
                filename = f"post_{post_id}_{uuid.uuid4()}.{file_extension}"
                file_path = f"posts/{post_id}/{filename}"
                
                # Upload to Supabase storage
                result = self.supabase.storage.from_(self.storage_bucket).upload(
                    path=file_path,
                    file=content,
                    file_options={"content-type": file.content_type}
                )
                
                if result.status_code != 200:
                    raise HTTPException(status_code=500, detail=f"Failed to upload {file.filename}")
                
                # Get public URL
                public_url = self.supabase.storage.from_(self.storage_bucket).get_public_url(file_path)
                
                uploaded_photos.append({
                    'url': public_url,
                    'path': file_path
                })
            
            # Add photos to post
            await self.post_repository.add_photos_to_post(post_id, uploaded_photos)
            return uploaded_photos
            
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to upload photos: {str(e)}")
    
    async def _upload_photos(self, photos: List[str], post_id: int) -> List[dict]:
        """Upload base64 encoded photos to Supabase storage"""
        uploaded_photos = []
        
        for i, photo_data in enumerate(photos):
            try:
                # Decode base64 image
                if photo_data.startswith('data:image/'):
                    # Remove data URL prefix
                    header, encoded = photo_data.split(',', 1)
                    image_data = base64.b64decode(encoded)
                    # Extract file type from header
                    file_extension = header.split('/')[1].split(';')[0]
                else:
                    # Assume it's pure base64
                    image_data = base64.b64decode(photo_data)
                    file_extension = 'jpg'  # Default
                
                # Generate unique filename
                filename = f"post_{post_id}_{uuid.uuid4()}.{file_extension}"
                file_path = f"posts/{post_id}/{filename}"
                
                # Upload to Supabase storage
                result = self.supabase.storage.from_(self.storage_bucket).upload(
                    path=file_path,
                    file=image_data,
                    file_options={"content-type": f"image/{file_extension}"}
                )
                
                if result.status_code != 200:
                    raise Exception(f"Upload failed for photo {i+1}")
                
                # Get public URL
                public_url = self.supabase.storage.from_(self.storage_bucket).get_public_url(file_path)
                
                uploaded_photos.append({
                    'url': public_url,
                    'path': file_path
                })
                
            except Exception as e:
                # Clean up already uploaded photos if one fails
                for uploaded in uploaded_photos:
                    try:
                        self.supabase.storage.from_(self.storage_bucket).remove([uploaded['path']])
                    except:
                        pass
                raise Exception(f"Failed to upload photo {i+1}: {str(e)}")
        
        return uploaded_photos
    
    async def get_post(self, post_id: int) -> PostWithUser:
        """Get a single post by ID"""
        post = await self.post_repository.get_post_by_id(post_id)
        if not post:
            raise HTTPException(status_code=404, detail="Post not found")
        return self._convert_to_post_with_user(post)
    
    async def get_user_posts(self, user_id: int, page: int = 1, page_size: int = 20) -> PostListResponse:
        """Get posts for a specific user with pagination"""
        skip = (page - 1) * page_size
        posts = await self.post_repository.get_posts_by_user(user_id, skip, page_size)
        total = await self.post_repository.count_user_posts(user_id)
        
        return PostListResponse(
            posts=[self._convert_to_post_with_user(post) for post in posts],
            total=total,
            page=page,
            page_size=page_size,
            total_pages=math.ceil(total / page_size)
        )
    
    async def get_all_posts(self, page: int = 1, page_size: int = 20) -> PostListResponse:
        """Get all posts with pagination"""
        skip = (page - 1) * page_size
        posts = await self.post_repository.get_all_posts(skip, page_size)
        total = await self.post_repository.count_all_posts()
        
        return PostListResponse(
            posts=[self._convert_to_post_with_user(post) for post in posts],
            total=total,
            page=page,
            page_size=page_size,
            total_pages=math.ceil(total / page_size)
        )
    
    async def update_post(self, post_id: int, post_data: PostUpdate, user_id: int) -> PostWithUser:
        """Update a post"""
        post = await self.post_repository.update_post(post_id, post_data, user_id)
        if not post:
            raise HTTPException(status_code=404, detail="Post not found or not authorized")
        
        # Get updated post with relations
        updated_post = await self.post_repository.get_post_by_id(post.id)
        return self._convert_to_post_with_user(updated_post)
    
    async def delete_post(self, post_id: int, user_id: int) -> bool:
        """Delete a post and its photos"""
        # Get post first to get photo paths
        post = await self.post_repository.get_post_by_id(post_id)
        if not post or post.user_id != user_id:
            raise HTTPException(status_code=404, detail="Post not found or not authorized")
        
        # Delete photos from storage
        if post.photos:
            photo_paths = [photo.photo_path for photo in post.photos]
            try:
                self.supabase.storage.from_(self.storage_bucket).remove(photo_paths)
            except Exception as e:
                # Log error but don't fail the deletion
                print(f"Warning: Failed to delete some photos from storage: {e}")
        
        # Soft delete the post
        return await self.post_repository.delete_post(post_id, user_id)
    
    def _convert_to_post_with_user(self, post: Post) -> PostWithUser:
        """Convert Post model to PostWithUser response"""
        user_info = {
            'id': post.user.id,
            'email': post.user.email
        }
        
        post_dict = {
            'id': post.id,
            'user_id': post.user_id,
            'content': post.content,
            'image_url': post.image_url,
            'image_path': post.image_path,
            'is_active': post.is_active,
            'created_at': post.created_at,
            'updated_at': post.updated_at,
            'photos': [
                {
                    'id': photo.id,
                    'post_id': photo.post_id,
                    'photo_url': photo.photo_url,
                    'photo_path': photo.photo_path,
                    'is_primary': photo.is_primary,
                    'created_at': photo.created_at
                }
                for photo in (post.photos or [])
            ],
            'user': user_info
        }
        
        return PostWithUser(**post_dict)