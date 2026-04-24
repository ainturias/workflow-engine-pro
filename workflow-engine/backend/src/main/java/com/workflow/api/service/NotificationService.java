package com.workflow.api.service;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import com.workflow.api.model.User;
import com.workflow.api.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationService {

    private final UserRepository userRepository;

    /**
     * Enviar notificación push a un usuario específico
     */
    public void sendToUser(String userId, String title, String body, Map<String, String> data) {
        try {
            User user = userRepository.findById(userId).orElse(null);
            if (user == null || user.getFcmToken() == null || user.getFcmToken().isEmpty()) {
                log.debug("⏭️ No se envió notificación: usuario {} sin FCM token", userId);
                return;
            }

            sendPush(user.getFcmToken(), title, body, data);
        } catch (Exception e) {
            log.error("❌ Error enviando notificación a usuario {}: {}", userId, e.getMessage());
        }
    }

    /**
     * Notificar al cliente que su trámite avanzó
     */
    public void notifyTramiteProgress(String clienteId, String tramiteName, String stepName) {
        sendToUser(
                clienteId,
                "📋 Tu trámite avanzó",
                "El paso '" + stepName + "' de tu trámite '" + tramiteName + "' fue completado",
                Map.of(
                        "type", "TRAMITE_PROGRESS",
                        "tramiteName", tramiteName,
                        "stepName", stepName
                )
        );
    }

    /**
     * Notificar a funcionarios de un departamento que hay una nueva tarea
     */
    public void notifyNewTaskForDepartment(String departmentId, String tramiteName, String taskName) {
        try {
            List<User> funcionarios = userRepository.findByRoleAndDepartmentId("FUNCIONARIO", departmentId);

            for (User funcionario : funcionarios) {
                if (funcionario.getFcmToken() != null && !funcionario.getFcmToken().isEmpty()) {
                    sendPush(
                            funcionario.getFcmToken(),
                            "📌 Nueva tarea asignada",
                            "Tarea '" + taskName + "' del trámite '" + tramiteName + "'",
                            Map.of(
                                    "type", "NEW_TASK",
                                    "tramiteName", tramiteName,
                                    "taskName", taskName
                            )
                    );
                }
            }

            log.info("📤 Notificación enviada a {} funcionarios del departamento {}",
                    funcionarios.size(), departmentId);
        } catch (Exception e) {
            log.error("❌ Error notificando departamento {}: {}", departmentId, e.getMessage());
        }
    }

    /**
     * Enviar push notification vía Firebase Cloud Messaging
     */
    private void sendPush(String fcmToken, String title, String body, Map<String, String> data) {
        try {
            if (FirebaseApp.getApps().isEmpty()) {
                log.warn("⚠️ Firebase no inicializado, no se puede enviar push");
                return;
            }

            Message message = Message.builder()
                    .setToken(fcmToken)
                    .setNotification(Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build())
                    .putAllData(data)
                    .build();

            String response = FirebaseMessaging.getInstance().send(message);
            log.info("✅ Push enviado exitosamente: {}", response);
        } catch (Exception e) {
            log.error("❌ Error enviando push a token {}: {}", fcmToken, e.getMessage());
        }
    }
}
