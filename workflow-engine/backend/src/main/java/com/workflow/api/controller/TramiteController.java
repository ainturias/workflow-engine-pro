package com.workflow.api.controller;

import com.workflow.api.model.Tramite;
import com.workflow.api.service.WorkflowEngineService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/tramites")
@RequiredArgsConstructor
public class TramiteController {

    private final WorkflowEngineService engineService;

    /**
     * Iniciar un nuevo trámite
     * Body: { policyId, userId, userName }
     */
    @PostMapping("/start")
    public ResponseEntity<?> startTramite(@RequestBody Map<String, String> body) {
        try {
            Tramite tramite = engineService.startTramite(
                    body.get("policyId"),
                    body.get("userId"),
                    body.get("userName")
            );
            return ResponseEntity.status(HttpStatus.CREATED).body(tramite);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Completar una tarea de un trámite
     * Body: { nodeId, userId, userName, formData: {}, comment }
     */
    @PostMapping("/{tramiteId}/complete")
    public ResponseEntity<?> completeTask(
            @PathVariable String tramiteId,
            @RequestBody Map<String, Object> body) {
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> formData = (Map<String, Object>) body.get("formData");
            Tramite tramite = engineService.completeTask(
                    tramiteId,
                    (String) body.get("nodeId"),
                    (String) body.get("userId"),
                    (String) body.get("userName"),
                    formData,
                    (String) body.get("comment")
            );
            return ResponseEntity.ok(tramite);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Listar todos los trámites
     */
    @GetMapping
    public ResponseEntity<List<Tramite>> getAll() {
        return ResponseEntity.ok(engineService.findAll());
    }

    /**
     * Obtener un trámite por ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable String id) {
        try {
            return ResponseEntity.ok(engineService.findById(id));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * Listar trámites por estado
     */
    @GetMapping("/status/{status}")
    public ResponseEntity<List<Tramite>> getByStatus(@PathVariable String status) {
        return ResponseEntity.ok(engineService.findByStatus(status.toUpperCase()));
    }

    /**
     * Listar trámites de un usuario
     */
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Tramite>> getByUser(@PathVariable String userId) {
        return ResponseEntity.ok(engineService.findByUser(userId));
    }

    /**
     * Tareas pendientes de un departamento
     */
    @GetMapping("/tasks/department/{departmentId}")
    public ResponseEntity<List<Map<String, Object>>> getPendingTasks(@PathVariable String departmentId) {
        return ResponseEntity.ok(engineService.findPendingTasksByDepartment(departmentId));
    }

    /**
     * Todas las tareas de un usuario por departamento (pendientes + completadas)
     */
    @GetMapping("/tasks/user/{departmentId}")
    public ResponseEntity<Map<String, Object>> getUserTasks(@PathVariable String departmentId) {
        return ResponseEntity.ok(engineService.findTasksForUser(departmentId));
    }

    /**
     * Cancelar un trámite
     */
    @PatchMapping("/{id}/cancel")
    public ResponseEntity<?> cancel(@PathVariable String id) {
        try {
            return ResponseEntity.ok(engineService.cancelTramite(id));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
