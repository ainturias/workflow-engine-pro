# 🏗️ Stack Tecnológico y Arquitectura del Sistema

---

## 1. Stack Tecnológico Definido

### Backend
| Tecnología | Uso | Justificación |
|-----------|-----|---------------|
| **Spring Boot (Java)** | Backend core — API principal, motor de workflow, lógica de negocio | Obligatorio por el profesor. Robusto para sistemas empresariales |
| **FastAPI (Python)** | Microservicios de IA — procesamiento de voz, análisis de cuellos de botella, prompts | Obligatorio. Ideal para ML/IA por el ecosistema Python |

### Base de Datos
| Tecnología | Uso |
|-----------|-----|
| **MongoDB** | Base de datos principal — almacenamiento de políticas de negocio, trámites, formularios, historial |

> **Nota sobre MongoDB:** Al ser NoSQL, los diagramas de "modelo de datos" se adaptarán a documentos/colecciones en lugar del modelo relacional clásico.

### Frontend
| Tecnología | Uso |
|-----------|-----|
| **Angular** | Aplicación web — diseñador de políticas, panel de administrador, panel de funcionario, monitoreo |

### Móvil
| Tecnología | Uso |
|-----------|-----|
| **Flutter** | App móvil para funcionarios y para el cliente final (notificaciones push) |

### Infraestructura y DevOps
| Tecnología | Uso |
|-----------|-----|
| **Docker** | Contenedores para todos los servicios (obligatorio) |
| **AWS / Google Cloud / Azure** | Despliegue en la nube (elegir uno) |
| **Git + GitHub** | Control de versiones |
| **Jira / Trello** | Gestión de proyectos |

---

## 2. Arquitectura Propuesta (Alto Nivel)

```
┌─────────────────────────────────────────────────────────────────────┐
│                        CLIENTES                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐   │
│  │  Angular Web  │  │ Flutter App  │  │ Flutter App (Cliente)    │   │
│  │  (Admin +     │  │ (Funcionario)│  │ (Notificaciones push)    │   │
│  │  Funcionario) │  │              │  │                          │   │
│  └──────┬───────┘  └──────┬───────┘  └────────────┬─────────────┘   │
│         │                 │                        │                 │
└─────────┼─────────────────┼────────────────────────┼─────────────────┘
          │                 │                        │
          ▼                 ▼                        ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     API GATEWAY / LOAD BALANCER                      │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
          ┌───────────────┼───────────────────┐
          ▼                                   ▼
┌───────────────────────────────┐  ┌──────────────────────────────┐
│   SPRING BOOT (Core API)      │  │   FASTAPI (Microservicio IA) │
│                               │  │                              │
│  • Motor de Workflow          │  │  • Speech-to-Text (STT)      │
│  • Gestión de Trámites        │  │  • Análisis de Prompts       │
│  • Gestión de Políticas       │  │  • Detección de cuellos      │
│  • Autenticación / Roles      │  │    de botella (ML)           │
│  • Notificaciones             │  │  • Procesamiento NLP         │
│  • Formularios dinámicos      │  │  • Agente asistente          │
│  • API REST / WebSockets      │  │                              │
│                               │  │                              │
└───────────┬───────────────────┘  └──────────┬───────────────────┘
            │                                  │
            ▼                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          MONGODB                                     │
│                                                                      │
│  Colecciones principales:                                            │
│  • empresas          • departamentos       • actividades             │
│  • politicas_negocio • tramites            • formularios             │
│  • usuarios          • notificaciones      • historial_tramites      │
│  • metricas          • sesiones_colab                                │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 3. Comunicación en Tiempo Real

Para lograr la colaboración en tiempo real y las actualizaciones automáticas:

| Tecnología | Uso |
|-----------|-----|
| **WebSockets (Spring Boot)** | Actualizaciones en tiempo real del estado de trámites, notificaciones push al panel del funcionario |
| **Socket.IO o WebSockets (Angular)** | Recibir cambios en tiempo real en el frontend |
| **WebSockets colaborativos** | Para el editor colaborativo de políticas de negocio (similar a Google Docs) |

---

## 4. Estructura de Microservicios (Docker)

```yaml
# Servicios Docker propuestos
services:
  # Backend principal
  - workflow-api (Spring Boot) → Puerto 8080
  
  # Microservicio de IA
  - ai-service (FastAPI) → Puerto 8000
  
  # Base de datos
  - mongodb → Puerto 27017
  
  # Frontend web
  - web-app (Angular) → Puerto 4200 (dev) / 80 (prod con Nginx)
  
  # Posible: Message broker para eventos
  - rabbitmq / redis → Para cola de eventos y notificaciones
```

---

## 5. Módulos del Sistema

### 5.1 Módulo de Configuración (Admin)
- CRUD de Empresas
- CRUD de Departamentos
- CRUD de Actividades
- Gestión de Usuarios y Roles

### 5.2 Módulo de Diseño de Políticas de Negocio (Admin/Diseñador)
- Editor visual de diagramas (tipo canvas/drag-and-drop)
- Soporte para swimlanes (calles por departamento)
- Elementos: actividades, flujos, condiciones, bifurcaciones, uniones, fork/join
- Creación vía prompts de texto
- Creación vía prompts de voz/audio
- **Colaboración en tiempo real** (múltiples usuarios editando simultáneamente)
- Guardar/cargar/editar políticas

### 5.3 Módulo de Ejecución de Trámites (Funcionario)
- Panel/Monitor del funcionario con estados (pendiente, en proceso, completado)
- Selección de política de negocio para iniciar trámite
- Formularios dinámicos por actividad
- Llenado de formulario por:
  - Escritura manual
  - Dictado por voz (Speech-to-Text)
- Marcar actividad como completada → enrutamiento automático
- Historial de trámites

### 5.4 Módulo de Motor de Workflow
- Ejecutar la lógica de flujos (secuencial, condicional, iterativo, paralelo)
- Enrutamiento automático entre departamentos/actividades
- Evaluación de condiciones para bifurcaciones
- Gestión de flujos paralelos (fork/join)
- Actualización automática de estados

### 5.5 Módulo de Notificaciones
- Notificaciones push (móvil)
- Notificaciones en tiempo real (web - WebSockets)
- Alertas por cada etapa del trámite

### 5.6 Módulo de Monitoreo y Analíticas
- Tiempos de atención por actividad
- Tiempos de atención por funcionario
- Detección de cuellos de botella (con IA)
- Comparación de eficiencia entre funcionarios
- Dashboards con métricas y gráficos

### 5.7 Módulo de Asistente/Agente Inteligente
- Agente conversacional que guía al usuario
- Detecta qué está haciendo el usuario en todo momento
- Ayuda contextual
- Posible implementación con n8n o similar

---

## 6. Modelo de Datos (MongoDB — Colecciones Principales)

### Empresa
```json
{
  "_id": "ObjectId",
  "nombre": "String",
  "descripcion": "String",
  "departamentos": ["ref_departamento_id"],
  "createdAt": "Date",
  "updatedAt": "Date"
}
```

### Departamento
```json
{
  "_id": "ObjectId",
  "nombre": "String",
  "empresa_id": "ref_empresa_id",
  "funcionarios": ["ref_usuario_id"],
  "descripcion": "String"
}
```

### Usuario
```json
{
  "_id": "ObjectId",
  "nombre": "String",
  "email": "String",
  "password": "String (hashed)",
  "rol": "ADMIN | DISEÑADOR | FUNCIONARIO | CLIENTE",
  "departamento_id": "ref_departamento_id",
  "activo": "Boolean"
}
```

### Política de Negocio
```json
{
  "_id": "ObjectId",
  "nombre": "String",
  "descripcion": "String",
  "empresa_id": "ref_empresa_id",
  "estado": "BORRADOR | ACTIVA | INACTIVA",
  "diagrama": {
    "nodos": [
      {
        "id": "String",
        "tipo": "INICIO | ACTIVIDAD | CONDICION | FORK | JOIN | FIN",
        "nombre": "String",
        "departamento_id": "ref_departamento_id",
        "formulario_template": { /* campos del formulario */ },
        "posicion": { "x": "Number", "y": "Number" }
      }
    ],
    "transiciones": [
      {
        "origen_id": "String",
        "destino_id": "String",
        "condicion": "String (opcional)",
        "etiqueta": "String"
      }
    ],
    "swimlanes": [
      {
        "departamento_id": "ref_departamento_id",
        "posicion_y": "Number",
        "alto": "Number"
      }
    ]
  },
  "createdAt": "Date",
  "updatedAt": "Date",
  "createdBy": "ref_usuario_id"
}
```

### Trámite (Instancia de una política)
```json
{
  "_id": "ObjectId",
  "politica_id": "ref_politica_id",
  "solicitante": {
    "nombre": "String",
    "contacto": "String"
  },
  "estado": "EN_CURSO | COMPLETADO | CANCELADO",
  "nodo_actual": ["String (id del nodo activo)"],
  "historial": [
    {
      "nodo_id": "String",
      "funcionario_id": "ref_usuario_id",
      "fecha_inicio": "Date",
      "fecha_fin": "Date",
      "formulario_datos": { /* datos llenados */ },
      "observaciones": "String"
    }
  ],
  "createdAt": "Date",
  "updatedAt": "Date"
}
```

### Notificación
```json
{
  "_id": "ObjectId",
  "usuario_id": "ref_usuario_id",
  "tipo": "NUEVA_TAREA | TRAMITE_COMPLETADO | ALERTA",
  "mensaje": "String",
  "leida": "Boolean",
  "tramite_id": "ref_tramite_id",
  "createdAt": "Date"
}
```

---

## 7. Decisiones Técnicas Pendientes

| Decisión | Opciones | Recomendación |
|----------|----------|---------------|
| Cloud Provider | AWS / GCP / Azure | AWS (más documentación, free tier generoso) |
| Editor visual de diagramas | Librería Canvas propia / jsPlumb / GoJS / React Flow adaptado a Angular | Evaluar GoJS o una librería compatible con Angular |
| Speech-to-Text | Google Cloud Speech API / Whisper (OpenAI) / Web Speech API | Whisper por ser open-source y correr en FastAPI |
| Message broker | RabbitMQ / Redis Pub/Sub / Kafka | Redis Pub/Sub (simple, suficiente para este caso) |
| Autenticación | JWT + Spring Security | JWT es el estándar |
| Editor colaborativo | WebSockets custom / Yjs / Socket.IO | Yjs + WebSockets (probado para editores colaborativos) |
