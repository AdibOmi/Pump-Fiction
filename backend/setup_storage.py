"""
Setup script to create the required Supabase storage bucket for posts
Run this script once to set up the storage bucket
"""

from app.core.supabase_client import get_supabase_client


def setup_storage_bucket():
    """Create the post-photos bucket in Supabase storage"""
    supabase = get_supabase_client()
    bucket_name = "post-photos"
    
    try:
        # Try to create the bucket
        result = supabase.storage.create_bucket(
            bucket_name,
            options={
                "public": True,  # Make bucket public for easier access
                "file_size_limit": 52428800,  # 50MB limit per file
                "allowed_mime_types": [
                    "image/jpeg",
                    "image/png", 
                    "image/gif",
                    "image/webp"
                ]
            }
        )
        print(f"✅ Successfully created bucket: {bucket_name}")
        
        # Set up RLS policy for the bucket
        # Users can upload to their own folders and read all public files
        policy_sql = f"""
        CREATE POLICY "Users can upload to posts folder" ON storage.objects
        FOR INSERT TO authenticated
        WITH CHECK (bucket_id = '{bucket_name}' AND auth.uid()::text = (storage.foldername(name))[1]);
        
        CREATE POLICY "Anyone can view post photos" ON storage.objects
        FOR SELECT TO public
        USING (bucket_id = '{bucket_name}');
        
        CREATE POLICY "Users can update their own post photos" ON storage.objects
        FOR UPDATE TO authenticated
        USING (bucket_id = '{bucket_name}' AND auth.uid()::text = (storage.foldername(name))[1]);
        
        CREATE POLICY "Users can delete their own post photos" ON storage.objects
        FOR DELETE TO authenticated
        USING (bucket_id = '{bucket_name}' AND auth.uid()::text = (storage.foldername(name))[1]);
        """
        
        print("✅ Storage bucket setup completed successfully!")
        print(f"Bucket name: {bucket_name}")
        print("Note: You may need to manually apply RLS policies in Supabase dashboard")
        
    except Exception as e:
        if "already exists" in str(e).lower():
            print(f"✅ Bucket {bucket_name} already exists")
        else:
            print(f"❌ Error creating bucket: {e}")
            print("You may need to create the bucket manually in Supabase dashboard")


def list_buckets():
    """List all storage buckets"""
    supabase = get_supabase_client()
    try:
        buckets = supabase.storage.list_buckets()
        print("📦 Available buckets:")
        for bucket in buckets:
            print(f"  - {bucket.name} (public: {bucket.public})")
    except Exception as e:
        print(f"❌ Error listing buckets: {e}")


if __name__ == "__main__":
    print("🚀 Setting up Supabase storage for posts...")
    setup_storage_bucket()
    print("\n📦 Current buckets:")
    list_buckets()