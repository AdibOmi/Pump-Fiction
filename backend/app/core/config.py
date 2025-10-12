from pydantic_settings import BaseSettings
from pydantic import Field


class Settings(BaseSettings):
    SECRET_KEY: str = 'change-me'
    ALGORITHM: str = 'HS256'
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    DATABASE_URL: str = 'sqlite+aiosqlite:///./test.db'
    
    # Supabase settings
    SUPABASE_URL: str = Field(..., env='SUPABASE_URL')
    SUPABASE_SERVICE_KEY: str = Field(..., env='SUPABASE_SERVICE_KEY')
    
    class Config:
        env_file = '.env'
        case_sensitive = True


settings = Settings()
