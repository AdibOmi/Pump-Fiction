from pydantic_settings import BaseSettings
from pydantic import Field


class Settings(BaseSettings):
    SECRET_KEY: str = 'change-me'
    ALGORITHM: str = 'HS256'
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60

    # Database URL - Will be constructed from Supabase connection string
    DATABASE_URL: str = Field(..., env='DATABASE_URL')

    # Supabase settings
    SUPABASE_URL: str = Field(..., env='SUPABASE_URL')
    SUPABASE_SERVICE_KEY: str = Field(..., env='SUPABASE_SERVICE_KEY')

    # Gemini AI settings
    GEMINI_API_KEY: str = Field(..., env='GEMINI_API_KEY')
    
    class Config:
        env_file = '.env'
        case_sensitive = True


settings = Settings()
