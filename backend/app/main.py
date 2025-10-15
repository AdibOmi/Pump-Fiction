from fastapi import FastAPI
from .routers import router
import asyncio

# Fix for Windows event loop with psycopg async
# This must be set before any async database operations
try:
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())
except AttributeError:
    pass  # Not on Windows

def create_app() -> FastAPI:
    app = FastAPI(title='Pump-Fiction API')
    app.include_router(router)
    return app

app = create_app()
