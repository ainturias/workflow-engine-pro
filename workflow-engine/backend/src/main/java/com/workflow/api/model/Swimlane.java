package com.workflow.api.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Swimlane — Representa una "calle" del diagrama asociada a un departamento.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Swimlane {

    private String id;
    private String departmentId;
    private String departmentName;

    /**
     * Orden de la swimlane en el diagrama (0, 1, 2...)
     */
    private int order;

    /**
     * Color de la swimlane
     */
    private String color;
}
