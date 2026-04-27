import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/tramite_service.dart';
import '../../widgets/status_badge.dart';
import 'task_detail_screen.dart';

class MisTareasScreen extends StatefulWidget {
  const MisTareasScreen({super.key});

  @override
  State<MisTareasScreen> createState() => _MisTareasScreenState();
}

class _MisTareasScreenState extends State<MisTareasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _pendientes = [];
  List<dynamic> _completados = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = context.read<AuthProvider>().user;
      if (user != null && user.departmentId != null) {
        final data = await TramiteService.getMyTasks(user.departmentId!);
        _pendientes = data['pending'] ?? [];
        _completados = data['completed'] ?? [];
      } else if (user != null && user.role == 'ADMIN') {
         _error = 'Los administradores deben usar la vista web o tener un departamento asignado.';
      }
    } catch (e) {
      _error = 'Error al cargar tus tareas';
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: const Color(0xFF0f0e17),
          child: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF667eea),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white38,
            labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Pendientes (${_pendientes.length})'),
              Tab(text: 'Completados (${_completados.length})'),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF667eea)))
              : _error != null
                  ? _buildError()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTaskList(_pendientes, 'No tienes tareas pendientes', true),
                        _buildTaskList(_completados, 'No tienes tareas completadas', false),
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _buildTaskList(List<dynamic> tasks, String emptyMessage, bool isPending) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isPending ? Icons.inbox : Icons.check_circle_outline, size: 64, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text(emptyMessage, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF667eea),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _buildTaskCard(task, isPending);
        },
      ),
    );
  }

  Widget _buildTaskCard(dynamic task, bool isPending) {
    return GestureDetector(
      onTap: () async {
        try {
           final tramite = await TramiteService.getById(task['tramiteId']);
           if (mounted) {
             await Navigator.push(
               context,
               MaterialPageRoute(builder: (_) => TaskDetailScreen(tramite: tramite)),
             );
             _loadData();
           }
        } catch (e) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Error al cargar el trámite')),
           );
        }
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
                    task['tramiteName'] ?? 'Trámite',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                StatusBadge(status: task['tramiteStatus'] ?? ''),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isPending ? const Color(0xFFfbbf24).withOpacity(0.15) : const Color(0xFF43e97b).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPending ? Icons.pending_actions : Icons.check_circle, 
                    size: 14, 
                    color: isPending ? const Color(0xFFfbbf24) : const Color(0xFF43e97b)
                  ),
                  const SizedBox(width: 6),
                  Text(
                    task['taskName'] ?? 'Tarea',
                    style: TextStyle(
                      color: isPending ? const Color(0xFFfbbf24) : const Color(0xFF43e97b),
                      fontSize: 12,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: Colors.white.withOpacity(0.4)),
                const SizedBox(width: 4),
                Text(
                  'Solicitante: ${task['requestedBy'] ?? 'Desconocido'}',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.redAccent.withOpacity(0.8)),
            const SizedBox(height: 16),
            Text(
              _error!, 
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
              child: const Text('Reintentar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
