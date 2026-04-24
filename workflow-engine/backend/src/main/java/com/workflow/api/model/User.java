package com.workflow.api.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "users")
public class User {

    @Id
    private String id;

    @Indexed(unique = true)
    private String email;

    private String password;
    private String firstName;
    private String lastName;

    /**
     * Roles: ADMIN, DISEÑADOR, FUNCIONARIO, CLIENTE
     */
    private String role;

    /**
     * Departamento al que pertenece (solo para FUNCIONARIO)
     */
    private String departmentId;

    /**
     * Token de Firebase Cloud Messaging para push notifications
     */
    private String fcmToken;

    @Builder.Default
    private boolean active = true;

    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    private LocalDateTime updatedAt;
}
