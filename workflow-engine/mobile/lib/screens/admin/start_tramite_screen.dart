import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/policy_service.dart';
import '../../services/tramite_service.dart';
import '../funcionario/task_detail_screen.dart';

class StartTramiteScreen extends StatefulWidget {
  const StartTramiteScreen({super.key});

  @override
  State<StartTramiteScreen> createState() => _StartTramiteScreenState();
}

class _StartTramiteScreenState extends State<StartTramiteScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _policies = [];
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    _loadPolicies();
  }

  Future<void> _loadPolicies() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await PolicyService.getPublishedPolicies();
      _policies = data;
    } catch (e) {
      _error = 'No se pudieron cargar las políticas disponibles.';
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _startTramite(String policyId) async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _isStarting = true);

    try {
      final tramite = await TramiteService.startTramite(
        policyId: policyId,
        userId: user.id,
        userName: user.fullName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Trámite "${tramite.policyName}" iniciado con éxito'),
            backgroundColor: const Color(0xFF43e97b),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isStarting = false);
      }
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
            const Icon(Icons.description, size: 48, color: Colors.white38),
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: Colors.white.withOpacity(0.8))),
            TextButton(
              onPressed: _loadPolicies,
              child: const Text('Reintentar', style: TextStyle(color: Color(0xFF667eea))),
            ),
          ],
        ),
      );
    }

    if (_policies.isEmpty) {
      return Center(
        child: Text(
          'No hay políticas publicadas.',
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPolicies,
      color: const Color(0xFF667eea),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _policies.length,
        itemBuilder: (context, index) {
          final p = _policies[index];
          return _buildPolicyCard(p);
        },
      ),
    );
  }

  Widget _buildPolicyCard(dynamic policy) {
    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.file_copy, color: Color(0xFF667eea), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  policy['name'] ?? 'Política sin nombre',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          if (policy['description'] != null && policy['description'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              policy['description'],
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isStarting ? null : () => _startTramite(policy['id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isStarting 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Iniciar Trámite', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
