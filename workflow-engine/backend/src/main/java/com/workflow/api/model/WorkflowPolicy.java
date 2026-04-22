package com.workflow.api.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Política de Negocio — Representa un diagrama de workflow completo.
 * Contiene los nodos (actividades, decisiones, forks, etc.) y las transiciones entre ellos.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "policies")
public class WorkflowPolicy {

    @Id
    private String id;

    private String name;
    private String description;

    /**
     * Usuario que creó la política
     */
    private String createdBy;

    /**
     * Estado: DRAFT, PUBLISHED, ARCHIVED
     */
    @Builder.Default
    private String status = "DRAFT";

    /**
     * Nodos del diagrama (Start, Activity, Decision, Fork, Join, End)
     */
    @Builder.Default
    private List<WorkflowNode> nodes = new ArrayList<>();

    /**
     * Transiciones/conexiones entre nodos
     */
    @Builder.Default
    private List<WorkflowTransition> transitions = new ArrayList<>();

    /**
     * Swimlanes (departamentos representados en el diagrama)
     */
    @Builder.Default
    private List<Swimlane> swimlanes = new ArrayList<>();

    @Builder.Default
    private boolean active = true;

    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    private LocalDateTime updatedAt;
}
