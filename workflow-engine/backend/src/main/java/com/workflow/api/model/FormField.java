package com.workflow.api.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FormField {

    private String name;
    private String label;

    /**
     * TEXT, NUMBER, DATE, TEXTAREA, SELECT, CHECKBOX
     */
    private String type;

    private boolean required;
    private String placeholder;
    private Integer width;

    /**
     * Solo para SELECT: lista de opciones disponibles
     */
    private java.util.List<String> options;

    /**
     * Valor por defecto (opcional)
     */
    private String defaultValue;
}
