"""
Debug script to verify Supabase connection and RLS policies
Run this to check if the service key is working properly
"""
import asyncio
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent))

from app.core.config import settings
from app.core.supabase_client import get_supabase_client


def test_supabase_connection():
    """Test basic Supabase connection and permissions"""
    print("=" * 60)
    print("SUPABASE CONNECTION TEST")
    print("=" * 60)
    
    # Check environment variables
    print("\n1. Checking environment variables...")
    print(f"   SUPABASE_URL: {settings.SUPABASE_URL[:30]}..." if len(settings.SUPABASE_URL) > 30 else settings.SUPABASE_URL)
    print(f"   SERVICE_KEY length: {len(settings.SUPABASE_SERVICE_KEY)} chars")
    print(f"   SERVICE_KEY prefix: {settings.SUPABASE_SERVICE_KEY[:20]}...")
    
    # Check if it's actually the service key (should start with 'eyJ')
    if not settings.SUPABASE_SERVICE_KEY.startswith('eyJ'):
        print("   ⚠️  WARNING: Service key should start with 'eyJ' (JWT format)")
        print("   Make sure you're using the SERVICE ROLE KEY, not the ANON KEY!")
        return False
    
    # Test Supabase client
    print("\n2. Testing Supabase client...")
    try:
        client = get_supabase_client()
        print("   ✅ Client initialized successfully")
    except Exception as e:
        print(f"   ❌ Failed to initialize client: {e}")
        return False
    
    # Test table access
    print("\n3. Testing 'users' table access...")
    try:
        # Try to read from users table (should work with service key even if empty)
        response = client.table("users").select("*").limit(1).execute()
        print(f"   ✅ Can read from users table (found {len(response.data)} rows)")
    except Exception as e:
        print(f"   ❌ Failed to read from users table: {e}")
        print("\n   Possible issues:")
        print("   - Table 'users' doesn't exist in public schema")
        print("   - RLS policies are blocking even service role")
        print("   - Service key is incorrect")
        return False
    
    # Test insert permission
    print("\n4. Testing insert permission...")
    try:
        # Try to insert a test record (will fail if user exists, but that's ok)
        test_data = {
            "id": "00000000-0000-0000-0000-000000000000",  # Dummy UUID
            "email": "test@test.com",
            "full_name": "Test User",
            "role": "normal_user"
        }
        response = client.table("users").insert(test_data).execute()
        print("   ✅ Insert test successful (you may need to delete this test record)")
        
        # Clean up test record
        try:
            client.table("users").delete().eq("id", test_data["id"]).execute()
            print("   ✅ Cleaned up test record")
        except:
            pass
            
    except Exception as e:
        error_str = str(e)
        if "duplicate" in error_str.lower() or "unique" in error_str.lower():
            print("   ⚠️  Test record already exists (this is okay)")
        elif "violates row-level security" in error_str.lower():
            print(f"   ❌ RLS is blocking insert: {e}")
            print("\n   SOLUTION: Run this SQL in Supabase SQL Editor:")
            print("   " + "=" * 50)
            print("""
   -- Disable RLS temporarily to test
   ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
   
   -- Then try signup again
   -- If it works, re-enable RLS and fix policies:
   ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
   
   -- Create proper service role policy
   DROP POLICY IF EXISTS "service_role_all" ON public.users;
   CREATE POLICY "service_role_all" ON public.users
     AS PERMISSIVE FOR ALL TO service_role
     USING (true) WITH CHECK (true);
            """)
            print("   " + "=" * 50)
            return False
        else:
            print(f"   ❌ Insert failed: {e}")
            return False
    
    print("\n" + "=" * 60)
    print("✅ ALL TESTS PASSED")
    print("=" * 60)
    print("\nYour Supabase setup is working correctly!")
    return True


if __name__ == "__main__":
    success = test_supabase_connection()
    sys.exit(0 if success else 1)
