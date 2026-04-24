import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// HTTP client wrapper que inyecta automáticamente el token JWT.
class ApiClient {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String path) async {
    final headers = await _headers();
    return http.get(Uri.parse('${ApiConfig.apiUrl}$path'), headers: headers);
  }

  static Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final headers = await _headers();
    return http.post(
      Uri.parse('${ApiConfig.apiUrl}$path'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> patch(String path, Map<String, dynamic> body) async {
    final headers = await _headers();
    return http.patch(
      Uri.parse('${ApiConfig.apiUrl}$path'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final headers = await _headers();
    return http.put(
      Uri.parse('${ApiConfig.apiUrl}$path'),
      headers: headers,
      body: jsonEncode(body),
    );
  }
}
