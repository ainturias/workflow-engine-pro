# 📋 Contexto Completo del Proyecto — Sistema de Gestión de Trámites (Workflow Engine)

> **Materia:** Ingeniería de Software 1 — Primer Parcial
> **Fecha de presentación:** 28 de abril de 2026
> **Tiempo de exposición:** 20 minutos

---

## 1. Descripción General del Problema

Se requiere diseñar y desarrollar un **sistema de gestión de trámites** inspirado en organizaciones como **CRE** (Cooperativa Rural de Electrificación). El sistema debe modelar y ejecutar **flujos de trabajo (workflows)** que permitan dar seguimiento completo a trámites desde su solicitud hasta su resolución.

### Ejemplo real del flujo:
1. Un usuario solicita un trámite (ej: interconexión eléctrica)
2. El **departamento de atención al cliente** recibe la solicitud
3. Se deriva a un **departamento técnico** para evaluar viabilidad
4. Luego pasa a un **área legal** para revisar aspectos legales
5. Continúa por otras áreas según la **política de negocio** definida
6. Cada departamento realiza su tarea y el sistema enruta automáticamente al siguiente

### Problema central:
Actualmente, cuando un cliente llama para consultar el estado de su trámite, el funcionario de atención al cliente **no tiene a la mano la información** de dónde está el trámite, cuánto le falta, qué ya recorrió, etc.

---

## 2. Objetivo del Sistema

El sistema debe:
- ✅ Gestionar trámites de principio a fin
- ✅ Modelar y ejecutar flujos de trabajo (workflows)
- ✅ Permitir identificar:
  - Cuellos de botella
  - Tiempos de atención
  - Estados de los trámites
  - Participación de los distintos departamentos
- ✅ Ser **flexible y adaptable** — no se conocen previamente los flujos ni las reglas de negocio

---

## 3. Requisitos Funcionales Clave

### 3.1 Motor de Workflows (Motor de Procesos)
El sistema contará con un **motor de workflow** basado en:
- **Diagramas de actividades organizados en calles (swimlanes)** de UML
- Representación visual para facilitar la creación de políticas de negocio

**Elementos del motor:**
- Actividades
- Flujos (transiciones entre actividades)
- Estados
- Transiciones

### 3.2 Tipos de Flujos que debe soportar

| Tipo | Descripción |
|------|-------------|
| **Secuencial/Lineal** | Actividades ejecutadas en orden, una tras otra |
| **Alternativo/Condicional** | Dependiendo de una condición, el flujo toma un camino u otro (if/else, switch) |
| **Iterativo (ida y vuelta)** | Posibilidad de regresar a pasos anteriores (while, do-while) |
| **Paralelo** | Actividades ejecutadas simultáneamente con barra de separación (fork) y unión (join) |

> **Nota importante:** Las políticas de negocio pueden combinar CUALQUIERA de estos 4 tipos en un solo flujo.

### 3.3 Gestión de Configuración
El sistema debe permitir registrar:
- **Empresas**
- **Actividades** (tareas que se realizan en cada nodo)
- **Departamentos**
- Asociar estos elementos dentro de los flujos

### 3.4 Roles del Sistema

| Rol | Permisos |
|-----|----------|
| **Administrador / Diseñador de Políticas** | Crear y configurar actividades, definir políticas de negocio, diseñar los flujos |
| **Funcionario Normal** | Solo ejecuta trámites, NO puede crear actividades ni modificar flujos |

### 3.5 Ejecución del Proceso
- El funcionario de atención al cliente recibe la solicitud
- Selecciona la **política de negocio** correspondiente al trámite
- El trámite sigue el flujo definido **automáticamente**
- El sistema **enruta automáticamente** al siguiente departamento sin intervención manual
- El funcionario **NO decide** a dónde va el trámite, lo hace el motor según la política

### 3.6 Panel del Funcionario
Cada funcionario tendrá un **panel/monitor** donde verá:
- 🟢 Actividades completadas
- 🔴 Actividades pendientes por atender
- 🟡 Actividades en proceso
- Todos los tiempos de atención

> **Importante:** El funcionario normal **NUNCA** ve el diagrama de actividades. Solo ve su panel con las tareas que le corresponden.

### 3.7 Formularios por Actividad
- En cada nodo/actividad del workflow, el sistema debe permitir **crear un formulario**
- Cada funcionario debe registrar un **informe** al completar su actividad
- El formulario puede llenarse de 3 formas:
  1. **Manual** — escritura directa
  2. **Por voz (audio)** — reconocimiento de voz que rellena el formulario
  3. **Edición posterior** — el funcionario puede modificar lo generado por voz

---

## 4. Funcionalidades Obligatorias

### 4.1 Automatización
- El sistema actualiza estados automáticamente
- Gestiona el avance del trámite sin intervención manual excesiva
- Al terminar una tarea, el sistema enruta automáticamente al siguiente departamento

### 4.2 Notificaciones
- Enviar notificaciones a los usuarios involucrados en cada etapa
- **Sin hacer ningún clic**, automáticamente se debe ver el progreso en tiempo real

### 4.3 Monitoreo y Analíticas
- Medir tiempos de atención
- Detectar cuellos de botella automáticamente
- Métricas de eficiencia por funcionario (ej: comparar tiempos entre funcionarios que hacen la misma tarea)
- Los estudiantes definen los criterios, métricas y parámetros

### 4.4 Sistema Colaborativo
- El diseño de políticas de negocio debe ser **100% colaborativo**
- Varias personas en **diferentes lugares** pueden diseñar simultáneamente un diagrama de actividades
- Interacción en tiempo real entre diseñadores

### 4.5 Creación de Flujos (Diseñador de Políticas)
El diseñador de políticas debe poder crear flujos mediante:
1. **Dibujo directo** — arrastrar y soltar componentes como en herramientas CASE (similar a StarUML/Architect)
2. **Prompts de texto** — ej: "Crea una actividad X en el departamento Y, conecta A con B usando flujo condicional"
3. **Prompts de voz/audio** — dictando la estructura del flujo

> **Importante:** La herramienta NO genera automáticamente el diagrama completo. El usuario va **diseñando paso a paso** con ayuda de prompts.

### 4.6 Análisis de Procesos con IA
- Identificación de cuellos de botella mediante análisis de datos
- Análisis tanto técnico como de atención al cliente

---

## 5. Stack Tecnológico (OBLIGATORIO)

| Componente | Tecnología |
|-----------|-----------|
| **Backend Core** | Spring Boot (Java) |
| **Microservicios IA** | FastAPI (Python) |
| **Base de Datos** | MongoDB |
| **Frontend Web** | Angular |
| **App Móvil (funcionarios)** | Flutter |
| **App Móvil (cliente final)** | Flutter (para notificaciones push, etc.) |
| **Despliegue** | AWS / Google Cloud / Azure |
| **Contenedores** | Docker (obligatorio) |
| **Control de versiones** | Git + GitHub |
| **Gestión de proyectos** | Jira / Trello / similar |
| **App móvil** | Generar APK |

---

## 6. Documentación Requerida

### 6.1 Metodología
- **Proceso Unificado (PUDS)** por Rumbaugh, Booch, Jacobson
- Tener el **libro digital impreso** el día de la presentación
- **UML 2.5 o superior**
- Tener el libro de UML escrito por los 3 autores (Booch, Rumbaugh, Jacobson)
- **Herramientas CASE obligatorias** para todos los modelos (StarUML, Architect, etc.)
- Todos los modelos deben cumplir con la **notación UML 2.5**

### 6.2 Estructura del Documento PDF

**Fecha límite de entrega:** 29 de abril hasta las 8:00 AM (subir a plataforma Moodle)
**Llevar:** 2 carátulas + PDF en la computadora

#### PARTE 1 — Fundamentación Teórica

| Capítulo | Contenido |
|----------|-----------|
| Ingeniería de Software Asistida por Computadora (CASE) | Herramientas CASE, propósito central de la ingeniería de software (productividad) |
| Desarrollo de Software Basado en Componentes | Reutilización, estándares, usar componentes hechos y crear componentes reutilizables |
| Arquitectura del Software | Reflejar plenamente la arquitectura usada |
| Proceso Unificado | Resumen puntual de la metodología |
| UML | Notación y uso |
| Inteligencia Artificial | Capítulo CRÍTICO — cómo debería usar la IA un programador, ventajas, beneficios, desventajas. Debe ser de autoría propia |
| Workflows | Sistemas workflow, se puede referenciar uno existente |
| Comparativa de Herramientas | Spring Boot vs Laravel, MongoDB vs otra BD, Angular vs otro framework, etc. |

#### PARTE 2 — Proceso de Desarrollo (Modelos UML)

| Diagrama | Obligatorio | Descripción |
|----------|-------------|-------------|
| Diagrama de Arquitectura | ✅ Sí | Visualizar la arquitectura del software |
| Diagrama de Paquetes | ✅ Sí | A nivel de código (mínimo 2) |
| Diagrama de Despliegue | ✅ Sí | Nodos físicos, notación del cubo |
| Modelo de Datos | ✅ Sí | Diseño de la base de datos (evaluar si usar modelo clásico para relacional o adaptarlo para MongoDB) |
| Diagrama de Secuencia | ✅ Sí | Diagrama dinámico recomendado |
| Diagrama de Estado | ✅ Sí | Complementa al de secuencia |
| Diagrama de Casos de Uso | ✅ Sí | Diagrama de contexto de alto nivel — funcionalidades, actores y entidades externas |

> **Nota:** No se necesitan TODOS los diagramas UML, solo los útiles según el contexto. Los 7 listados arriba son los mínimos obligatorios.

#### PARTE 3 — Guía de Usuario

El usuario debe aprender a usar el sistema con el **menor esfuerzo posible**. Opciones:
- ❌ Manual de usuario tradicional (arcaico)
- ✅ Videos cortos demostrativos
- ✅ **Agente inteligente** (la opción más adecuada) — que detecte qué está haciendo el usuario en todo momento y lo guíe
- Posible uso de **n8n** para construir el agente
- Debe funcionar a través de **conversaciones naturales**

---

## 7. Criterios de Evaluación (Día de la Presentación)

| Paso | Criterio |
|------|----------|
| **1ro** | ¿El software es de calidad? Demostrar que cumple definiciones de calidad y productividad |
| **2do** | El software es un **producto** completo |
| **3ro** | Demostrar que el proyecto fue desarrollado por **ingenieros de software** y la IA fue solo una herramienta |
| **4to** | Demostrar que el código fue hecho por el equipo — se pedirá **modificar/agregar** funcionalidades en vivo |

### Requisitos para la presentación:
- Todo debe estar **desplegado en la nube**
- Tener también ambiente **local** para demostrar cambios rápidamente
- Se necesitan **múltiples navegadores/máquinas** para simular múltiples funcionarios
- Los cambios deben verse en **tiempo real** sin recargar

---

## 8. Aspectos Críticos a Tener en Cuenta

1. **El sistema NO conoce previamente ninguna política de negocio** — debe ser 100% configurable
2. **Múltiples políticas simultáneas** — el sistema debe soportar N políticas diferentes
3. **Tiempo real** — los cambios de estado deben reflejarse instantáneamente
4. **El índice del PDF debe ser 100% navegable**
5. **Herramientas CASE obligatorias** — modelos hechos a mano o en herramientas que no cumplan UML 2.5 no serán aceptados
6. **La IA debe usarse como herramienta, no como sustituto del desarrollador**
7. **Colaboración en tiempo real** para el diseño de políticas de negocio
