import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.apiUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);

      // Guardar token y datos del usuario
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', authResponse.token);
      await prefs.setString('user_data', jsonEncode(data));

      return authResponse;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Error al iniciar sesión');
    }
  }

  static Future<AuthResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String role = 'CLIENTE',
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.apiUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', authResponse.token);
      await prefs.setString('user_data', jsonEncode(data));

      return authResponse;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Error al registrarse');
    }
  }

  static Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    final token = prefs.getString('auth_token');

    if (userData != null && token != null) {
      final data = jsonDecode(userData);
      return AuthResponse.fromJson(data).toUser();
    }
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }
}
