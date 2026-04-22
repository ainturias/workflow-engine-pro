# 🚀 Workflow Engine — Sistema de Gestión de Trámites

Sistema de gestión de trámites con motor de workflows, diseñado para modelar y ejecutar flujos de trabajo (políticas de negocio) de manera visual y automatizada.

## Stack Tecnológico

| Servicio | Tecnología | Puerto |
|----------|-----------|--------|
| Backend API | Spring Boot 3.5 (Java 21) | 8080 |
| AI Service | FastAPI (Python 3.10) | 8000 |
| Frontend Web | Angular 19 | 4200 |
| App Móvil | Flutter 3.32 | — |
| Base de Datos | MongoDB 7 | 27017 |

## Desarrollo Local

### Requisitos
- Java 21+
- Node.js 22+
- Python 3.10+
- Flutter 3.32+
- Docker + Docker Compose

### Levantar servicios con Docker
```bash
# Levantar MongoDB + Backend + AI Service
docker-compose up -d

# O solo MongoDB para desarrollo local
docker-compose up -d mongodb
```

### Desarrollo individual

**Backend (Spring Boot):**
```bash
cd backend
./mvnw spring-boot:run
```

**AI Service (FastAPI):**
```bash
cd ai-service
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

**Frontend (Angular):**
```bash
cd frontend
npm install
ng serve
```

**Mobile (Flutter):**
```bash
cd mobile
flutter pub get
flutter run
```

## Estructura del Proyecto
```
workflow-engine/
├── backend/          → Spring Boot API (Motor de workflow, Auth, CRUD)
├── ai-service/       → FastAPI (Speech-to-Text, Prompts IA, Analíticas)
├── frontend/         → Angular (Diseñador visual, Panel funcionario, Admin)
├── mobile/           → Flutter (App funcionario + App cliente)
├── docker-compose.yml
└── README.md
```
