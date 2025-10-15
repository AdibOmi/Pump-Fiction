-- Migration to add posts and post_photos tables
-- Run this after creating the tables in your database

-- Create posts table
CREATE TABLE IF NOT EXISTS posts (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT,
    image_url VARCHAR,
    image_path VARCHAR,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create post_photos table
CREATE TABLE IF NOT EXISTS post_photos (
    id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    photo_url VARCHAR NOT NULL,
    photo_path VARCHAR NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_active ON posts(is_active);
CREATE INDEX IF NOT EXISTS idx_post_photos_post_id ON post_photos(post_id);
CREATE INDEX IF NOT EXISTS idx_post_photos_primary ON post_photos(is_primary);

-- Add updated_at trigger for posts table
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_posts_updated_at ON posts;
CREATE TRIGGER update_posts_updated_at
    BEFORE UPDATE ON posts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


-- Policy for viewing post photos (anyone can view)
CREATE POLICY "Anyone can view post photos" ON storage.objects
FOR SELECT TO public
USING (bucket_id = 'post-photos');

-- Policy for uploading post photos (authenticated users only)
CREATE POLICY "Authenticated users can upload post photos" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'post-photos');

-- Policy for updating post photos (users can update their own photos)
CREATE POLICY "Users can update their own post photos" ON storage.objects
FOR UPDATE TO authenticated
USING (bucket_id = 'post-photos');

-- Policy for deleting post photos (users can delete their own photos)
CREATE POLICY "Users can delete their own post photos" ON storage.objects
FOR DELETE TO authenticated
USING (bucket_id = 'post-photos');

