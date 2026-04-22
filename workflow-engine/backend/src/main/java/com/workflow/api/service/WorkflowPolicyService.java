package com.workflow.api.service;

import com.workflow.api.model.WorkflowPolicy;
import com.workflow.api.repository.WorkflowPolicyRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class WorkflowPolicyService {

    private final WorkflowPolicyRepository policyRepository;

    public List<WorkflowPolicy> findAll() {
        return policyRepository.findByActiveTrue();
    }

    public List<WorkflowPolicy> findPublished() {
        return policyRepository.findByStatusAndActiveTrue("PUBLISHED");
    }

    public WorkflowPolicy findById(String id) {
        return policyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Política no encontrada"));
    }

    public WorkflowPolicy create(WorkflowPolicy policy) {
        policy.setStatus("DRAFT");
        policy.setActive(true);
        policy.setCreatedAt(LocalDateTime.now());
        return policyRepository.save(policy);
    }

    public WorkflowPolicy update(String id, WorkflowPolicy updated) {
        WorkflowPolicy policy = findById(id);
        policy.setName(updated.getName());
        policy.setDescription(updated.getDescription());
        policy.setNodes(updated.getNodes());
        policy.setTransitions(updated.getTransitions());
        policy.setSwimlanes(updated.getSwimlanes());
        policy.setUpdatedAt(LocalDateTime.now());
        return policyRepository.save(policy);
    }

    public WorkflowPolicy publish(String id) {
        WorkflowPolicy policy = findById(id);
        // Validar que tenga al menos un nodo START y un END
        boolean hasStart = policy.getNodes().stream().anyMatch(n -> "START".equals(n.getType()));
        boolean hasEnd = policy.getNodes().stream().anyMatch(n -> "END".equals(n.getType()));
        if (!hasStart || !hasEnd) {
            throw new RuntimeException("La política debe tener al menos un nodo de Inicio y uno de Fin");
        }
        policy.setStatus("PUBLISHED");
        policy.setUpdatedAt(LocalDateTime.now());
        return policyRepository.save(policy);
    }

    public WorkflowPolicy archive(String id) {
        WorkflowPolicy policy = findById(id);
        policy.setStatus("ARCHIVED");
        policy.setUpdatedAt(LocalDateTime.now());
        return policyRepository.save(policy);
    }

    public void delete(String id) {
        WorkflowPolicy policy = findById(id);
        policy.setActive(false);
        policy.setUpdatedAt(LocalDateTime.now());
        policyRepository.save(policy);
    }
}
