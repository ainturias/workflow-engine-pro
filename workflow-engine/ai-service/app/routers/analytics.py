from fastapi import APIRouter

router = APIRouter()


@router.get("/bottlenecks")
async def detect_bottlenecks():
    """Endpoint placeholder para detección de cuellos de botella."""
    return {"message": "Bottleneck detection endpoint - pendiente de implementación"}
