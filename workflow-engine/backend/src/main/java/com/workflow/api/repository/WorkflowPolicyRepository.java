package com.workflow.api.repository;

import com.workflow.api.model.WorkflowPolicy;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WorkflowPolicyRepository extends MongoRepository<WorkflowPolicy, String> {
    List<WorkflowPolicy> findByActiveTrue();
    List<WorkflowPolicy> findByStatus(String status);
    List<WorkflowPolicy> findByCreatedBy(String userId);
    List<WorkflowPolicy> findByStatusAndActiveTrue(String status);
}
