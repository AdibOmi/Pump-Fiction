from supabase import create_client, Client
from .config import settings

# Initialize Supabase client with service key for backend operations
# The service key should have full admin access and bypass RLS
supabase: Client = create_client(
    settings.SUPABASE_URL,
    settings.SUPABASE_SERVICE_KEY
)


def get_supabase_client() -> Client:
    """Get Supabase client instance"""
    return supabase
