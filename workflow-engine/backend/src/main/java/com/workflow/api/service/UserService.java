package com.workflow.api.service;

import com.workflow.api.model.User;
import com.workflow.api.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    public List<User> findAll() {
        return userRepository.findAll();
    }

    public User findById(String id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
    }

    public List<User> findByRole(String role) {
        return userRepository.findAll().stream()
                .filter(u -> u.getRole().equals(role))
                .toList();
    }

    public User assignDepartment(String userId, String departmentId) {
        User user = findById(userId);
        user.setDepartmentId(departmentId);
        user.setUpdatedAt(LocalDateTime.now());
        return userRepository.save(user);
    }

    public User updateRole(String userId, String role) {
        User user = findById(userId);
        user.setRole(role.toUpperCase());
        user.setUpdatedAt(LocalDateTime.now());
        return userRepository.save(user);
    }

    public void deactivate(String userId) {
        User user = findById(userId);
        user.setActive(false);
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);
    }

    public User updateFcmToken(String userId, String fcmToken) {
        User user = findById(userId);
        user.setFcmToken(fcmToken);
        user.setUpdatedAt(LocalDateTime.now());
        return userRepository.save(user);
    }
}
