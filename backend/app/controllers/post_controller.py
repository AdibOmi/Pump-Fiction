from fastapi import APIRouter, Depends, HTTPException, File, UploadFile, Form, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from ..core.dependencies import get_db, get_current_user
from ..services.post_service import PostService
from ..schemas.post_schema import PostCreate, PostUpdate, PostWithUser, PostListResponse
from ..schemas.user_schema import UserResponse


router = APIRouter(prefix="/posts", tags=["posts"])


@router.post("/", response_model=PostWithUser)
async def create_post(
    content: Optional[str] = Form(None),
    photos: List[UploadFile] = File(default=[]),
    db: Session = Depends(get_db),
    current_user: UserResponse = Depends(get_current_user)
):
    """Create a new post with optional photos"""
    post_service = PostService(db)
    
    # Create post data
    post_data = PostCreate(content=content)
    
    # Create the post
    post = await post_service.create_post(post_data, current_user.id)
    
    # Upload photos if provided
    if photos and photos[0].filename:  # Check if actual files were uploaded
        await post_service.upload_photos_for_post(photos, post.id, current_user.id)
        # Get updated post with photos
        post = await post_service.get_post(post.id)
    
    return post


@router.post("/base64", response_model=PostWithUser)
async def create_post_with_base64_photos(
    post_data: PostCreate,
    db: Session = Depends(get_db),
    current_user: UserResponse = Depends(get_current_user)
):
    """Create a new post with base64 encoded photos"""
    post_service = PostService(db)
    return await post_service.create_post(post_data, current_user.id)


@router.get("/", response_model=PostListResponse)
async def get_all_posts(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """Get all posts with pagination"""
    post_service = PostService(db)
    return await post_service.get_all_posts(page, page_size)


@router.get("/user/{user_id}", response_model=PostListResponse)
async def get_user_posts(
    user_id: int,
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """Get posts for a specific user (for profile page)"""
    post_service = PostService(db)
    return await post_service.get_user_posts(user_id, page, page_size)


@router.get("/my-posts", response_model=PostListResponse)
async def get_my_posts(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: UserResponse = Depends(get_current_user)
):
    """Get current user's posts"""
    post_service = PostService(db)
    return await post_service.get_user_posts(current_user.id, page, page_size)


@router.get("/{post_id}", response_model=PostWithUser)
async def get_post(
    post_id: int,
    db: Session = Depends(get_db)
):
    """Get a specific post by ID"""
    post_service = PostService(db)
    return await post_service.get_post(post_id)


@router.put("/{post_id}", response_model=PostWithUser)
async def update_post(
    post_id: int,
    post_data: PostUpdate,
    db: Session = Depends(get_db),
    current_user: UserResponse = Depends(get_current_user)
):
    """Update a post (only by owner)"""
    post_service = PostService(db)
    return await post_service.update_post(post_id, post_data, current_user.id)


@router.post("/{post_id}/photos")
async def add_photos_to_post(
    post_id: int,
    photos: List[UploadFile] = File(...),
    db: Session = Depends(get_db),
    current_user: UserResponse = Depends(get_current_user)
):
    """Add photos to an existing post"""
    if not photos or not photos[0].filename:
        raise HTTPException(status_code=400, detail="No photos provided")
    
    post_service = PostService(db)
    uploaded_photos = await post_service.upload_photos_for_post(photos, post_id, current_user.id)
    
    return {
        "message": f"Successfully uploaded {len(uploaded_photos)} photos",
        "photos": uploaded_photos
    }


@router.delete("/{post_id}")
async def delete_post(
    post_id: int,
    db: Session = Depends(get_db),
    current_user: UserResponse = Depends(get_current_user)
):
    """Delete a post (only by owner)"""
    post_service = PostService(db)
    success = await post_service.delete_post(post_id, current_user.id)
    
    if not success:
        raise HTTPException(status_code=404, detail="Post not found or not authorized")
    
    return {"message": "Post deleted successfully"}