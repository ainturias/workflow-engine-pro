package com.workflow.api.repository;

import com.workflow.api.model.Department;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DepartmentRepository extends MongoRepository<Department, String> {
    List<Department> findByActiveTrue();
    boolean existsByName(String name);
}
