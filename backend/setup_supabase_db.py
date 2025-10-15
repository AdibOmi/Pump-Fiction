"""
Helper script to set up Supabase database connection
This script helps you get the correct DATABASE_URL for your .env file
"""

def get_supabase_connection_info():
    """
    Instructions to get your Supabase PostgreSQL connection string
    """
    print("=" * 70)
    print("SUPABASE DATABASE CONNECTION SETUP")
    print("=" * 70)
    print()
    print("To get your Supabase PostgreSQL connection string:")
    print()
    print("1. Go to: https://supabase.com/dashboard/project/nuvjjkvcjldrmxsbkibp")
    print()
    print("2. Navigate to: Settings → Database")
    print()
    print("3. Scroll down to 'Connection String' section")
    print()
    print("4. Select the 'URI' tab")
    print()
    print("5. Copy the connection string that looks like:")
    print("   postgresql://postgres.nuvjjkvcjldrmxsbkibp:[YOUR-PASSWORD]@aws-0-us-east-1.pooler.supabase.com:6543/postgres")
    print()
    print("6. IMPORTANT: Replace [YOUR-PASSWORD] with your actual database password")
    print()
    print("7. For async SQLAlchemy, change 'postgresql://' to 'postgresql+asyncpg://'")
    print()
    print("=" * 70)
    print("EXAMPLE .env FILE ENTRY:")
    print("=" * 70)
    print()
    print("DATABASE_URL=postgresql+asyncpg://postgres.nuvjjkvcjldrmxsbkibp:[PASSWORD]@aws-0-us-east-1.pooler.supabase.com:6543/postgres")
    print()
    print("=" * 70)
    print()
    print("NOTE: If you don't know your database password:")
    print("  - Go to Settings → Database → Database Password")
    print("  - Click 'Reset Database Password' to create a new one")
    print("=" * 70)
    print()


if __name__ == "__main__":
    get_supabase_connection_info()
