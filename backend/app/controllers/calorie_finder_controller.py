"""
Calorie Finder Controller
REST API endpoints for calorie estimation from food images
"""
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from typing import Annotated
from ..schemas.calorie_finder_schema import CalorieFinderResponse
from ..services.calorie_finder_service import CalorieFinderService
from ..core.dependencies import get_current_user


router = APIRouter(prefix='/calorie-finder', tags=['Calorie Finder'])


def _get_calorie_finder_service() -> CalorieFinderService:
    """Dependency to get calorie finder service"""
    return CalorieFinderService()


@router.post('/estimate', response_model=CalorieFinderResponse, status_code=status.HTTP_200_OK)
async def estimate_calories(
    image: Annotated[UploadFile, File(description="Food image for calorie estimation")],
    serving_size: Annotated[str, Form(description="Serving size (e.g., '2 pieces', '150 grams', '1 cup')")],
    current_user: dict = Depends(get_current_user),
    service: CalorieFinderService = Depends(_get_calorie_finder_service)
):
    """
    Estimate calories from a food image

    - **image**: Upload a food image (JPEG, PNG, etc.)
    - **serving_size**: Specify the serving size (e.g., "2 pieces", "150 grams", "1 cup")

    Returns the estimated calorie count for the specified serving size
    """
    try:
        # Validate file type
        if not image.content_type or not image.content_type.startswith('image/'):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="File must be an image (JPEG, PNG, etc.)"
            )

        # Read image data
        image_data = await image.read()

        # Validate image size (max 10MB)
        max_size = 10 * 1024 * 1024  # 10MB
        if len(image_data) > max_size:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Image size must be less than 10MB"
            )

        # Estimate calories using Gemini
        result = await service.estimate_calories(
            image_data=image_data,
            serving_size=serving_size
        )

        return CalorieFinderResponse(**result)

    except HTTPException:
        raise
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to estimate calories: {str(e)}"
        )
