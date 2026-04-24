package com.workflow.api.controller;

import com.workflow.api.model.User;
import com.workflow.api.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping
    public ResponseEntity<List<User>> getAll() {
        return ResponseEntity.ok(userService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable String id) {
        try {
            return ResponseEntity.ok(userService.findById(id));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/role/{role}")
    public ResponseEntity<List<User>> getByRole(@PathVariable String role) {
        return ResponseEntity.ok(userService.findByRole(role.toUpperCase()));
    }

    @PatchMapping("/{id}/department")
    public ResponseEntity<?> assignDepartment(@PathVariable String id, @RequestBody Map<String, String> body) {
        try {
            User user = userService.assignDepartment(id, body.get("departmentId"));
            return ResponseEntity.ok(user);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PatchMapping("/{id}/role")
    public ResponseEntity<?> updateRole(@PathVariable String id, @RequestBody Map<String, String> body) {
        try {
            User user = userService.updateRole(id, body.get("role"));
            return ResponseEntity.ok(user);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deactivate(@PathVariable String id) {
        try {
            userService.deactivate(id);
            return ResponseEntity.ok(Map.of("message", "Usuario desactivado"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PutMapping("/{id}/fcm-token")
    public ResponseEntity<?> updateFcmToken(@PathVariable String id, @RequestBody Map<String, String> body) {
        try {
            User user = userService.updateFcmToken(id, body.get("fcmToken"));
            return ResponseEntity.ok(Map.of("message", "FCM token actualizado"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
