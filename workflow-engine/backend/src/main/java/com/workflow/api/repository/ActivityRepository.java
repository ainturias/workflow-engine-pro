package com.workflow.api.repository;

import com.workflow.api.model.Activity;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ActivityRepository extends MongoRepository<Activity, String> {
    List<Activity> findByActiveTrue();
    List<Activity> findByDepartmentId(String departmentId);
    List<Activity> findByDepartmentIdAndActiveTrue(String departmentId);
}
