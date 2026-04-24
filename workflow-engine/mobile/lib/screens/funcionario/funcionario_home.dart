import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tramite.dart';
import '../../providers/auth_provider.dart';
import '../../services/tramite_service.dart';
import '../../widgets/status_badge.dart';
import '../login_screen.dart';
import 'task_detail_screen.dart';

class FuncionarioHome extends StatefulWidget {
  const FuncionarioHome({super.key});

  @override
  State<FuncionarioHome> createState() => _FuncionarioHomeState();
}

class _FuncionarioHomeState extends State<FuncionarioHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Tramite> _allTramites = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      _allTramites = await TramiteService.getAll();
    } catch (e) {
      _error = 'Error al cargar trámites';
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  List<Tramite> get _pendientes =>
      _allTramites.where((t) => t.status == 'EN_CURSO').toList();

  List<Tramite> get _completados =>
      _allTramites.where((t) => t.status == 'COMPLETADO').toList();

  List<Tramite> get _cancelados =>
      _allTramites.where((t) => t.status == 'CANCELADO').toList();

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
              user?.roleLabel ?? '',
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF667eea),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: 'Pendientes (${_pendientes.length})'),
            Tab(text: 'Completados (${_completados.length})'),
            Tab(text: 'Cancelados (${_cancelados.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF667eea)))
          : _error != null
              ? _buildError()
              : Column(
                  children: [
                    // KPI Cards
                    _buildKpiRow(),
                    // Tab content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTramiteList(_pendientes, 'No hay trámites pendientes'),
                          _buildTramiteList(_completados, 'No hay trámites completados'),
                          _buildTramiteList(_cancelados, 'No hay trámites cancelados'),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildKpiRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildKpi('📋', '${_allTramites.length}', 'Total', const Color(0xFF667eea)),
          const SizedBox(width: 10),
          _buildKpi('⏳', '${_pendientes.length}', 'En Curso', const Color(0xFFfbbf24)),
          const SizedBox(width: 10),
          _buildKpi('✅', '${_completados.length}', 'Completados', const Color(0xFF43e97b)),
        ],
      ),
    );
  }

  Widget _buildKpi(String emoji, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }

  Widget _buildTramiteList(List<Tramite> tramites, String emptyMessage) {
    if (tramites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.white.withOpacity(0.15)),
            const SizedBox(height: 12),
            Text(emptyMessage, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF667eea),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: tramites.length,
        itemBuilder: (context, index) {
          final tramite = tramites[index];
          return _buildTramiteCard(tramite);
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
        _loadData(); // Refresh after returning
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
                Expanded(
                  child: Text(
                    tramite.policyName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                StatusBadge(status: tramite.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: Colors.white.withOpacity(0.4)),
                const SizedBox(width: 4),
                Text(
                  tramite.requestedByName,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                ),
                const Spacer(),
                if (pendingSteps > 0) ...[
                  Icon(Icons.pending_actions, size: 14, color: const Color(0xFFfbbf24).withOpacity(0.7)),
                  const SizedBox(width: 4),
                  Text(
                    '$pendingSteps pendiente${pendingSteps > 1 ? 's' : ''}',
                    style: TextStyle(color: const Color(0xFFfbbf24).withOpacity(0.7), fontSize: 11),
                  ),
                ],
              ],
            ),
            if (tramite.createdAt != null) ...[
              const SizedBox(height: 4),
              Text(
                '📅 ${tramite.createdAt!.substring(0, 10)}',
                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
              ),
            ],
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
