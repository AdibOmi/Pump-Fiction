# Posts API Documentation

This document describes the backend API endpoints for the social media posts feature.

## Overview

The posts API allows users to:
- Create posts with text content and photos
- Upload photos to Supabase storage
- View posts on user profiles
- Manage their own posts (update/delete)

## Database Tables

### posts
- `id`: Primary key
- `user_id`: Foreign key to users table
- `content`: Text content of the post
- `image_url`: URL to main image (if single image)
- `image_path`: Storage path for main image
- `is_active`: Soft delete flag
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp

### post_photos
- `id`: Primary key
- `post_id`: Foreign key to posts table
- `photo_url`: Public URL to the photo
- `photo_path`: Storage path in Supabase
- `is_primary`: Whether this is the main photo
- `created_at`: Upload timestamp

## API Endpoints

### POST /posts/
Create a new post with form data and file uploads.

**Request:**
- Form data: `content` (optional text)
- Files: `photos` (multiple image files)

**Response:**
```json
{
  "id": 1,
  "user_id": 1,
  "content": "Hello world!",
  "image_url": null,
  "image_path": null,
  "is_active": true,
  "created_at": "2023-01-01T00:00:00",
  "updated_at": "2023-01-01T00:00:00",
  "photos": [
    {
      "id": 1,
      "post_id": 1,
      "photo_url": "https://supabase.url/storage/v1/object/public/post-photos/posts/1/image.jpg",
      "photo_path": "posts/1/image.jpg",
      "is_primary": true,
      "created_at": "2023-01-01T00:00:00"
    }
  ],
  "user": {
    "id": 1,
    "email": "user@example.com"
  }
}
```

### POST /posts/base64
Create a post with base64 encoded images.

**Request:**
```json
{
  "content": "Hello world!",
  "photos": [
    "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD...",
    "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA..."
  ]
}
```

### GET /posts/
Get all posts with pagination.

**Query Parameters:**
- `page`: Page number (default: 1)
- `page_size`: Items per page (default: 20, max: 100)

**Response:**
```json
{
  "posts": [...],
  "total": 100,
  "page": 1,
  "page_size": 20,
  "total_pages": 5
}
```

### GET /posts/user/{user_id}
Get posts for a specific user (for profile page).

**Query Parameters:**
- `page`: Page number (default: 1)
- `page_size`: Items per page (default: 20, max: 100)

### GET /posts/my-posts
Get current user's posts.

**Requires Authentication**

### GET /posts/{post_id}
Get a specific post by ID.

### PUT /posts/{post_id}
Update a post (only by owner).

**Request:**
```json
{
  "content": "Updated content",
  "is_active": true
}
```

### POST /posts/{post_id}/photos
Add photos to an existing post.

**Request:**
- Files: `photos` (multiple image files)

### DELETE /posts/{post_id}
Delete a post (only by owner). Soft delete - sets `is_active` to false.

## Storage Configuration

### Supabase Storage Bucket
- Bucket name: `post-photos`
- Structure: `posts/{post_id}/{filename}`
- Public access for viewing
- File size limit: 50MB per file
- Allowed types: JPEG, PNG, GIF, WebP

### Setup Steps

1. **Create Database Tables:**
   ```sql
   -- Run the migration file
   psql -f migrations/add_posts_tables.sql
   ```

2. **Setup Storage:**
   ```bash
   python setup_storage.py
   ```

3. **Test Setup:**
   ```bash
   python test_setup.py
   ```

## Frontend Integration

### Profile Page Posts
To display posts on a user's profile page:

```javascript
// Fetch user posts
const response = await fetch(`/api/posts/user/${userId}?page=1&page_size=10`);
const data = await response.json();

// Display posts
data.posts.forEach(post => {
  // Show post content
  console.log(post.content);
  
  // Show photos
  post.photos.forEach(photo => {
    // Display image using photo.photo_url
    const img = document.createElement('img');
    img.src = photo.photo_url;
  });
});
```

### Create Post
```javascript
// Create post with files
const formData = new FormData();
formData.append('content', 'My new post!');
formData.append('photos', file1);
formData.append('photos', file2);

const response = await fetch('/api/posts/', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`
  },
  body: formData
});
```

## Security

- All endpoints require authentication except for viewing posts
- Users can only update/delete their own posts
- Photos are stored in user-specific folders
- RLS policies control storage access
- File type validation on upload
- File size limits enforced

## Error Handling

Common error responses:
- `400`: Bad request (invalid file type, missing data)
- `401`: Unauthorized (invalid token)
- `403`: Forbidden (not post owner)
- `404`: Post not found
- `500`: Server error (storage upload failed)

## Performance Considerations

- Pagination for large datasets
- Indexes on user_id, created_at, and is_active
- Lazy loading of photos
- CDN-style access through Supabase storage
- Database connection pooling