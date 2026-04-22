# 🚀 Plan de Desarrollo por Bloques — Workflow Engine

> Cada bloque es una unidad independiente que se puede desarrollar, probar y validar antes de pasar al siguiente.
> **Fecha límite: 28 de abril de 2026** (quedan ~6 días)

---

## Visión General de Bloques

```
BLOQUE 0: Setup del Proyecto (Infraestructura base)
    │
    ▼
BLOQUE 1: Autenticación y Gestión de Usuarios/Roles
    │
    ▼
BLOQUE 2: Módulo de Configuración (Empresas, Departamentos, Actividades)
    │
    ▼
BLOQUE 3: Diseñador Visual de Políticas de Negocio (Editor de Workflows)
    │
    ▼
BLOQUE 4: Motor de Workflow (Ejecución de procesos)
    │
    ▼
BLOQUE 5: Panel del Funcionario + Formularios Dinámicos
    │
    ▼
BLOQUE 6: Notificaciones en Tiempo Real + WebSockets
    │
    ▼
BLOQUE 7: Microservicio de IA (Speech-to-Text, Prompts, Análisis)
    │
    ▼
BLOQUE 8: Monitoreo, Analíticas y Detección de Cuellos de Botella
    │
    ▼
BLOQUE 9: App Móvil (Flutter)
    │
    ▼
BLOQUE 10: Despliegue en la Nube + Docker
    │
    ▼
BLOQUE 11: Agente Inteligente (Guía de usuario)
    │
    ▼
BLOQUE 12: Pulido Final, Testing y Preparación para la Presentación
```

---

## BLOQUE 0: Setup del Proyecto ⚙️
**Prioridad: CRÍTICA** | **Estimación: 2-3 horas**

### Tareas:
- [ ] Crear estructura de carpetas del proyecto
- [ ] Inicializar proyecto Spring Boot (Maven/Gradle)
- [ ] Inicializar proyecto FastAPI
- [ ] Inicializar proyecto Angular
- [ ] Inicializar proyecto Flutter
- [ ] Configurar Docker Compose con todos los servicios
- [ ] Configurar MongoDB (local + Docker)
- [ ] Configurar Git + .gitignore para cada servicio
- [ ] Verificar que todos los servicios levanten correctamente

### Criterio de éxito:
✅ `docker-compose up` levanta todos los servicios
✅ Cada servicio responde en su puerto correspondiente
✅ MongoDB es accesible desde Spring Boot y FastAPI

### Estructura de carpetas propuesta:
```
sw1-1erParcial/
├── informacion/              ← Info original del profesor
├── docs/                     ← Documentos de contexto (.md)
├── workflow-engine/          ← PROYECTO PRINCIPAL
│   ├── backend/              ← Spring Boot (API Core)
│   │   ├── src/
│   │   ├── pom.xml
│   │   └── Dockerfile
│   ├── ai-service/           ← FastAPI (Microservicio IA)
│   │   ├── app/
│   │   ├── requirements.txt
│   │   └── Dockerfile
│   ├── frontend/             ← Angular (Web App)
│   │   ├── src/
│   │   ├── package.json
│   │   └── Dockerfile
│   ├── mobile/               ← Flutter (App Móvil)
│   │   ├── lib/
│   │   └── pubspec.yaml
│   ├── docker-compose.yml
│   └── README.md
└── README.md
```

---

## BLOQUE 1: Autenticación y Gestión de Usuarios/Roles 🔐
**Prioridad: ALTA** | **Estimación: 4-6 horas**

### Tareas:
- [ ] Diseñar modelo de datos de Usuario en MongoDB
- [ ] Implementar registro de usuarios (Spring Boot)
- [ ] Implementar login con JWT (Spring Security)
- [ ] Definir roles: `ADMIN`, `DISEÑADOR`, `FUNCIONARIO`, `CLIENTE`
- [ ] Implementar guards/middleware de autorización por rol
- [ ] Crear pantalla de Login en Angular
- [ ] Crear pantalla de Registro en Angular
- [ ] Implementar interceptor HTTP para JWT en Angular
- [ ] Proteger rutas por rol en Angular

### Criterio de éxito:
✅ Un usuario puede registrarse y loguearse
✅ El JWT se envía en cada request
✅ Rutas protegidas según el rol del usuario
✅ Un ADMIN ve opciones diferentes a un FUNCIONARIO

---

## BLOQUE 2: Módulo de Configuración 🏢
**Prioridad: ALTA** | **Estimación: 3-4 horas**

### Tareas:
- [ ] CRUD de Empresas (Backend + Frontend)
- [ ] CRUD de Departamentos (asociados a una empresa)
- [ ] CRUD de Actividades (plantillas de actividades)
- [ ] Asignar funcionarios a departamentos
- [ ] UI de administración en Angular

### Criterio de éxito:
✅ Se pueden crear empresas con departamentos
✅ Se pueden definir actividades disponibles
✅ Los funcionarios están asignados a departamentos
✅ Validaciones funcionan correctamente

---

## BLOQUE 3: Diseñador Visual de Políticas de Negocio 🎨
**Prioridad: CRÍTICA** | **Estimación: 10-15 horas** (el bloque más complejo)

### Tareas:
- [ ] Investigar y elegir librería para editor de diagramas en Angular
  - Opciones: GoJS, jsPlumb, mxGraph, @angular/cdk drag-drop, custom Canvas
- [ ] Implementar canvas/área de diseño con swimlanes (calles por departamento)
- [ ] Implementar paleta de componentes:
  - Nodo de Inicio
  - Nodo de Actividad
  - Nodo de Decisión/Condición
  - Nodo de Fork (separación paralela)
  - Nodo de Join (unión paralela)
  - Nodo de Fin
- [ ] Implementar drag-and-drop de componentes al canvas
- [ ] Implementar conexiones/transiciones entre nodos
- [ ] Implementar condiciones en las transiciones
- [ ] Configurar formulario plantilla por cada nodo de actividad
- [ ] Guardar la política de negocio en MongoDB (serializar diagrama)
- [ ] Cargar y editar políticas existentes
- [ ] Validar que el diagrama sea un flujo válido

### Sub-tareas de IA (pueden ir en Bloque 7):
- [ ] Crear prompts de texto para construir el diagrama
- [ ] Crear prompts de voz para construir el diagrama

### Sub-tareas de colaboración:
- [ ] Implementar WebSocket para edición colaborativa
- [ ] Sincronización en tiempo real de cambios en el diagrama
- [ ] Cursores de otros usuarios visibles

### Criterio de éxito:
✅ Se puede diseñar un diagrama de actividades con swimlanes
✅ Se soportan los 4 tipos de flujo (secuencial, condicional, iterativo, paralelo)
✅ Se puede guardar y cargar una política de negocio
✅ Los nodos tienen formularios asociados configurables

---

## BLOQUE 4: Motor de Workflow ⚡
**Prioridad: CRÍTICA** | **Estimación: 8-10 horas**

### Tareas:
- [ ] Diseñar el modelo de datos de "Trámite" (instancia de política)
- [ ] Implementar la lógica del motor:
  - Ejecutar flujo secuencial
  - Evaluar condiciones (flujo alternativo)
  - Ejecutar ciclos (flujo iterativo)
  - Ejecutar actividades paralelas (fork/join)
- [ ] Implementar enrutamiento automático al siguiente nodo
- [ ] Gestionar estados del trámite (EN_CURSO, COMPLETADO, CANCELADO)
- [ ] Registrar historial de cada paso del trámite
- [ ] API para iniciar un trámite (seleccionar política + datos del solicitante)
- [ ] API para completar una actividad (siguiente paso automático)
- [ ] Gestionar múltiples trámites simultáneos

### Criterio de éxito:
✅ Se puede iniciar un trámite basado en una política de negocio
✅ Al completar una actividad, el sistema enruta automáticamente a la siguiente
✅ Los flujos condicionales evalúan correctamente
✅ Los flujos paralelos se dividen y unen correctamente
✅ El historial queda registrado con tiempos

---

## BLOQUE 5: Panel del Funcionario + Formularios Dinámicos 📋
**Prioridad: ALTA** | **Estimación: 6-8 horas**

### Tareas:
- [ ] Crear panel/monitor del funcionario:
  - Lista de tareas pendientes 🔴
  - Lista de tareas en proceso 🟡
  - Lista de tareas completadas 🟢
- [ ] Implementar formularios dinámicos:
  - Renderizar formulario según el template definido en la política
  - Validaciones dinámicas
  - Guardar datos del formulario
- [ ] Implementar funcionalidad de "Completar actividad"
- [ ] Mostrar información del trámite (historial, estado general)
- [ ] Actualización automática del panel (sin recargar página)

### Criterio de éxito:
✅ El funcionario ve sus tareas organizadas por estado
✅ Puede abrir una tarea, llenar el formulario y completarla
✅ Al completar, la tarea desaparece y aparece en el siguiente funcionario
✅ Todo se actualiza en tiempo real

---

## BLOQUE 6: Notificaciones en Tiempo Real 🔔
**Prioridad: MEDIA** | **Estimación: 3-4 horas**

### Tareas:
- [ ] Configurar WebSockets en Spring Boot
- [ ] Configurar WebSocket client en Angular
- [ ] Implementar notificaciones cuando:
  - Llega una nueva tarea al funcionario
  - Un trámite cambia de estado
  - Se completa un trámite
- [ ] Mostrar badge/contador de notificaciones
- [ ] Panel de notificaciones
- [ ] Configurar push notifications para Flutter (Firebase Cloud Messaging)

### Criterio de éxito:
✅ Al completar una actividad, el siguiente funcionario recibe notificación instantáneamente
✅ Sin recargar la página, se actualiza todo en tiempo real
✅ Push notifications funcionan en la app móvil

---

## BLOQUE 7: Microservicio de IA 🤖
**Prioridad: MEDIA-ALTA** | **Estimación: 8-10 horas**

### Tareas:
- [ ] Configurar FastAPI con endpoints
- [ ] Implementar Speech-to-Text (STT):
  - Integrar Whisper (OpenAI) o Google Cloud Speech
  - Endpoint para recibir audio y devolver texto
  - Integrar con formularios del funcionario
- [ ] Implementar procesamiento de prompts para el diseñador:
  - Recibir texto natural → generar instrucciones para el diagrama
  - Ej: "Crea una actividad llamada 'Revisión Legal' en el departamento Legal"
  - Devolver JSON estructurado que el frontend interprete
- [ ] Implementar análisis de cuellos de botella:
  - Recibir métricas de trámites
  - Analizar tiempos por actividad/funcionario
  - Identificar actividades que retrasan el proceso
  - Devolver recomendaciones

### Criterio de éxito:
✅ Se puede dictar un informe por voz y el formulario se llena
✅ Se puede crear un diagrama usando prompts de texto
✅ El sistema detecta automáticamente cuellos de botella

---

## BLOQUE 8: Monitoreo y Analíticas 📊
**Prioridad: MEDIA** | **Estimación: 4-6 horas**

### Tareas:
- [ ] Dashboard de métricas generales:
  - Total de trámites activos/completados/cancelados
  - Tiempo promedio de resolución
  - Trámites por política de negocio
- [ ] Métricas por funcionario:
  - Tiempo promedio de atención
  - Cantidad de tareas procesadas
  - Comparación entre funcionarios del mismo departamento
- [ ] Detección de cuellos de botella:
  - Actividades con mayor tiempo de espera
  - Departamentos saturados
  - Gráficos visuales
- [ ] Implementar gráficos con librería de charts (ng2-charts, Chart.js)

### Criterio de éxito:
✅ Dashboard muestra métricas en tiempo real
✅ Se pueden comparar funcionarios
✅ Los cuellos de botella se identifican visualmente

---

## BLOQUE 9: App Móvil (Flutter) 📱
**Prioridad: MEDIA** | **Estimación: 6-8 horas**

### Tareas:
- [ ] Configurar proyecto Flutter
- [ ] Implementar pantalla de login
- [ ] Implementar panel del funcionario (versión móvil):
  - Tareas pendientes, en proceso, completadas
  - Formularios dinámicos
  - Llenado por voz
- [ ] Implementar push notifications (Firebase Cloud Messaging)
- [ ] App para cliente final:
  - Consultar estado de su trámite
  - Recibir notificaciones de avance
- [ ] Generar APK

### Criterio de éxito:
✅ La app permite loguearse y ver tareas
✅ Push notifications funcionan
✅ Se puede completar tareas desde el móvil
✅ APK generado e instalable

---

## BLOQUE 10: Despliegue en la Nube + Docker ☁️
**Prioridad: ALTA** | **Estimación: 4-6 horas**

### Tareas:
- [ ] Finalizar Dockerfiles para cada servicio
- [ ] Verificar docker-compose funciona en producción
- [ ] Elegir proveedor cloud (AWS/GCP/Azure)
- [ ] Desplegar servicios:
  - MongoDB (Atlas o en servidor)
  - Spring Boot (EC2/App Engine/Azure App Service)
  - FastAPI (mismo servidor o separado)
  - Angular (S3 + CloudFront / Nginx)
- [ ] Configurar dominio/subdominios
- [ ] Configurar HTTPS/SSL
- [ ] Variables de entorno en producción

### Criterio de éxito:
✅ Todo el sistema funciona en la nube
✅ Accesible desde cualquier navegador
✅ Ambiente local también funciona para cambios rápidos

---

## BLOQUE 11: Agente Inteligente (Guía de Usuario) 🧠
**Prioridad: BAJA-MEDIA** | **Estimación: 4-6 horas**

### Tareas:
- [ ] Diseñar el agente de ayuda contextual
- [ ] Implementar chat/conversación integrado en la app
- [ ] El agente detecta en qué pantalla está el usuario
- [ ] Responde preguntas sobre cómo usar la funcionalidad actual
- [ ] Posible implementación con n8n o LLM API
- [ ] Crear videos cortos demostrativos como complemento

### Criterio de éxito:
✅ El usuario puede preguntar "¿Cómo creo una política?" y obtener ayuda
✅ El agente sabe en qué pantalla está el usuario
✅ Videos disponibles para funcionalidades principales

---

## BLOQUE 12: Pulido Final + Preparación para la Presentación 🎯
**Prioridad: CRÍTICA** | **Estimación: 4-6 horas**

### Tareas:
- [ ] Testing end-to-end de flujos completos
- [ ] Crear al menos 2-3 políticas de negocio de ejemplo
- [ ] Ejecutar trámites completos con múltiples funcionarios
- [ ] Verificar que el tiempo real funciona (múltiples navegadores)
- [ ] Preparar datos de demo
- [ ] Preparar script de presentación (20 minutos)
- [ ] Verificar despliegue en la nube
- [ ] Verificar ambiente local para cambios en vivo
- [ ] Revisar documentación PDF
- [ ] Ensayo de la presentación

### Criterio de éxito:
✅ Demo fluida de 20 minutos
✅ Se pueden hacer cambios en vivo sin romper nada
✅ Múltiples navegadores muestran tiempo real
✅ Documentación completa y navegable

---

## Resumen de Estimaciones

| Bloque | Horas estimadas | Prioridad |
|--------|----------------|-----------|
| B0: Setup | 2-3h | CRÍTICA |
| B1: Auth | 4-6h | ALTA |
| B2: Configuración | 3-4h | ALTA |
| B3: Diseñador Visual | 10-15h | CRÍTICA |
| B4: Motor Workflow | 8-10h | CRÍTICA |
| B5: Panel Funcionario | 6-8h | ALTA |
| B6: Notificaciones | 3-4h | MEDIA |
| B7: IA Service | 8-10h | MEDIA-ALTA |
| B8: Analíticas | 4-6h | MEDIA |
| B9: App Móvil | 6-8h | MEDIA |
| B10: Despliegue | 4-6h | ALTA |
| B11: Agente | 4-6h | BAJA-MEDIA |
| B12: Pulido | 4-6h | CRÍTICA |
| **TOTAL** | **~67-92h** | — |

---

## Orden de Ejecución Recomendado

```
Día 1 (Hoy): B0 → B1 → B2
Día 2: B3 (Diseñador visual — parte 1)
Día 3: B3 (Diseñador visual — parte 2) → B4 (Motor — parte 1)
Día 4: B4 (Motor — parte 2) → B5 (Panel funcionario)
Día 5: B6 → B7 (IA) → B8 (Analíticas)
Día 6: B9 (Móvil) → B10 (Despliegue)
Día 7: B11 (Agente) → B12 (Pulido final)
```

> ⚠️ **El Bloque 3 (Diseñador Visual) y el Bloque 4 (Motor) son los más críticos y complejos.** Si alguno tiene bugs, debemos resolverlos antes de avanzar.
