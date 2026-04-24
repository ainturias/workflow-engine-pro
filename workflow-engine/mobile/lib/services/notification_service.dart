import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_client.dart';

/// Handler para mensajes en background (debe ser top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📩 [BG] Notificación recibida: ${message.notification?.title}');
}

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifs =
      FlutterLocalNotificationsPlugin();
  static String? _currentToken;

  /// Canal de notificación para Android
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'workflow_notifications',
    'Notificaciones de Workflow',
    description: 'Notificaciones de avance de trámites y tareas',
    importance: Importance.high,
  );

  /// Inicializar todo el sistema de notificaciones
  static Future<void> init() async {
    // Registrar handler de background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Solicitar permisos
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('🔔 Permiso de notificaciones: ${settings.authorizationStatus}');

    // Crear canal de notificación Android
    await _localNotifs
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Inicializar notificaciones locales
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifs.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Escuchar mensajes en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Escuchar tap en notificación (cuando app en background)
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Verificar si la app se abrió desde una notificación
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('📩 App abierta desde notificación: ${initialMessage.notification?.title}');
    }

    // Obtener token
    _currentToken = await _fcm.getToken();
    debugPrint('🔑 FCM Token: $_currentToken');

    // Escuchar refresco de token
    _fcm.onTokenRefresh.listen((newToken) {
      _currentToken = newToken;
      debugPrint('🔄 FCM Token actualizado: $newToken');
    });
  }

  /// Obtener el token FCM actual
  static String? get currentToken => _currentToken;

  /// Registrar el FCM token en el backend para el usuario dado
  static Future<void> registerTokenForUser(String userId) async {
    if (_currentToken == null) {
      _currentToken = await _fcm.getToken();
    }
    if (_currentToken == null) return;

    try {
      await ApiClient.put('/users/$userId/fcm-token', {
        'fcmToken': _currentToken!,
      });
      debugPrint('✅ FCM token registrado en backend para user: $userId');
    } catch (e) {
      debugPrint('❌ Error registrando FCM token: $e');
    }
  }

  /// Eliminar el FCM token del backend (en logout)
  static Future<void> unregisterTokenForUser(String userId) async {
    try {
      await ApiClient.put('/users/$userId/fcm-token', {
        'fcmToken': '',
      });
      debugPrint('🗑️ FCM token eliminado del backend');
    } catch (e) {
      debugPrint('❌ Error eliminando FCM token: $e');
    }
  }

  /// Manejar mensajes recibidos en foreground
  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📩 [FG] ${message.notification?.title}: ${message.notification?.body}');

    final notification = message.notification;
    if (notification == null) return;

    // Mostrar notificación local
    _localNotifs.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
          color: const Color(0xFF667eea),
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Cuando el usuario toca la notificación (app en background)
  static void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('📲 Notificación tocada: ${message.notification?.title}');
    // Aquí se podría navegar a la pantalla relevante según message.data
  }

  /// Cuando el usuario toca la notificación local (foreground)
  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('📲 Notificación local tocada: ${response.payload}');
    // Navegar según el payload si es necesario
  }
}
