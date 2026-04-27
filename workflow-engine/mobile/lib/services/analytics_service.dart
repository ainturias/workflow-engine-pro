import 'dart:convert';
import 'api_client.dart';

class AnalyticsService {
  static Future<Map<String, dynamic>> getSummary() async {
    final response = await ApiClient.get('/analytics/summary');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al obtener el resumen de métricas');
  }

  static Future<List<dynamic>> getFuncionarios(String? departmentId) async {
    String url = '/analytics/funcionarios';
    if (departmentId != null && departmentId.isNotEmpty) {
      url += '?departmentId=$departmentId';
    }
    final response = await ApiClient.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al obtener métricas de funcionarios');
  }
}
