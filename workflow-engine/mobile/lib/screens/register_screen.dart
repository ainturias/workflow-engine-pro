import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/gradient_button.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'CLIENTE';
  bool _obscurePassword = true;

  final _roles = [
    {'value': 'CLIENTE', 'label': 'Cliente'},
    {'value': 'FUNCIONARIO', 'label': 'Funcionario'},
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      role: _selectedRole,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0e17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crear Cuenta',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Completa tus datos para registrarte',
                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.45)),
              ),
              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildField('Nombre', _firstNameController, Icons.person_outline)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField('Apellido', _lastNameController, Icons.person_outline)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildField('Correo electrónico', _emailController, Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    _buildField('Contraseña', _passwordController, Icons.lock_outline,
                        obscure: _obscurePassword,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white38,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        )),
                    const SizedBox(height: 16),

                    // Role selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rol',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedRole,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF1a1a2e),
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              items: _roles.map((r) {
                                return DropdownMenuItem(
                                  value: r['value'],
                                  child: Text(r['label']!),
                                );
                              }).toList(),
                              onChanged: (v) => setState(() => _selectedRole = v!),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Error
                    Consumer<AuthProvider>(
                      builder: (_, auth, __) {
                        if (auth.error != null) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFf5576c).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: Color(0xFFf5576c), size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(auth.error!, style: const TextStyle(color: Color(0xFFfca5a5), fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    Consumer<AuthProvider>(
                      builder: (_, auth, __) {
                        return GradientButton(
                          text: 'Registrarse',
                          icon: Icons.person_add,
                          isLoading: auth.isLoading,
                          onPressed: _register,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon,
      {bool obscure = false, Widget? suffix, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white38, size: 20),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF667eea))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}
