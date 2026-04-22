# 🚀 Workflow Engine Pro

Sistema avanzado de gestión de trámites y motor de flujos empresariales con diseño moderno, editor visual y asistencia por IA.

## 🛠️ Tech Stack
- **Backend:** Java 21 + Spring Boot 3.5.x + MongoDB
- **Frontend:** Angular 19 + SCSS (Glassmorphism UI)
- **IA Service:** Python 3.12 + FastAPI + HuggingFace/OpenAI
- **Seguridad:** JWT + Role Based Access Control (RBAC)

## 📌 Funcionalidades Implementadas

### Bloque 1: Autenticación y Seguridad 🔐
- Registro e inicio de sesión de usuarios.
- Roles de usuario: `ADMIN`, `DISEÑADOR`, `FUNCIONARIO`, `CLIENTE`.
- Protecciones de rutas (Guards) e interceptores de tokens.

### Bloque 2: Configuración Organizacional 🏢
- Gestión de Departamentos y Actividades.
- Asignación dinámica de funcionarios a departamentos.
- Definición de formularios base para actividades.

### Bloque 3: Diseñador Visual de Políticas 🎨
- Canvas interactivo basado en SVG.
- Drag & drop de nodos (Inicio, Actividad, Decisión, Fork, Join, Fin).
- Sistema de **Swimlanes** (Calles) por departamento.
- Configuración de transiciones condicionales.

### Bloque 4: Motor de Workflow (Core) ⚡
- Instanciación de trámites a partir de políticas publicadas.
- Evaluación de condiciones en tiempo real (monto > 100, etc.).
- Gestión de estados y línea de tiempo (Timeline) de cada trámite.
- Soporte para flujos secuenciales y ramificaciones.

## 🚀 Próximamente
- **Bloque 5:** Integración de IA para análisis de riesgos y chatbot de asistencia.
- **Bloque 6:** Dashboard estadístico y reportes avanzados.

---
Desarrollado como parte del proyecto de Ingeniería de Software.
