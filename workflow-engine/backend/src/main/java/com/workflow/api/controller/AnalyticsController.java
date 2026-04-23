package com.workflow.api.controller;

import com.workflow.api.dto.AnalyticsDTO;
import com.workflow.api.service.AnalyticsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controller de Analíticas — Expone métricas de monitoreo del motor de workflow.
 */
@RestController
@RequestMapping("/api/analytics")
@RequiredArgsConstructor
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    /**
     * Dashboard completo con todas las métricas.
     */
    @GetMapping("/summary")
    public ResponseEntity<AnalyticsDTO.DashboardSummary> getSummary() {
        return ResponseEntity.ok(analyticsService.getDashboardSummary());
    }

    /**
     * Métricas generales: totales, promedios, trámites por política.
     */
    @GetMapping("/general")
    public ResponseEntity<AnalyticsDTO.GeneralMetrics> getGeneralMetrics() {
        return ResponseEntity.ok(analyticsService.getGeneralMetrics());
    }

    /**
     * Métricas por funcionario, opcionalmente filtrado por departamento.
     */
    @GetMapping("/funcionarios")
    public ResponseEntity<List<AnalyticsDTO.FuncionarioMetrics>> getFuncionarioMetrics(
            @RequestParam(required = false) String departmentId) {
        return ResponseEntity.ok(analyticsService.getFuncionarioMetrics(departmentId));
    }

    /**
     * Cuellos de botella detectados.
     */
    @GetMapping("/bottlenecks")
    public ResponseEntity<List<AnalyticsDTO.BottleneckInfo>> getBottlenecks() {
        return ResponseEntity.ok(analyticsService.getBottlenecks());
    }

    /**
     * Carga por departamento.
     */
    @GetMapping("/departments")
    public ResponseEntity<List<AnalyticsDTO.DepartmentLoad>> getDepartmentLoad() {
        return ResponseEntity.ok(analyticsService.getDepartmentLoad());
    }

    /**
     * Tendencia de trámites (últimos 30 días).
     */
    @GetMapping("/trends")
    public ResponseEntity<List<AnalyticsDTO.TramiteTrend>> getTrends() {
        return ResponseEntity.ok(analyticsService.getTramiteTrends());
    }
}
