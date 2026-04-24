import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tramite.dart';
import '../../providers/auth_provider.dart';
import '../../services/tramite_service.dart';
import '../../widgets/status_badge.dart';
import '../login_screen.dart';
import 'tramite_detail_screen.dart';

class ClienteHome extends StatefulWidget {
  const ClienteHome({super.key});

  @override
  State<ClienteHome> createState() => _ClienteHomeState();
}

class _ClienteHomeState extends State<ClienteHome> {
  List<Tramite> _tramites = [];
  bool _loading = true;
  String? _error;
  String _filter = 'TODOS';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        _tramites = await TramiteService.getByUser(user.id);
      }
    } catch (e) {
      _error = 'Error al cargar tus trámites';
    }

    if (mounted) setState(() => _loading = false);
  }

  List<Tramite> get _filtered {
    if (_filter == 'TODOS') return _tramites;
    return _tramites.where((t) => t.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: const Color(0xFF0f0e17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Hola, ${user?.firstName ?? ''}!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            Text(
              'Tus trámites',
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white54),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF667eea)))
          : _error != null
              ? _buildError()
              : Column(
                  children: [
                    // Filter chips
                    _buildFilters(),
                    // List
                    Expanded(
                      child: _filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.folder_open, size: 48, color: Colors.white.withOpacity(0.15)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No tienes trámites${_filter != 'TODOS' ? ' con este estado' : ''}',
                                    style: TextStyle(color: Colors.white.withOpacity(0.4)),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadData,
                              color: const Color(0xFF667eea),
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: _filtered.length,
                                itemBuilder: (context, index) => _buildCard(_filtered[index]),
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFilters() {
    final filters = ['TODOS', 'EN_CURSO', 'COMPLETADO', 'CANCELADO'];
    final labels = ['Todos', 'En Curso', 'Completados', 'Cancelados'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(filters.length, (i) {
          final selected = _filter == filters[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(labels[i]),
              selected: selected,
              onSelected: (_) => setState(() => _filter = filters[i]),
              backgroundColor: Colors.white.withOpacity(0.05),
              selectedColor: const Color(0xFF667eea).withOpacity(0.2),
              labelStyle: TextStyle(
                color: selected ? const Color(0xFF667eea) : Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: selected ? const Color(0xFF667eea).withOpacity(0.4) : Colors.white.withOpacity(0.08),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCard(Tramite tramite) {
    final completedSteps = tramite.steps.where((s) => s.status == 'COMPLETED').length;
    final totalSteps = tramite.steps.length;
    final progress = totalSteps > 0 ? completedSteps / totalSteps : 0.0;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TramiteDetailScreen(tramite: tramite)),
        );
        _loadData();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF667eea).withOpacity(0.2), const Color(0xFF764ba2).withOpacity(0.15)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.description, color: Color(0xFF667eea), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tramite.policyName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      if (tramite.createdAt != null)
                        Text(
                          '📅 ${tramite.createdAt!.substring(0, 10)}',
                          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                        ),
                    ],
                  ),
                ),
                StatusBadge(status: tramite.status),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: Colors.white.withOpacity(0.06),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        tramite.status == 'COMPLETADO'
                            ? const Color(0xFF43e97b)
                            : const Color(0xFF667eea),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$completedSteps/$totalSteps',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w600),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 48, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: Colors.white.withOpacity(0.5))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF667eea)),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
