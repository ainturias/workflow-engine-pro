import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tramite.dart';
import '../../providers/auth_provider.dart';
import '../../services/tramite_service.dart';
import '../../widgets/dynamic_form.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/timeline_widget.dart';

class TaskDetailScreen extends StatefulWidget {
  final Tramite tramite;

  const TaskDetailScreen({super.key, required this.tramite});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Tramite _tramite;
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    _tramite = widget.tramite;
  }

  TramiteStep? get _pendingStep {
    try {
      return _tramite.steps.firstWhere((s) => s.status == 'PENDING');
    } catch (_) {
      return null;
    }
  }

  Future<void> _completeTask(Map<String, dynamic> data) async {
    final step = _pendingStep;
    if (step == null) return;

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _completing = true);

    try {
      final updated = await TramiteService.completeTask(
        tramiteId: _tramite.id!,
        nodeId: step.nodeId,
        userId: user.id,
        userName: user.fullName,
        formData: data['formData'] ?? {},
        comment: data['comment'] ?? '',
      );

      setState(() {
        _tramite = updated;
        _completing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Tarea completada exitosamente'),
            backgroundColor: const Color(0xFF43e97b).withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        // Volver a la lista de tareas
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _completing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${e.toString().replaceFirst("Exception: ", "")}'),
            backgroundColor: const Color(0xFFf5576c).withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _pendingStep;

    return Scaffold(
      backgroundColor: const Color(0xFF0f0e17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detalle del Trámite', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF667eea).withOpacity(0.15), const Color(0xFF764ba2).withOpacity(0.1)],
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
                          _tramite.policyName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                      StatusBadge(status: _tramite.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.person_outline, 'Solicitante', _tramite.requestedByName),
                  if (_tramite.createdAt != null)
                    _buildInfoRow(Icons.calendar_today, 'Creado', _tramite.createdAt!.substring(0, 10)),
                  _buildInfoRow(Icons.layers, 'Steps', '${_tramite.steps.length} paso(s)'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Complete task form
            if (step != null && _tramite.status == 'EN_CURSO') ...[
              Builder(
                builder: (context) {
                  final user = context.watch<AuthProvider>().user;
                  final isMyDepartment = user?.departmentId == step.departmentId;
                  final isAdmin = user?.role == 'ADMIN';
                  
                  // Solo mostrar si es mi departamento o soy Admin (opcional)
                  if (!isMyDepartment && !isAdmin) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.hourglass_empty, color: Colors.white38, size: 32),
                          const SizedBox(height: 12),
                          const Text(
                            'Esperando Acción',
                            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Esta tarea (${step.nodeLabel}) debe ser completada por el departamento correspondiente.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF43e97b).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF43e97b).withOpacity(0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF43e97b).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.edit_note, color: Color(0xFF43e97b), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tarea Pendiente',
                                    style: TextStyle(color: Color(0xFF43e97b), fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                  Text(
                                    step.nodeLabel,
                                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (_completing)
                          const Center(child: CircularProgressIndicator(color: Color(0xFF43e97b)))
                        else
                          DynamicForm(
                            fields: step.formFields ?? [],
                            submitLabel: 'Completar Tarea',
                            onSubmit: (formData) => _completeTask({'formData': formData}),
                          ),
                      ],
                    ),
                  );
                }
              ),
              const SizedBox(height: 24),
            ],

            // Timeline
            Text(
              '📋 Historial de Pasos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9)),
            ),
            const SizedBox(height: 16),
            TimelineWidget(steps: _tramite.steps),
          ],
        ),
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
