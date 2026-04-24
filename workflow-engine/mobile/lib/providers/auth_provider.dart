import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = true;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await AuthService.getSavedUser();
      // Registrar FCM token si hay sesión activa
      if (_user != null) {
        NotificationService.registerTokenForUser(_user!.id);
      }
    } catch (_) {
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.login(email, password);
      _user = response.toUser();
      // Registrar FCM token en backend
      await NotificationService.registerTokenForUser(_user!.id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String role = 'CLIENTE',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
      );
      _user = response.toUser();
      // Registrar FCM token en backend
      await NotificationService.registerTokenForUser(_user!.id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    // Limpiar FCM token del backend antes de cerrar sesión
    if (_user != null) {
      await NotificationService.unregisterTokenForUser(_user!.id);
    }
    await AuthService.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
