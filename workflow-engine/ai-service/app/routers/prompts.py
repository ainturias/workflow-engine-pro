from fastapi import APIRouter

router = APIRouter()


@router.post("/process")
async def process_prompt():
    """Endpoint placeholder para procesamiento de prompts del diseñador de workflows."""
    return {"message": "Prompt processing endpoint - pendiente de implementación"}
