import 'dart:convert';
import '../models/tramite.dart';
import 'api_client.dart';

class TramiteService {
  static Future<List<Tramite>> getAll() async {
    final response = await ApiClient.get('/tramites');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((t) => Tramite.fromJson(t)).toList();
    }
    throw Exception('Error al obtener trámites');
  }

  static Future<Tramite> getById(String id) async {
    final response = await ApiClient.get('/tramites/$id');
    if (response.statusCode == 200) {
      return Tramite.fromJson(jsonDecode(response.body));
    }
    throw Exception('Trámite no encontrado');
  }

  static Future<List<Tramite>> getByUser(String userId) async {
    final response = await ApiClient.get('/tramites/user/$userId');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((t) => Tramite.fromJson(t)).toList();
    }
    throw Exception('Error al obtener trámites del usuario');
  }

  static Future<List<Tramite>> getByStatus(String status) async {
    final response = await ApiClient.get('/tramites/status/$status');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((t) => Tramite.fromJson(t)).toList();
    }
    throw Exception('Error al obtener trámites por estado');
  }

  static Future<List<PendingTask>> getPendingTasks(String departmentId) async {
    final response = await ApiClient.get('/tramites/tasks/department/$departmentId');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((t) => PendingTask.fromJson(t)).toList();
    }
    throw Exception('Error al obtener tareas pendientes');
  }

  static Future<Tramite> completeTask({
    required String tramiteId,
    required String nodeId,
    required String userId,
    required String userName,
    required Map<String, dynamic> formData,
    required String comment,
  }) async {
    final response = await ApiClient.post('/tramites/$tramiteId/complete', {
      'nodeId': nodeId,
      'userId': userId,
      'userName': userName,
      'formData': formData,
      'comment': comment,
    });

    if (response.statusCode == 200) {
      return Tramite.fromJson(jsonDecode(response.body));
    }
    final error = jsonDecode(response.body);
    throw Exception(error['error'] ?? 'Error al completar tarea');
  }

  static Future<Tramite> startTramite({
    required String policyId,
    required String userId,
    required String userName,
  }) async {
    final response = await ApiClient.post('/tramites/start', {
      'policyId': policyId,
      'userId': userId,
      'userName': userName,
    });

    if (response.statusCode == 201) {
      return Tramite.fromJson(jsonDecode(response.body));
    }
    final error = jsonDecode(response.body);
    throw Exception(error['error'] ?? 'Error al iniciar trámite');
  }
}
