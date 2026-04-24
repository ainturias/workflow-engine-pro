import 'package:flutter/material.dart';
import '../models/tramite.dart';

class TimelineWidget extends StatelessWidget {
  final List<TramiteStep> steps;

  const TimelineWidget({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        return _buildStep(step, isLast);
      }),
    );
  }

  Widget _buildStep(TramiteStep step, bool isLast) {
    final color = _statusColor(step.status);
    final icon = _statusIcon(step.status);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Icon(icon, size: 14, color: color),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.nodeLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _statusLabel(step.status),
                          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  if (step.completedByName != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      '👤 ${step.completedByName}',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                    ),
                  ],
                  if (step.comment != null && step.comment!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '💬 ${step.comment}',
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                    ),
                  ],
                  if (step.completedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '📅 ${_formatDate(step.completedAt!)}',
                      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return const Color(0xFF43e97b);
      case 'PENDING':
        return const Color(0xFFfbbf24);
      case 'IN_PROGRESS':
        return const Color(0xFF667eea);
      default:
        return Colors.white54;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'COMPLETED':
        return Icons.check;
      case 'PENDING':
        return Icons.hourglass_empty;
      case 'IN_PROGRESS':
        return Icons.play_arrow;
      default:
        return Icons.circle_outlined;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'COMPLETED':
        return 'Completado';
      case 'PENDING':
        return 'Pendiente';
      case 'IN_PROGRESS':
        return 'En Proceso';
      default:
        return status;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final parts = dateStr.split('T');
      if (parts.length >= 2) {
        return '${parts[0]} ${parts[1].substring(0, 5)}';
      }
      return dateStr;
    } catch (_) {
      return dateStr;
    }
  }
}
