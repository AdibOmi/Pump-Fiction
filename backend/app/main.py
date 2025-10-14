from fastapi import FastAPI
from .routers import router

def create_app() -> FastAPI:
    app = FastAPI(title='Pump-Fiction API')
    app.include_router(router)
    return app

app = create_app()
