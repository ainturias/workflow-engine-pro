import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Inicializar servicio de notificaciones
  await NotificationService.init();

  // Barra de estado transparente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const WorkflowMobileApp());
}

class WorkflowMobileApp extends StatelessWidget {
  const WorkflowMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Workflow Engine',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0f0e17),
          primaryColor: const Color(0xFF667eea),
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFF667eea),
            secondary: const Color(0xFF764ba2),
            surface: const Color(0xFF1a1a2e),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
          ),
          snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

/// Splash screen con auto-login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _animController.forward();

    // Wait for auth provider to initialize, then navigate
    Future.delayed(const Duration(milliseconds: 1800), _navigate);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigate() {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();

    // Wait until auth finishes loading
    if (auth.isLoading) {
      Future.delayed(const Duration(milliseconds: 300), _navigate);
      return;
    }

    final destination = auth.isLoggedIn ? const HomeScreen() : const LoginScreen();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0e17),
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.account_tree_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              const Text(
                'Workflow Engine',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Motor de Trámites Inteligente',
                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.4)),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF667eea).withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
