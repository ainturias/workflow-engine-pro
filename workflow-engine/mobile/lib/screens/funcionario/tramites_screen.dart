import 'package:flutter/material.dart';

class TramitesScreen extends StatelessWidget {
  const TramitesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.construction, size: 64, color: Colors.white.withOpacity(0.2)),
            ),
            const SizedBox(height: 24),
            Text(
              'Próximamente',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.6)),
            ),
            const SizedBox(height: 12),
            Text(
              'En esta sección podrás iniciar nuevos trámites y ver los catálogos disponibles según tu rol y departamento.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
