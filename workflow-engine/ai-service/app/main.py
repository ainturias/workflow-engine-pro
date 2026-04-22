from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import health, speech, prompts, analytics

app = FastAPI(
    title="Workflow Engine - AI Service",
    description="Microservicio de IA para el motor de workflows: Speech-to-Text, procesamiento de prompts y análisis de datos.",
    version="1.0.0",
)

# CORS - permitir requests del frontend Angular
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, restringir a dominios específicos
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Registrar routers
app.include_router(health.router, prefix="/api", tags=["Health"])
app.include_router(speech.router, prefix="/api/speech", tags=["Speech-to-Text"])
app.include_router(prompts.router, prefix="/api/prompts", tags=["Prompts"])
app.include_router(analytics.router, prefix="/api/analytics", tags=["Analytics"])
