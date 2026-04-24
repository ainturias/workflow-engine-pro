import 'package:flutter/material.dart';
import '../../models/tramite.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/timeline_widget.dart';

class TramiteDetailScreen extends StatelessWidget {
  final Tramite tramite;

  const TramiteDetailScreen({super.key, required this.tramite});

  @override
  Widget build(BuildContext context) {
    final completedSteps = tramite.steps.where((s) => s.status == 'COMPLETED').length;
    final totalSteps = tramite.steps.length;
    final progress = totalSteps > 0 ? completedSteps / totalSteps : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0f0e17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Seguimiento del Trámite',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF667eea).withOpacity(0.15),
                    const Color(0xFF764ba2).withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF667eea).withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tramite.policyName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                      StatusBadge(status: tramite.status),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Progress
                  Row(
                    children: [
                      Text(
                        'Progreso: ',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                      ),
                      Text(
                        '$completedSteps de $totalSteps pasos',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(color: Color(0xFF667eea), fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        tramite.status == 'COMPLETADO'
                            ? const Color(0xFF43e97b)
                            : const Color(0xFF667eea),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info rows
                  _buildInfoRow(Icons.calendar_today, 'Creado',
                      tramite.createdAt?.substring(0, 10) ?? 'N/A'),
                  if (tramite.completedAt != null)
                    _buildInfoRow(Icons.check_circle, 'Completado',
                        tramite.completedAt!.substring(0, 10)),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Current step highlight
            if (tramite.status == 'EN_CURSO') ...[
              _buildCurrentStep(),
              const SizedBox(height: 24),
            ],

            // Timeline
            Text(
              '📋 Línea de Tiempo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9)),
            ),
            const SizedBox(height: 16),
            TimelineWidget(steps: tramite.steps),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    final pendingStep = tramite.steps.where((s) => s.status == 'PENDING').toList();
    if (pendingStep.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFfbbf24).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFfbbf24).withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFfbbf24).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.hourglass_bottom, color: Color(0xFFfbbf24), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Paso actual',
                  style: TextStyle(color: Color(0xFFfbbf24), fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  pendingStep.first.nodeLabel,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  'En espera de revisión por un funcionario',
                  style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white.withOpacity(0.4)),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
          Text(value, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
