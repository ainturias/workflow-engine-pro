package com.workflow.api.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Transición/conexión entre dos nodos del workflow.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WorkflowTransition {

    private String id;

    /**
     * ID del nodo origen
     */
    private String sourceNodeId;

    /**
     * ID del nodo destino
     */
    private String targetNodeId;

    /**
     * Etiqueta de la transición (ej: "Aprobado", "Rechazado")
     */
    private String label;

    /**
     * Condición para tomar esta transición (para nodos DECISION)
     * Formato: expresión evaluable como "monto > 1000"
     */
    private String condition;
}
