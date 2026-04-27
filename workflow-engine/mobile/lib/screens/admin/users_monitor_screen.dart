import 'package:flutter/material.dart';
import '../../services/analytics_service.dart';

class UsersMonitorScreen extends StatefulWidget {
  const UsersMonitorScreen({super.key});

  @override
  State<UsersMonitorScreen> createState() => _UsersMonitorScreenState();
}

class _UsersMonitorScreenState extends State<UsersMonitorScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _funcionarios = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await AnalyticsService.getFuncionarios(null);
      _funcionarios = data;
    } catch (e) {
      _error = 'No se pudo cargar el directorio del personal.';
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF667eea)));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_off, size: 48, color: Colors.white38),
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: Colors.white.withOpacity(0.8))),
            TextButton(
              onPressed: _loadUsers,
              child: const Text('Reintentar', style: TextStyle(color: Color(0xFF667eea))),
            ),
          ],
        ),
      );
    }

    if (_funcionarios.isEmpty) {
      return Center(
        child: Text(
          'No hay funcionarios registrados.',
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      color: const Color(0xFF667eea),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _funcionarios.length,
        itemBuilder: (context, index) {
          final f = _funcionarios[index];
          return _buildUserCard(f);
        },
      ),
    );
  }

  Widget _buildUserCard(dynamic user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF667eea).withOpacity(0.2),
            radius: 24,
            child: Text(
              (user['name'] != null && user['name'].toString().isNotEmpty)
                  ? user['name'].toString().substring(0, 1).toUpperCase()
                  : '?',
              style: const TextStyle(color: Color(0xFF667eea), fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? 'Usuario Desconocido',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  user['departmentName'] ?? 'Sin Departamento',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatChip(Icons.assignment_turned_in, '${user['tasksCompleted'] ?? 0} completadas', const Color(0xFF43e97b)),
                    const SizedBox(width: 8),
                    _buildStatChip(Icons.assignment, '${user['tasksProcessed'] ?? 0} en proceso', const Color(0xFFfbbf24)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
