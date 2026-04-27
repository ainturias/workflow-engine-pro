import 'package:flutter/material.dart';
import '../../services/analytics_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await AnalyticsService.getSummary();
      _summary = data;
    } catch (e) {
      _error = 'No se pudieron cargar las métricas.';
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
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: Colors.white.withOpacity(0.8))),
            TextButton(
              onPressed: _loadAnalytics,
              child: const Text('Reintentar', style: TextStyle(color: Color(0xFF667eea))),
            ),
          ],
        ),
      );
    }

    final general = _summary?['generalMetrics'] ?? {};
    final total = general['totalTramites'] ?? 0;
    final enCurso = general['totalActive'] ?? 0;
    final completados = general['totalCompleted'] ?? 0;
    
    double exito = 0.0;
    if (total > 0) {
      exito = (completados / total) * 100;
    }

    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      color: const Color(0xFF667eea),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Vista General del Sistema',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildKpiCard('Total Trámites', '$total', Icons.folder, const Color(0xFF667eea)),
              const SizedBox(width: 16),
              _buildKpiCard('En Curso', '$enCurso', Icons.pending_actions, const Color(0xFFfbbf24)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildKpiCard('Completados', '$completados', Icons.check_circle, const Color(0xFF43e97b)),
              const SizedBox(width: 16),
              _buildKpiCard('Tasa Éxito', '${exito.toStringAsFixed(1)}%', Icons.trending_up, const Color(0xFFa18cd1)),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF667eea).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.insights, color: Color(0xFF667eea), size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sistema Operativo',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'El motor de workflows está funcionando correctamente. Desliza hacia abajo para actualizar.',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
