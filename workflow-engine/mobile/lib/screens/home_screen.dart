import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'funcionario/funcionario_home.dart';
import 'cliente/cliente_home.dart';
import 'login_screen.dart';

/// Router screen que muestra la pantalla correcta según el rol del usuario.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        if (!auth.isLoggedIn) {
          return const LoginScreen();
        }

        final user = auth.user!;
        switch (user.role) {
          case 'FUNCIONARIO':
          case 'ADMIN':
            return const FuncionarioHome();
          case 'CLIENTE':
          default:
            return const ClienteHome();
        }
      },
    );
  }
}
