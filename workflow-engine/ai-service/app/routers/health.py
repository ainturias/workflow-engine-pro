from fastapi import APIRouter

router = APIRouter()


@router.get("/health")
async def health_check():
    """Verificar que el servicio de IA está funcionando."""
    return {"status": "ok", "service": "ai-service"}
