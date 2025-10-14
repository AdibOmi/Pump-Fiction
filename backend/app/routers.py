from fastapi import APIRouter
from .controllers import user_controller, auth_controller

router = APIRouter()

# Authentication routes (no prefix, auth_controller has /auth prefix)
router.include_router(auth_controller.router)

# User routes (keeping for backward compatibility, but should be secured)
router.include_router(user_controller.router)
