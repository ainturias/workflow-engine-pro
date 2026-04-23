package com.workflow.api.service;

import com.workflow.api.model.Department;
import com.workflow.api.repository.DepartmentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DepartmentService {

    private final DepartmentRepository departmentRepository;

    public List<Department> findAll() {
        return departmentRepository.findAll();
    }

    public List<Department> findActive() {
        return departmentRepository.findByActiveTrue();
    }

    public Department findById(String id) {
        return departmentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Departamento no encontrado"));
    }

    public Department create(Department department) {
        if (departmentRepository.existsByName(department.getName())) {
            throw new RuntimeException("Ya existe un departamento con ese nombre");
        }
        department.setCreatedAt(LocalDateTime.now());
        department.setActive(true);
        return departmentRepository.save(department);
    }

    public Department update(String id, Department updated) {
        Department department = findById(id);
        department.setName(updated.getName());
        department.setDescription(updated.getDescription());
        department.setUpdatedAt(LocalDateTime.now());
        return departmentRepository.save(department);
    }

    public void delete(String id) {
        departmentRepository.deleteById(id);
    }
}
