package com.workflow.api.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Trámite — Instancia en ejecución de una Política de Negocio.
 * Cada trámite avanza paso a paso por los nodos del workflow.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "tramites")
public class Tramite {

    @Id
    private String id;

    /**
     * Referencia a la política de negocio que define el flujo
     */
    private String policyId;
    private String policyName;

    /**
     * Solicitante: quién inició el trámite
     */
    private String requestedBy;
    private String requestedByName;

    /**
     * Estado general: EN_CURSO, COMPLETADO, CANCELADO
     */
    @Builder.Default
    private String status = "EN_CURSO";

    /**
     * Nodos actualmente activos (puede haber varios en paralelo por fork)
     */
    @Builder.Default
    private List<String> activeNodeIds = new ArrayList<>();

    /**
     * Historial de cada paso del trámite
     */
    @Builder.Default
    private List<TramiteStep> steps = new ArrayList<>();

    /**
     * Datos acumulados del trámite (formularios completados)
     */
    @Builder.Default
    private Map<String, Object> data = new HashMap<>();

    /**
     * Nodos que están esperando un join (fork paralelo)
     * Key: joinNodeId, Value: lista de sourceNodeIds que ya completaron
     */
    @Builder.Default
    private Map<String, List<String>> pendingJoins = new HashMap<>();

    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    private LocalDateTime completedAt;
    private LocalDateTime updatedAt;
}
