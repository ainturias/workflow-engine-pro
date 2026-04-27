import 'package:flutter/material.dart';
import '../../models/tramite.dart';
import '../../services/tramite_service.dart';
import '../../widgets/status_badge.dart';
import '../funcionario/task_detail_screen.dart';

class TramitesMonitorScreen extends StatefulWidget {
  const TramitesMonitorScreen({super.key});

  @override
  State<TramitesMonitorScreen> createState() => _TramitesMonitorScreenState();
}

class _TramitesMonitorScreenState extends State<TramitesMonitorScreen> {
  bool _loading = true;
  String? _error;
  List<Tramite> _tramites = [];

  @override
  void initState() {
    super.initState();
    _loadTramites();
  }

  Future<void> _loadTramites() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      _tramites = await TramiteService.getAll();
    } catch (e) {
      _error = 'No se pudieron cargar los trámites.';
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
            const Icon(Icons.cloud_off, size: 48, color: Colors.white38),
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: Colors.white.withOpacity(0.8))),
            TextButton(
              onPressed: _loadTramites,
              child: const Text('Reintentar', style: TextStyle(color: Color(0xFF667eea))),
            ),
          ],
        ),
      );
    }

    if (_tramites.isEmpty) {
      return Center(
        child: Text(
          'No hay trámites en el sistema.',
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTramites,
      color: const Color(0xFF667eea),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tramites.length,
        itemBuilder: (context, index) {
          final t = _tramites[index];
          return _buildTramiteCard(t);
        },
      ),
    );
  }

  Widget _buildTramiteCard(Tramite tramite) {
    final pendingSteps = tramite.steps.where((s) => s.status == 'PENDING').length;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TaskDetailScreen(tramite: tramite)),
        );
        _loadTramites();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    tramite.policyName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                StatusBadge(status: tramite.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.white.withOpacity(0.4)),
                const SizedBox(width: 4),
                Text(
                  'Solicitante: ${tramite.requestedByName}',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.format_list_numbered, size: 14, color: Colors.white.withOpacity(0.4)),
                const SizedBox(width: 4),
                Text(
                  '${tramite.steps.length} pasos totales',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                ),
                const Spacer(),
                if (pendingSteps > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFfbbf24).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$pendingSteps en espera',
                      style: const TextStyle(color: Color(0xFFfbbf24), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            if (tramite.createdAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.white.withOpacity(0.3)),
                  const SizedBox(width: 4),
                  Text(
                    tramite.createdAt!.substring(0, 10),
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}
