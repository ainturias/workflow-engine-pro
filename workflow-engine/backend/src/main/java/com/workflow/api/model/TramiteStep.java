package com.workflow.api.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * Paso del historial de un trámite.
 * Registra cada acción realizada sobre un nodo.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TramiteStep {

    private String id;

    /**
     * ID del nodo del workflow donde ocurrió este paso
     */
    private String nodeId;
    private String nodeType;
    private String nodeLabel;

    /**
     * ID del departamento responsable
     */
    private String departmentId;

    /**
     * Funcionario que completó este paso (null si fue automático)
     */
    private String completedBy;
    private String completedByName;

    /**
     * Estado: PENDING, IN_PROGRESS, COMPLETED, SKIPPED
     */
    @Builder.Default
    private String status = "PENDING";

    /**
     * Datos del formulario completado en este paso
     */
    private Map<String, Object> formData;

    /**
     * Comentario u observación del funcionario
     */
    private String comment;

    @Builder.Default
    private LocalDateTime assignedAt = LocalDateTime.now();

    private LocalDateTime startedAt;
    private LocalDateTime completedAt;

    /**
     * Definición del formulario (esquema) para este paso
     */
    private List<FormField> formFields;
}
