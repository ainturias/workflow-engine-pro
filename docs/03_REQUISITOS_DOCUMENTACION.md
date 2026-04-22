# 📄 Requisitos de Documentación — Primer Parcial

> **Fecha límite PDF:** 29 de abril de 2026, hasta las 8:00 AM (subir a Moodle)
> **Día de presentación:** 28 de abril de 2026

---

## 1. Entregables Físicos el Día de la Presentación

- [ ] **2 carátulas** impresas
- [ ] **PDF** del documento en la computadora
- [ ] **Libro de PUDS** (Proceso Unificado) por Rumbaugh — digital impreso
- [ ] **Libro de UML** escrito por Booch, Rumbaugh y Jacobson — digital impreso
- [ ] **Software desplegado** en la nube (AWS/GCP/Azure)
- [ ] **Ambiente local** configurado para demostrar cambios en vivo
- [ ] **APK generado** de la app Flutter
- [ ] **Múltiples navegadores** para simular múltiples funcionarios

---

## 2. Estructura del Documento PDF

### Requisitos del PDF:
- ✅ Índice o tabla de contenido **100% navegable** (con hipervínculos internos)
- ✅ Todos los modelos UML elaborados con **herramientas CASE** (StarUML, Enterprise Architect, etc.)
- ✅ Notación **UML 2.5 o superior** obligatoria
- ✅ Los modelos que no cumplan con UML 2.5 **no serán aceptados**

---

## 3. PARTE 1 — Fundamentación Teórica (Marco Teórico)

> **Propósito:** Documentar todos los temas que se profundizaron o especializaron para realizar el proyecto.

### Capítulos requeridos:

#### Cap. 1: Ingeniería de Software Asistida por Computadora (CASE)
- Qué son las herramientas CASE
- Propósito central de la ingeniería de software: **la productividad**
- Cómo las herramientas CASE mejoran la productividad
- Herramientas CASE utilizadas en el proyecto

#### Cap. 2: Desarrollo de Software Basado en Componentes
- Concepto de desarrollo basado en componentes
- Analogía con hardware: definir arquitectura, estándares, y que cambios no afecten al todo
- **Aplicación en el proyecto de 2 formas:**
  1. Usar componentes ya hechos (librerías, frameworks)
  2. Todo lo implementado debe ser **reutilizable**, idealmente a nivel de componente
- Estándares de componentes
- Referencia al libro: "Desarrollo de Software Basado en Componentes"

#### Cap. 3: Arquitectura del Software
- Definición y tipos de arquitectura
- Arquitectura utilizada en el proyecto (microservicios, etc.)
- Justificación de las decisiones arquitectónicas
- Debe estar **reflejada plenamente** en el proyecto

#### Cap. 4: Proceso Unificado (Metodología)
- Resumen **muy puntual** de la metodología
- Fases del Proceso Unificado
- Cómo se aplica al proyecto

#### Cap. 5: UML
- Notación UML 2.5
- Diagramas utilizados
- Justificación de los diagramas elegidos

#### Cap. 6: Inteligencia Artificial
> ⚠️ **CAPÍTULO CRÍTICO — Debe ser de autoría propia**
- Cómo debería usar la IA un programador de manera conveniente y apropiada
- Ventajas y beneficios de la IA en el desarrollo
- Desventajas y riesgos
- Postura crítica y personal del equipo
- Aplicación de IA en el proyecto (STT, análisis de datos, prompts, agente)

#### Cap. 7: Sistemas Workflow
- Qué son los workflows
- Tipos de workflows
- Motores de workflow existentes
- Se puede referenciar alguno existente como base teórica

#### Cap. 8: Comparativa de Herramientas
| Comparativa | Opción A | Opción B |
|------------|----------|----------|
| Backend | Spring Boot | Laravel |
| Base de datos | MongoDB | PostgreSQL / MySQL |
| Frontend | Angular | React / Vue |
| Móvil | Flutter | React Native / Kotlin |
| Microservicios IA | FastAPI | Flask / Express |
| Cloud | AWS | GCP / Azure |
| Contenedores | Docker | Podman |

> Para cada comparativa: features, rendimiento, comunidad, curva de aprendizaje, ecosistema, justificación de la elección.

---

## 4. PARTE 2 — Proceso de Desarrollo (Diagramas UML)

> **Metodología base:** Proceso Unificado (Booch, Rumbaugh, Jacobson)
> **Notación:** UML 2.5 o superior
> **Herramientas:** CASE obligatorias
> **Regla:** No se necesitan TODOS los diagramas, solo los útiles. Los listados abajo son **obligatorios**.

### Diagramas Obligatorios:

#### 1. Diagrama de Casos de Uso (Contexto)
- Diagrama de **alto nivel**, muy abstracto
- En una sola página se debe ver **todo el sistema**
- Debe mostrar:
  - Funcionalidades del software
  - Actores (Admin, Funcionario, Cliente)
  - Entidades externas que interactúan con el sistema

#### 2. Diagrama de Arquitectura del Software
- Visualizar la arquitectura general
- Microservicios, capas, componentes principales
- Comunicación entre servicios

#### 3. Diagramas de Paquetes (mínimo 2)
- A **nivel de código**
- Mostrar organización de paquetes/módulos
- Uno para el backend, otro para el frontend (sugerido)

#### 4. Diagrama de Despliegue
- Nodos físicos
- **Notación del cubo** (representación 3D de nodos)
- Dónde se despliega cada servicio
- Docker containers, cloud, bases de datos

#### 5. Modelo de Datos
- Diseño de la base de datos
- Adaptar para MongoDB (colecciones, documentos, relaciones por referencia)
- Evaluar si usar modelo clásico ER adaptado o modelo de documentos

#### 6. Diagrama de Secuencia
- Diagrama dinámico
- Flujos principales del sistema
- Interacción entre componentes

#### 7. Diagrama de Estado
- Complementa al diagrama de secuencia
- Estados de los trámites
- Transiciones de estado en el workflow

---

## 5. PARTE 3 — Guía de Usuario

> **Principio:** El usuario debe aprender a usar el sistema con el **menor esfuerzo posible**

### Opciones (de menor a mayor recomendación):

| Opción | Valoración |
|--------|-----------|
| Manual de usuario PDF | ❌ Arcaico, no recomendado |
| Videos cortos demostrativos | ✅ Aceptable, útil como complemento |
| **Agente inteligente** | ✅✅ La opción más adecuada y valorada |

### Agente Inteligente (Recomendado):
- Debe ser consciente de lo que está haciendo el usuario **en todo momento**
- Funcionar a través de **conversaciones naturales**
- Similar al asistente de Adobe Acrobat como ejemplo
- Posible implementación con **n8n** u otra herramienta de automatización
- No es un simple chatbot — es un **agente contextual**

---

## 6. Criterios de Evaluación (Presentación)

### Paso 1: Calidad del Software
- Demostrar que el software cumple con las definiciones de **calidad**
- Definir qué es calidad y cómo el software la cumple
- Demostrar **productividad** en el proceso de desarrollo

### Paso 2: Software como Producto
- Demostrar que es un **producto completo**
- No un prototipo o MVP — un producto funcional

### Paso 3: Ingeniería de Software (CRÍTICO)
> ⚠️ **Si no se pasa este paso, se cae el examen**
- Demostrar que el proyecto fue desarrollado por **ingenieros de software**
- La IA es **solo una herramienta**, no el desarrollador
- **Sincronización** entre lo documentado y lo implementado
- El proceso de desarrollo cumple con lo establecido en el documento

### Paso 4: Autoría del Código
- Se pedirá **modificar y agregar funcionalidades en vivo**
- Demostrar conocimiento profundo del código
- Los cambios deben poder hacerse en tiempo real
- Opción: tener el proyecto en **local** para que los cambios se vean rápido
- Si está solo en la nube, considerar que el deploy puede tardar

---

## 7. Checklist de Documentación

- [ ] Carátula
- [ ] Índice navegable
- [ ] Cap. 1: CASE
- [ ] Cap. 2: Desarrollo basado en componentes
- [ ] Cap. 3: Arquitectura del software
- [ ] Cap. 4: Proceso Unificado
- [ ] Cap. 5: UML
- [ ] Cap. 6: Inteligencia Artificial (autoría propia)
- [ ] Cap. 7: Workflows
- [ ] Cap. 8: Comparativa de herramientas
- [ ] Diagrama de Casos de Uso
- [ ] Diagrama de Arquitectura
- [ ] Diagramas de Paquetes (x2)
- [ ] Diagrama de Despliegue
- [ ] Modelo de Datos
- [ ] Diagrama de Secuencia
- [ ] Diagrama de Estado
- [ ] Guía de usuario (agente + videos)
