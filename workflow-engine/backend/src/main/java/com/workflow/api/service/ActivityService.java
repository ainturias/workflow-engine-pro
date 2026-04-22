package com.workflow.api.service;

import com.workflow.api.model.Activity;
import com.workflow.api.repository.ActivityRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ActivityService {

    private final ActivityRepository activityRepository;

    public List<Activity> findAll() {
        return activityRepository.findAll();
    }

    public List<Activity> findActive() {
        return activityRepository.findByActiveTrue();
    }

    public List<Activity> findByDepartment(String departmentId) {
        return activityRepository.findByDepartmentIdAndActiveTrue(departmentId);
    }

    public Activity findById(String id) {
        return activityRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Actividad no encontrada"));
    }

    public Activity create(Activity activity) {
        activity.setCreatedAt(LocalDateTime.now());
        activity.setActive(true);
        return activityRepository.save(activity);
    }

    public Activity update(String id, Activity updated) {
        Activity activity = findById(id);
        activity.setName(updated.getName());
        activity.setDescription(updated.getDescription());
        activity.setDepartmentId(updated.getDepartmentId());
        activity.setFormFields(updated.getFormFields());
        activity.setUpdatedAt(LocalDateTime.now());
        return activityRepository.save(activity);
    }

    public void delete(String id) {
        Activity activity = findById(id);
        activity.setActive(false);
        activity.setUpdatedAt(LocalDateTime.now());
        activityRepository.save(activity);
    }
}
