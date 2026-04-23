package com.workflow.api.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * DTOs para el módulo de Analíticas y Monitoreo.
 */
public class AnalyticsDTO {

    // ==================== Métricas Generales ====================

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class GeneralMetrics {
        private long totalActive;
        private long totalCompleted;
        private long totalCancelled;
        private long totalTramites;
        private double avgResolutionHours;
        private List<TramitesByPolicy> tramitesByPolicy;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TramitesByPolicy {
        private String policyId;
        private String policyName;
        private long count;
    }

    // ==================== Métricas por Funcionario ====================

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class FuncionarioMetrics {
        private String userId;
        private String name;
        private String departmentId;
        private String departmentName;
        private double avgAttentionHours;
        private long tasksProcessed;
        private long tasksCompleted;
    }

    // ==================== Cuellos de Botella ====================

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class BottleneckInfo {
        private String nodeLabel;
        private String policyName;
        private String departmentId;
        private String departmentName;
        private double avgWaitHours;
        private long pendingCount;
        /** HIGH, MEDIUM, LOW */
        private String severity;
    }

    // ==================== Carga por Departamento ====================

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DepartmentLoad {
        private String departmentId;
        private String name;
        private long pendingTasks;
        private long activeTramites;
        private double avgWaitHours;
        /** 0-100 porcentaje de saturación */
        private int saturationLevel;
    }

    // ==================== Tendencias ====================

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TramiteTrend {
        private String date;
        private long count;
    }

    // ==================== Dashboard Completo ====================

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DashboardSummary {
        private GeneralMetrics generalMetrics;
        private List<FuncionarioMetrics> funcionarioMetrics;
        private List<BottleneckInfo> bottlenecks;
        private List<DepartmentLoad> departmentLoads;
        private List<TramiteTrend> trends;
    }
}
