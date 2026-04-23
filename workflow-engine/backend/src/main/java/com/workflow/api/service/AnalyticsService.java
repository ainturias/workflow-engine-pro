package com.workflow.api.service;

import com.workflow.api.dto.AnalyticsDTO;
import com.workflow.api.model.*;
import com.workflow.api.repository.DepartmentRepository;
import com.workflow.api.repository.TramiteRepository;
import com.workflow.api.repository.UserRepository;
import com.workflow.api.repository.WorkflowPolicyRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Servicio de Analíticas — Calcula métricas, detecta cuellos de botella
 * y genera estadísticas para el dashboard de monitoreo.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AnalyticsService {

    private final TramiteRepository tramiteRepository;
    private final WorkflowPolicyRepository policyRepository;
    private final UserRepository userRepository;
    private final DepartmentRepository departmentRepository;

    /**
     * Obtiene el resumen completo del dashboard.
     */
    public AnalyticsDTO.DashboardSummary getDashboardSummary() {
        return AnalyticsDTO.DashboardSummary.builder()
                .generalMetrics(getGeneralMetrics())
                .funcionarioMetrics(getFuncionarioMetrics(null))
                .bottlenecks(getBottlenecks())
                .departmentLoads(getDepartmentLoad())
                .trends(getTramiteTrends())
                .build();
    }

    /**
     * Métricas generales: totales por estado, promedio de resolución, trámites por política.
     */
    public AnalyticsDTO.GeneralMetrics getGeneralMetrics() {
        List<Tramite> allTramites = tramiteRepository.findAll();

        long totalActive = allTramites.stream()
                .filter(t -> "EN_CURSO".equals(t.getStatus()))
                .count();
        long totalCompleted = allTramites.stream()
                .filter(t -> "COMPLETADO".equals(t.getStatus()))
                .count();
        long totalCancelled = allTramites.stream()
                .filter(t -> "CANCELADO".equals(t.getStatus()))
                .count();

        // Calcular tiempo promedio de resolución (solo completados)
        double avgResolutionHours = allTramites.stream()
                .filter(t -> "COMPLETADO".equals(t.getStatus()) && t.getCompletedAt() != null && t.getCreatedAt() != null)
                .mapToDouble(t -> Duration.between(t.getCreatedAt(), t.getCompletedAt()).toMinutes() / 60.0)
                .average()
                .orElse(0.0);

        // Trámites por política
        Map<String, Long> byPolicy = allTramites.stream()
                .collect(Collectors.groupingBy(
                        t -> t.getPolicyId() != null ? t.getPolicyId() : "unknown",
                        Collectors.counting()
                ));

        List<AnalyticsDTO.TramitesByPolicy> tramitesByPolicy = byPolicy.entrySet().stream()
                .map(entry -> {
                    String policyName = allTramites.stream()
                            .filter(t -> entry.getKey().equals(t.getPolicyId()))
                            .map(Tramite::getPolicyName)
                            .findFirst()
                            .orElse("Desconocida");
                    return AnalyticsDTO.TramitesByPolicy.builder()
                            .policyId(entry.getKey())
                            .policyName(policyName)
                            .count(entry.getValue())
                            .build();
                })
                .sorted(Comparator.comparingLong(AnalyticsDTO.TramitesByPolicy::getCount).reversed())
                .collect(Collectors.toList());

        return AnalyticsDTO.GeneralMetrics.builder()
                .totalActive(totalActive)
                .totalCompleted(totalCompleted)
                .totalCancelled(totalCancelled)
                .totalTramites(allTramites.size())
                .avgResolutionHours(Math.round(avgResolutionHours * 100.0) / 100.0)
                .tramitesByPolicy(tramitesByPolicy)
                .build();
    }

    /**
     * Métricas por funcionario: tiempo promedio de atención, tareas procesadas.
     * Opcionalmente filtrado por departamento.
     */
    public List<AnalyticsDTO.FuncionarioMetrics> getFuncionarioMetrics(String departmentId) {
        // Obtener funcionarios
        List<User> funcionarios = userRepository.findAll().stream()
                .filter(u -> "FUNCIONARIO".equals(u.getRole()))
                .filter(u -> departmentId == null || departmentId.equals(u.getDepartmentId()))
                .collect(Collectors.toList());

        // Mapa de departamentos para obtener nombres
        Map<String, String> deptNames = departmentRepository.findAll().stream()
                .collect(Collectors.toMap(Department::getId, Department::getName, (a, b) -> a));

        List<Tramite> allTramites = tramiteRepository.findAll();

        return funcionarios.stream()
                .map(user -> {
                    // Buscar todos los steps completados por este funcionario
                    List<TramiteStep> completedSteps = allTramites.stream()
                            .flatMap(t -> t.getSteps().stream())
                            .filter(s -> user.getId().equals(s.getCompletedBy()))
                            .collect(Collectors.toList());

                    long tasksCompleted = completedSteps.stream()
                            .filter(s -> "COMPLETED".equals(s.getStatus()))
                            .count();

                    // Calcular tiempo promedio de atención (assignedAt -> completedAt)
                    double avgHours = completedSteps.stream()
                            .filter(s -> s.getAssignedAt() != null && s.getCompletedAt() != null)
                            .mapToDouble(s -> Duration.between(s.getAssignedAt(), s.getCompletedAt()).toMinutes() / 60.0)
                            .average()
                            .orElse(0.0);

                    return AnalyticsDTO.FuncionarioMetrics.builder()
                            .userId(user.getId())
                            .name(user.getFirstName() + " " + user.getLastName())
                            .departmentId(user.getDepartmentId())
                            .departmentName(deptNames.getOrDefault(user.getDepartmentId(), "Sin departamento"))
                            .avgAttentionHours(Math.round(avgHours * 100.0) / 100.0)
                            .tasksProcessed(completedSteps.size())
                            .tasksCompleted(tasksCompleted)
                            .build();
                })
                .sorted(Comparator.comparingLong(AnalyticsDTO.FuncionarioMetrics::getTasksCompleted).reversed())
                .collect(Collectors.toList());
    }

    /**
     * Detecta cuellos de botella: actividades con mayor tiempo de espera.
     */
    public List<AnalyticsDTO.BottleneckInfo> getBottlenecks() {
        List<Tramite> activeTramites = tramiteRepository.findByStatus("EN_CURSO");
        Map<String, String> deptNames = departmentRepository.findAll().stream()
                .collect(Collectors.toMap(Department::getId, Department::getName, (a, b) -> a));

        LocalDateTime now = LocalDateTime.now();

        // Agrupar steps pendientes por nodo (nodeLabel + departmentId)
        Map<String, List<TramiteStep>> pendingByNode = new HashMap<>();
        Map<String, String> nodePolicyName = new HashMap<>();

        for (Tramite tramite : activeTramites) {
            for (TramiteStep step : tramite.getSteps()) {
                if ("PENDING".equals(step.getStatus())) {
                    String key = step.getNodeLabel() + "|" + step.getDepartmentId();
                    pendingByNode.computeIfAbsent(key, k -> new ArrayList<>()).add(step);
                    nodePolicyName.putIfAbsent(key, tramite.getPolicyName());
                }
            }
        }

        return pendingByNode.entrySet().stream()
                .map(entry -> {
                    String[] parts = entry.getKey().split("\\|", 2);
                    String nodeLabel = parts[0];
                    String deptId = parts.length > 1 ? parts[1] : null;
                    List<TramiteStep> steps = entry.getValue();

                    double avgWaitHours = steps.stream()
                            .filter(s -> s.getAssignedAt() != null)
                            .mapToDouble(s -> Duration.between(s.getAssignedAt(), now).toMinutes() / 60.0)
                            .average()
                            .orElse(0.0);

                    String severity;
                    if (avgWaitHours > 48) severity = "HIGH";
                    else if (avgWaitHours > 24) severity = "MEDIUM";
                    else severity = "LOW";

                    return AnalyticsDTO.BottleneckInfo.builder()
                            .nodeLabel(nodeLabel)
                            .policyName(nodePolicyName.getOrDefault(entry.getKey(), "Desconocida"))
                            .departmentId(deptId)
                            .departmentName(deptNames.getOrDefault(deptId, "Sin departamento"))
                            .avgWaitHours(Math.round(avgWaitHours * 100.0) / 100.0)
                            .pendingCount(steps.size())
                            .severity(severity)
                            .build();
                })
                .sorted(Comparator.comparingDouble(AnalyticsDTO.BottleneckInfo::getAvgWaitHours).reversed())
                .collect(Collectors.toList());
    }

    /**
     * Carga por departamento: tareas pendientes, trámites activos, saturación.
     */
    public List<AnalyticsDTO.DepartmentLoad> getDepartmentLoad() {
        List<Department> departments = departmentRepository.findAll();
        List<Tramite> activeTramites = tramiteRepository.findByStatus("EN_CURSO");
        LocalDateTime now = LocalDateTime.now();

        return departments.stream()
                .map(dept -> {
                    // Contar tareas pendientes para este departamento
                    long pendingTasks = activeTramites.stream()
                            .flatMap(t -> t.getSteps().stream())
                            .filter(s -> "PENDING".equals(s.getStatus()) && dept.getId().equals(s.getDepartmentId()))
                            .count();

                    // Contar trámites que tienen al menos una tarea pendiente en este depto
                    long activeTramitesInDept = activeTramites.stream()
                            .filter(t -> t.getSteps().stream()
                                    .anyMatch(s -> "PENDING".equals(s.getStatus()) && dept.getId().equals(s.getDepartmentId())))
                            .count();

                    // Tiempo promedio de espera de tareas pendientes
                    double avgWaitHours = activeTramites.stream()
                            .flatMap(t -> t.getSteps().stream())
                            .filter(s -> "PENDING".equals(s.getStatus()) && dept.getId().equals(s.getDepartmentId()))
                            .filter(s -> s.getAssignedAt() != null)
                            .mapToDouble(s -> Duration.between(s.getAssignedAt(), now).toMinutes() / 60.0)
                            .average()
                            .orElse(0.0);

                    // Calcular nivel de saturación (heurística: 10+ tareas = 100%)
                    int saturation = (int) Math.min(100, pendingTasks * 10);

                    return AnalyticsDTO.DepartmentLoad.builder()
                            .departmentId(dept.getId())
                            .name(dept.getName())
                            .pendingTasks(pendingTasks)
                            .activeTramites(activeTramitesInDept)
                            .avgWaitHours(Math.round(avgWaitHours * 100.0) / 100.0)
                            .saturationLevel(saturation)
                            .build();
                })
                .sorted(Comparator.comparingLong(AnalyticsDTO.DepartmentLoad::getPendingTasks).reversed())
                .collect(Collectors.toList());
    }

    /**
     * Tendencia de creación de trámites en los últimos 30 días.
     */
    public List<AnalyticsDTO.TramiteTrend> getTramiteTrends() {
        List<Tramite> allTramites = tramiteRepository.findAll();
        LocalDate today = LocalDate.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        // Crear mapa con todos los días (incluyendo los que no tienen trámites)
        Map<String, Long> countByDate = new LinkedHashMap<>();
        for (int i = 29; i >= 0; i--) {
            countByDate.put(today.minusDays(i).format(formatter), 0L);
        }

        // Contar trámites por fecha de creación
        allTramites.stream()
                .filter(t -> t.getCreatedAt() != null)
                .filter(t -> t.getCreatedAt().toLocalDate().isAfter(today.minusDays(30)))
                .forEach(t -> {
                    String date = t.getCreatedAt().toLocalDate().format(formatter);
                    countByDate.computeIfPresent(date, (k, v) -> v + 1);
                });

        return countByDate.entrySet().stream()
                .map(entry -> AnalyticsDTO.TramiteTrend.builder()
                        .date(entry.getKey())
                        .count(entry.getValue())
                        .build())
                .collect(Collectors.toList());
    }
}
