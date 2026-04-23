package com.workflow.api.service;

import com.workflow.api.model.*;
import com.workflow.api.repository.TramiteRepository;
import com.workflow.api.repository.WorkflowPolicyRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Motor de Workflow — Gestiona la ejecución de trámites paso a paso.
 * Soporta flujos: secuencial, condicional (decisión), paralelo (fork/join).
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class WorkflowEngineService {

    private final TramiteRepository tramiteRepository;
    private final WorkflowPolicyRepository policyRepository;

    /**
     * Inicia un nuevo trámite basado en una política publicada.
     */
    public Tramite startTramite(String policyId, String userId, String userName) {
        WorkflowPolicy policy = policyRepository.findById(policyId)
                .orElseThrow(() -> new RuntimeException("Política no encontrada"));

        if (!"PUBLISHED".equals(policy.getStatus())) {
            throw new RuntimeException("Solo se pueden iniciar trámites de políticas publicadas");
        }

        // Buscar nodo START
        WorkflowNode startNode = policy.getNodes().stream()
                .filter(n -> "START".equals(n.getType()))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("La política no tiene nodo de inicio"));

        // Crear el trámite
        Tramite tramite = Tramite.builder()
                .policyId(policyId)
                .policyName(policy.getName())
                .requestedBy(userId)
                .requestedByName(userName)
                .status("EN_CURSO")
                .createdAt(LocalDateTime.now())
                .build();

        tramite = tramiteRepository.save(tramite);

        // Registrar paso del START y avanzar automáticamente
        registerStep(tramite, startNode, userId, userName, null, "Trámite iniciado");
        advanceFromNode(tramite, policy, startNode.getId(), null);

        return tramiteRepository.save(tramite);
    }

    /**
     * Completa una tarea asignada a un funcionario.
     */
    public Tramite completeTask(String tramiteId, String nodeId, String userId,
                                 String userName, Map<String, Object> formData, String comment) {
        Tramite tramite = tramiteRepository.findById(tramiteId)
                .orElseThrow(() -> new RuntimeException("Trámite no encontrado"));

        if (!"EN_CURSO".equals(tramite.getStatus())) {
            throw new RuntimeException("Este trámite ya no está en curso");
        }

        if (!tramite.getActiveNodeIds().contains(nodeId)) {
            throw new RuntimeException("Este nodo no está activo en el trámite");
        }

        WorkflowPolicy policy = policyRepository.findById(tramite.getPolicyId())
                .orElseThrow(() -> new RuntimeException("Política no encontrada"));

        WorkflowNode node = findNode(policy, nodeId);

        // Completar el step actual
        completeCurrentStep(tramite, nodeId, userId, userName, formData, comment);

        // Guardar datos del formulario en el trámite
        if (formData != null) {
            tramite.getData().putAll(formData);
        }

        // Remover nodo de activos
        tramite.getActiveNodeIds().remove(nodeId);

        // Avanzar al siguiente nodo
        advanceFromNode(tramite, policy, nodeId, formData);

        tramite.setUpdatedAt(LocalDateTime.now());
        return tramiteRepository.save(tramite);
    }

    /**
     * Avanza el flujo desde un nodo completado hacia el/los siguiente(s).
     */
    private void advanceFromNode(Tramite tramite, WorkflowPolicy policy,
                                  String completedNodeId, Map<String, Object> formData) {
        WorkflowNode currentNode = findNode(policy, completedNodeId);

        // Buscar transiciones salientes
        List<WorkflowTransition> outgoing = policy.getTransitions().stream()
                .filter(t -> t.getSourceNodeId().equals(completedNodeId))
                .collect(Collectors.toList());

        if (outgoing.isEmpty()) {
            log.warn("Nodo {} no tiene transiciones salientes", completedNodeId);
            return;
        }

        for (WorkflowTransition transition : outgoing) {
            WorkflowNode targetNode = findNode(policy, transition.getTargetNodeId());

            // Evaluar condición si es una transición condicional
            if (currentNode.getType().equals("DECISION") && transition.getCondition() != null
                    && !transition.getCondition().isEmpty()) {
                if (!evaluateCondition(transition.getCondition(), tramite.getData())) {
                    continue; // Saltar esta rama
                }
            }

            processNode(tramite, policy, targetNode);
        }
    }

    /**
     * Procesa un nodo según su tipo.
     */
    private void processNode(Tramite tramite, WorkflowPolicy policy, WorkflowNode node) {
        switch (node.getType()) {
            case "END":
                registerStep(tramite, node, null, null, null, "Trámite finalizado");
                tramite.setStatus("COMPLETADO");
                tramite.setCompletedAt(LocalDateTime.now());
                log.info("Trámite {} completado", tramite.getId());
                break;

            case "ACTIVITY":
                // Crear tarea pendiente para el funcionario del departamento
                TramiteStep step = TramiteStep.builder()
                        .id("step-" + UUID.randomUUID().toString().substring(0, 8))
                        .nodeId(node.getId())
                        .nodeType(node.getType())
                        .nodeLabel(node.getLabel())
                        .departmentId(node.getDepartmentId())
                        .status("PENDING")
                        .assignedAt(LocalDateTime.now())
                        .build();
                tramite.getSteps().add(step);
                tramite.getActiveNodeIds().add(node.getId());
                log.info("Tarea asignada: {} -> Depto: {}", node.getLabel(), node.getDepartmentId());
                break;

            case "DECISION":
                // Las decisiones se resuelven automáticamente evaluando condiciones
                registerStep(tramite, node, null, null, null, "Evaluando decisión");
                advanceFromNode(tramite, policy, node.getId(), tramite.getData());
                break;

            case "FORK":
                // Activar TODAS las ramas salientes en paralelo
                registerStep(tramite, node, null, null, null, "Fork: iniciando ramas paralelas");
                advanceFromNode(tramite, policy, node.getId(), tramite.getData());
                break;

            case "JOIN":
                // Verificar si todas las ramas entrantes llegaron
                handleJoin(tramite, policy, node);
                break;

            default:
                log.warn("Tipo de nodo no reconocido: {}", node.getType());
        }
    }

    /**
     * Maneja la lógica de JOIN: espera a que todas las ramas paralelas lleguen.
     */
    private void handleJoin(Tramite tramite, WorkflowPolicy policy, WorkflowNode joinNode) {
        // Contar cuántas transiciones entran al join
        long incomingCount = policy.getTransitions().stream()
                .filter(t -> t.getTargetNodeId().equals(joinNode.getId()))
                .count();

        // Registrar que una rama llegó
        List<String> arrived = tramite.getPendingJoins()
                .computeIfAbsent(joinNode.getId(), k -> new ArrayList<>());

        // Buscar de dónde viene (último nodo completado que apunta aquí)
        String lastCompleted = tramite.getSteps().stream()
                .filter(s -> "COMPLETED".equals(s.getStatus()))
                .map(TramiteStep::getNodeId)
                .reduce((first, second) -> second)
                .orElse("unknown");

        if (!arrived.contains(lastCompleted)) {
            arrived.add(lastCompleted);
        }

        if (arrived.size() >= incomingCount) {
            // Todas las ramas llegaron — continuar
            registerStep(tramite, joinNode, null, null, null, "Join: todas las ramas completadas");
            tramite.getPendingJoins().remove(joinNode.getId());
            advanceFromNode(tramite, policy, joinNode.getId(), tramite.getData());
        } else {
            log.info("Join {}: esperando {}/{} ramas", joinNode.getLabel(), arrived.size(), incomingCount);
        }
    }

    /**
     * Registra un paso en el historial del trámite.
     */
    private void registerStep(Tramite tramite, WorkflowNode node,
                               String userId, String userName,
                               Map<String, Object> formData, String comment) {
        TramiteStep step = TramiteStep.builder()
                .id("step-" + UUID.randomUUID().toString().substring(0, 8))
                .nodeId(node.getId())
                .nodeType(node.getType())
                .nodeLabel(node.getLabel())
                .departmentId(node.getDepartmentId())
                .completedBy(userId)
                .completedByName(userName)
                .status("COMPLETED")
                .formData(formData)
                .comment(comment)
                .assignedAt(LocalDateTime.now())
                .completedAt(LocalDateTime.now())
                .build();
        tramite.getSteps().add(step);
    }

    /**
     * Completa el step pendiente actual de un nodo.
     */
    private void completeCurrentStep(Tramite tramite, String nodeId,
                                      String userId, String userName,
                                      Map<String, Object> formData, String comment) {
        tramite.getSteps().stream()
                .filter(s -> s.getNodeId().equals(nodeId) && "PENDING".equals(s.getStatus()))
                .findFirst()
                .ifPresent(step -> {
                    step.setStatus("COMPLETED");
                    step.setCompletedBy(userId);
                    step.setCompletedByName(userName);
                    step.setFormData(formData);
                    step.setComment(comment);
                    step.setCompletedAt(LocalDateTime.now());
                });
    }

    /**
     * Evalúa una condición simple contra los datos del trámite.
     * Formato soportado: "campo == valor", "campo != valor", "campo > valor"
     */
    private boolean evaluateCondition(String condition, Map<String, Object> data) {
        try {
            condition = condition.trim();

            // Soportar: campo == valor, campo != valor, campo > valor, campo < valor
            String[] operators = {"==", "!=", ">=", "<=", ">", "<"};

            for (String op : operators) {
                if (condition.contains(op)) {
                    String[] parts = condition.split(op, 2);
                    String field = parts[0].trim();
                    String expected = parts[1].trim().replace("\"", "").replace("'", "");

                    Object actual = data.get(field);
                    if (actual == null) return false;

                    String actualStr = actual.toString();

                    switch (op) {
                        case "==": return actualStr.equalsIgnoreCase(expected);
                        case "!=": return !actualStr.equalsIgnoreCase(expected);
                        case ">":
                            return Double.parseDouble(actualStr) > Double.parseDouble(expected);
                        case "<":
                            return Double.parseDouble(actualStr) < Double.parseDouble(expected);
                        case ">=":
                            return Double.parseDouble(actualStr) >= Double.parseDouble(expected);
                        case "<=":
                            return Double.parseDouble(actualStr) <= Double.parseDouble(expected);
                    }
                }
            }

            // Si no tiene operador, evaluar como booleano
            Object val = data.get(condition);
            return val != null && Boolean.parseBoolean(val.toString());

        } catch (Exception e) {
            log.error("Error evaluando condición '{}': {}", condition, e.getMessage());
            return true; // Por defecto, pasar
        }
    }

    /**
     * Busca un nodo en la política.
     */
    private WorkflowNode findNode(WorkflowPolicy policy, String nodeId) {
        return policy.getNodes().stream()
                .filter(n -> n.getId().equals(nodeId))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Nodo no encontrado: " + nodeId));
    }

    // ==================== CONSULTAS ====================

    public List<Tramite> findAll() {
        return tramiteRepository.findAll();
    }

    public Tramite findById(String id) {
        return tramiteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Trámite no encontrado"));
    }

    public List<Tramite> findByStatus(String status) {
        return tramiteRepository.findByStatus(status);
    }

    public List<Tramite> findByUser(String userId) {
        return tramiteRepository.findByRequestedBy(userId);
    }

    /**
     * Busca tareas pendientes para un departamento específico.
     * Incluye los formFields del nodo para renderizar formularios dinámicos.
     */
    public List<Map<String, Object>> findPendingTasksByDepartment(String departmentId) {
        List<Tramite> activeTramites = tramiteRepository.findByStatus("EN_CURSO");
        List<Map<String, Object>> tasks = new ArrayList<>();

        for (Tramite tramite : activeTramites) {
            WorkflowPolicy policy = policyRepository.findById(tramite.getPolicyId()).orElse(null);

            for (TramiteStep step : tramite.getSteps()) {
                if ("PENDING".equals(step.getStatus()) && departmentId.equals(step.getDepartmentId())) {
                    Map<String, Object> task = new HashMap<>();
                    task.put("tramiteId", tramite.getId());
                    task.put("tramiteName", tramite.getPolicyName());
                    task.put("stepId", step.getId());
                    task.put("nodeId", step.getNodeId());
                    task.put("taskName", step.getNodeLabel());
                    task.put("assignedAt", step.getAssignedAt());
                    task.put("requestedBy", tramite.getRequestedByName());
                    task.put("tramiteData", tramite.getData());

                    // Incluir formFields del nodo
                    if (policy != null) {
                        policy.getNodes().stream()
                                .filter(n -> n.getId().equals(step.getNodeId()))
                                .findFirst()
                                .ifPresent(node -> task.put("formFields", node.getFormFields()));
                    }

                    tasks.add(task);
                }
            }
        }

        return tasks;
    }

    /**
     * Busca todas las tareas de un usuario (por departamento) organizadas por estado.
     */
    public Map<String, Object> findTasksForUser(String departmentId) {
        List<Tramite> allTramites = tramiteRepository.findAll();
        List<Map<String, Object>> pending = new ArrayList<>();
        List<Map<String, Object>> completed = new ArrayList<>();

        for (Tramite tramite : allTramites) {
            WorkflowPolicy policy = policyRepository.findById(tramite.getPolicyId()).orElse(null);

            for (TramiteStep step : tramite.getSteps()) {
                // FILTRO: Solo mostrar actividades (nodos humanos) del departamento solicitado
                if (!departmentId.equals(step.getDepartmentId()) || !"ACTIVITY".equals(step.getNodeType())) continue;

                Map<String, Object> task = new HashMap<>();
                task.put("tramiteId", tramite.getId());
                task.put("tramiteName", tramite.getPolicyName());
                task.put("stepId", step.getId());
                task.put("nodeId", step.getNodeId());
                task.put("taskName", step.getNodeLabel());
                task.put("status", step.getStatus());
                task.put("assignedAt", step.getAssignedAt());
                task.put("completedAt", step.getCompletedAt());
                task.put("completedByName", step.getCompletedByName());
                task.put("comment", step.getComment());
                task.put("requestedBy", tramite.getRequestedByName());
                task.put("tramiteStatus", tramite.getStatus());
                task.put("tramiteData", tramite.getData());

                // Incluir formFields del nodo
                if (policy != null) {
                    policy.getNodes().stream()
                            .filter(n -> n.getId().equals(step.getNodeId()))
                            .findFirst()
                            .ifPresent(node -> task.put("formFields", node.getFormFields()));
                }

                if ("PENDING".equals(step.getStatus())) {
                    pending.add(task);
                } else if ("COMPLETED".equals(step.getStatus())) {
                    completed.add(task);
                }
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("pending", pending);
        result.put("completed", completed);
        result.put("pendingCount", pending.size());
        result.put("completedCount", completed.size());
        return result;
    }

    /**
     * Cancela un trámite en curso.
     */
    public Tramite cancelTramite(String tramiteId) {
        Tramite tramite = findById(tramiteId);
        if (!"EN_CURSO".equals(tramite.getStatus())) {
            throw new RuntimeException("Solo se pueden cancelar trámites en curso");
        }
        tramite.setStatus("CANCELADO");
        tramite.setUpdatedAt(LocalDateTime.now());
        return tramiteRepository.save(tramite);
    }
}
