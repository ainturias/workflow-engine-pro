# 📎 Glosario y Notas Importantes

---

## Glosario de Términos

| Término | Definición |
|---------|-----------|
| **Workflow** | Flujo de trabajo — secuencia de actividades que se ejecutan para completar un proceso |
| **Política de Negocio** | Definición de un flujo de trabajo específico para un tipo de trámite. Incluye actividades, transiciones, condiciones y departamentos involucrados |
| **Motor de Workflow** | Componente del sistema que ejecuta las políticas de negocio, enruta trámites y gestiona estados automáticamente |
| **Swimlane (Calle)** | En un diagrama de actividades UML, cada "calle" horizontal representa un departamento o actor responsable |
| **Trámite** | Instancia de ejecución de una política de negocio. Un caso concreto con datos reales |
| **Nodo** | Cada punto en el diagrama de actividades: puede ser actividad, decisión, fork, join, inicio o fin |
| **Transición** | Conexión entre nodos que define el flujo. Puede tener condiciones asociadas |
| **Fork** | Punto donde un flujo se divide en múltiples flujos paralelos |
| **Join** | Punto donde múltiples flujos paralelos se unen en uno solo |
| **CASE** | Computer-Aided Software Engineering — herramientas para asistir el desarrollo de software |
| **PUDS** | Proceso Unificado de Desarrollo de Software |
| **STT** | Speech-to-Text — conversión de audio a texto |
| **Cuello de Botella** | Punto del flujo donde se acumulan trámites por lentitud en el procesamiento |

---

## Notas Clave del Profesor

> 📌 "Lo desafiante de esta situación es que no tenemos ni la más peregrina idea de quién o para qué lo vamos a ver... No tenemos ni idea de cuántas políticas de negocio, ni cuál es el flujo"

**Interpretación:** El sistema debe ser 100% genérico y configurable. NO podemos hardcodear ninguna política de negocio.

---

> 📌 "El funcionario normal nunca lo va a ver [el diagrama de actividades]. Él va a entrar solamente a su monitor"

**Interpretación:** Separación estricta de interfaces: el diseñador ve el diagrama, el funcionario solo ve su panel de tareas.

---

> 📌 "Es el software que solito, a través de su motor, según lo que se definió en la política del negocio, debería enrutarlo a otro"

**Interpretación:** El enrutamiento es 100% automático. El funcionario solo marca "completado" y el sistema hace el resto.

---

> 📌 "Sin hacer ningún clic, automáticamente se tiene que ver el progreso"

**Interpretación:** WebSockets obligatorios. El panel se actualiza en tiempo real sin refresh.

---

> 📌 "Lo más sencillo es tener más de un navegador, y en cada navegador está un funcionario distinto"

**Interpretación:** Para la demo, usar múltiples navegadores/pestañas para simular distintos funcionarios.

---

> 📌 "Cada uno agregue su innovación... pero para que cuenten la idea que ustedes han implementado, esto que es lo mínimo lo deben tener"

**Interpretación:** Primero cumplir con TODO lo obligatorio, luego innovar. Las innovaciones no cuentan si lo base no está completo.

---

> 📌 "El 4to paso: modificar cosas, agregar cosas... todo debe ser en la nube, pero traer lo local para visualizar los cambios"

**Interpretación:** En la presentación nos pedirán hacer cambios al código EN VIVO. Debemos conocer el código perfectamente y tener el ambiente local listo.

---

## Riesgos Identificados

| Riesgo | Impacto | Mitigación |
|--------|---------|------------|
| El editor visual de diagramas es muy complejo | ALTO | Comenzar temprano, usar librería existente |
| El motor de workflow tiene bugs con flujos paralelos | ALTO | Testing exhaustivo con casos de prueba |
| No conocer bien el código para la modificación en vivo | CRÍTICO | Cada miembro del equipo debe conocer su módulo a fondo |
| El despliegue en la nube falla | ALTO | Tener ambiente local como respaldo |
| El tiempo real (WebSockets) no funciona | MEDIO | Probar con múltiples navegadores desde el día 1 |
| MongoDB no soporta las queries necesarias | BAJO | Diseñar bien las colecciones desde el inicio |

---

## FAQ (Preguntas Frecuentes del Contexto)

**P: ¿Tenemos que crear políticas de negocio específicas?**
R: No. El sistema debe permitir crear CUALQUIER política. Para la demo, crearemos 2-3 de ejemplo.

**P: ¿El cliente final usa la misma app que el funcionario?**
R: No. El cliente solo recibe notificaciones y puede consultar el estado de su trámite (app Flutter separada o misma app con vista diferente).

**P: ¿Qué pasa si un trámite se atasca en una actividad?**
R: El sistema de monitoreo debe detectar esto como cuello de botella y alertar.

**P: ¿Los formularios son iguales para todas las actividades?**
R: No. Cada actividad en la política de negocio tiene su propio formulario personalizado, definido por el diseñador de la política.

**P: ¿Se puede editar una política de negocio que ya tiene trámites en curso?**
R: Esta es una decisión de diseño. Lo más seguro es que los trámites en curso sigan la versión anterior, y los nuevos trámites usen la nueva versión.
