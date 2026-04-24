import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String get _label {
    switch (status) {
      case 'EN_CURSO':
        return 'En Curso';
      case 'COMPLETADO':
        return 'Completado';
      case 'CANCELADO':
        return 'Cancelado';
      case 'PENDING':
        return 'Pendiente';
      case 'IN_PROGRESS':
        return 'En Proceso';
      case 'COMPLETED':
        return 'Completado';
      case 'SKIPPED':
        return 'Omitido';
      default:
        return status;
    }
  }

  Color get _textColor {
    switch (status) {
      case 'EN_CURSO':
      case 'IN_PROGRESS':
        return const Color(0xFF667eea);
      case 'COMPLETADO':
      case 'COMPLETED':
        return const Color(0xFF43e97b);
      case 'CANCELADO':
        return const Color(0xFFf5576c);
      case 'PENDING':
        return const Color(0xFFfbbf24);
      default:
        return Colors.white70;
    }
  }

  Color get _bgColor => _textColor.withOpacity(0.12);
  Color get _borderColor => _textColor.withOpacity(0.25);
}
