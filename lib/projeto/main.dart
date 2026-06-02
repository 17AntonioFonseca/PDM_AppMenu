import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'cliente_screen.dart';
import 'empregado_screen.dart';
import 'cozinha_screen.dart';
import 'admin_screen.dart';

// =====================================================
// MAIN — Ponto de entrada do projeto
// =====================================================
// ESTRUTURA DE ROTAS:
//   /            → HomeScreen (splash)
//   /login       → LoginScreen
//   /cliente     → ClienteScreen
//   /empregado   → EmpregadoScreen
//   /cozinha     → CozinhaScreen
//   /admin       → AdminScreen
// =====================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MesaEMesaApp());
}

class MesaEMesaApp extends StatelessWidget {
  const MesaEMesaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mesa & Mesa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4821A),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/cliente': (context) => const ClienteScreen(),
        '/empregado': (context) => const EmpregadoScreen(),
        '/cozinha': (context) => const CozinhaScreen(),
        '/admin': (context) => const AdminScreen(),
      },
    );
  }
}
