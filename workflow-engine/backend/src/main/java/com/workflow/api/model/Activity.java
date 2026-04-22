package com.workflow.api.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "activities")
public class Activity {

    @Id
    private String id;

    private String name;
    private String description;

    /**
     * Departamento responsable de ejecutar esta actividad
     */
    private String departmentId;

    /**
     * Campos del formulario asociado a esta actividad (plantilla)
     * Cada campo tiene: name, type (TEXT, NUMBER, DATE, TEXTAREA, SELECT), required, options
     */
    private List<FormField> formFields;

    @Builder.Default
    private boolean active = true;

    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    private LocalDateTime updatedAt;
}
