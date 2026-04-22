from fastapi import APIRouter

router = APIRouter()


@router.post("/transcribe")
async def transcribe_audio():
    """Endpoint placeholder para Speech-to-Text."""
    return {"message": "Speech-to-Text endpoint - pendiente de implementación"}
