package com.workflow.api.controller;

import com.workflow.api.model.WorkflowPolicy;
import com.workflow.api.service.WorkflowPolicyService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/policies")
@RequiredArgsConstructor
public class WorkflowPolicyController {

    private final WorkflowPolicyService policyService;

    @GetMapping
    public ResponseEntity<List<WorkflowPolicy>> getAll() {
        return ResponseEntity.ok(policyService.findAll());
    }

    @GetMapping("/published")
    public ResponseEntity<List<WorkflowPolicy>> getPublished() {
        return ResponseEntity.ok(policyService.findPublished());
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable String id) {
        try {
            return ResponseEntity.ok(policyService.findById(id));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping
    public ResponseEntity<?> create(@RequestBody WorkflowPolicy policy) {
        try {
            String userId = SecurityContextHolder.getContext().getAuthentication().getPrincipal().toString();
            policy.setCreatedBy(userId);
            WorkflowPolicy created = policyService.create(policy);
            return ResponseEntity.status(HttpStatus.CREATED).body(created);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable String id, @RequestBody WorkflowPolicy policy) {
        try {
            return ResponseEntity.ok(policyService.update(id, policy));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PatchMapping("/{id}/publish")
    public ResponseEntity<?> publish(@PathVariable String id) {
        try {
            return ResponseEntity.ok(policyService.publish(id));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PatchMapping("/{id}/archive")
    public ResponseEntity<?> archive(@PathVariable String id) {
        try {
            return ResponseEntity.ok(policyService.archive(id));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable String id) {
        try {
            policyService.delete(id);
            return ResponseEntity.ok(Map.of("message", "Política eliminada"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
