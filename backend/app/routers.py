from fastapi import APIRouter
from .controllers import user_controller, auth_controller, ai_chat_controller, post_controller, user_profile_controller, tracker_controller

router = APIRouter()

# Authentication routes (no prefix, auth_controller has /auth prefix)
router.include_router(auth_controller.router)

# User routes (keeping for backward compatibility, but should be secured)
router.include_router(user_controller.router)

# User Profile routes
router.include_router(user_profile_controller.router)

# AI Chat routes (Phase 1 - AI Chatbot)
router.include_router(ai_chat_controller.router)

# Post routes (Social media posts)
router.include_router(post_controller.router)

# Tracker routes (Fitness progress tracking)
router.include_router(tracker_controller.router)
