import 'dart:convert';
import 'api_client.dart';

class PolicyService {
  static Future<List<dynamic>> getPolicies() async {
    final response = await ApiClient.get('/policies');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al obtener políticas');
  }

  static Future<List<dynamic>> getPublishedPolicies() async {
    final response = await ApiClient.get('/policies/published');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al obtener políticas publicadas');
  }
}
