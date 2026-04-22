package com.workflow.api.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

/**
 * Nodo dentro del diagrama de workflow.
 * Tipos: START, END, ACTIVITY, DECISION, FORK, JOIN
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WorkflowNode {

    private String id;

    /**
     * START, END, ACTIVITY, DECISION, FORK, JOIN
     */
    private String type;

    private String label;

    /**
     * ID del departamento (swimlane) donde se ubica este nodo
     */
    private String departmentId;

    /**
     * ID de la actividad asociada (solo para type=ACTIVITY)
     */
    private String activityId;

    /**
     * Campos del formulario para este nodo específico
     */
    private List<FormField> formFields;

    /**
     * Posición visual en el canvas (x, y)
     */
    private double x;
    private double y;

    /**
     * Datos adicionales de configuración del nodo
     */
    private Map<String, Object> config;
}
