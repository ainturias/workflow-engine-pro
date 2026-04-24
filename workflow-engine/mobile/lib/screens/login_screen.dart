import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/gradient_button.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo / Title
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667eea).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.account_tree_rounded, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Workflow Engine',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Motor de Trámites Inteligente',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.45),
                  ),
                ),
                const SizedBox(height: 40),

                // Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email
                      _buildLabel('Correo electrónico'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _emailController,
                        hint: 'tu@email.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      _buildLabel('Contraseña'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _passwordController,
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        obscure: _obscurePassword,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white38,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
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
                                  border: Border.all(color: const Color(0xFFf5576c).withOpacity(0.2)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: Color(0xFFf5576c), size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        auth.error!,
                                        style: const TextStyle(color: Color(0xFFfca5a5), fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // Login button
                      Consumer<AuthProvider>(
                        builder: (_, auth, __) {
                          return GradientButton(
                            text: 'Ingresar',
                            icon: Icons.login,
                            isLoading: auth.isLoading,
                            onPressed: _login,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes cuenta? ',
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.read<AuthProvider>().clearError();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        'Regístrate',
                        style: TextStyle(
                          color: Color(0xFF667eea),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.6),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667eea)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}
