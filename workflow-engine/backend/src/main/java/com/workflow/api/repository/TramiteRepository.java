package com.workflow.api.repository;

import com.workflow.api.model.Tramite;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TramiteRepository extends MongoRepository<Tramite, String> {
    List<Tramite> findByStatus(String status);
    List<Tramite> findByRequestedBy(String userId);
    List<Tramite> findByPolicyId(String policyId);
    List<Tramite> findByActiveNodeIdsContaining(String nodeId);
}
