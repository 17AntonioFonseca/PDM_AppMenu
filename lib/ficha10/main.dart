import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'basedados.dart';
import 'servidor.dart';
import 'shapref.dart';
import 'notificacoes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    await Notificacoes().inicializar();
  } catch (e) {
    debugPrint('Erro a inicializar Firebase: $e');
  }

  final String ultimaAtualizacao = await ShaPref().getUltimaAtualizacao();
  await Servidor().sincronizar(ultimaAtualizacao);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ficha 10 – Antigravity',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const EcraPrincipal(),
    );
  }
}

class EcraPrincipal extends StatefulWidget {
  const EcraPrincipal({super.key});

  @override
  State<EcraPrincipal> createState() => _EcraPrincipalState();
}

class _EcraPrincipalState extends State<EcraPrincipal> {
  final Basedados _bd = Basedados();
  int _totalProdutos = 0;
  int _totalClientes = 0;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _atualizarContadores();

    // Escuta notificações de atualização
    _sub = atualizadorNotificacoes.stream.listen((_) {
      _atualizarContadores();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _atualizarContadores() async {
    final p = await _bd.contarProdutos();
    final c = await _bd.contarClientes();
    setState(() {
      _totalProdutos = p;
      _totalClientes = c;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Antigravity – Ficha 10'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.inventory_2, color: Colors.indigo, size: 40),
                title: const Text('Produtos na BD local'),
                trailing: Text(
                  '$_totalProdutos',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.people, color: Colors.teal, size: 40),
                title: const Text('Clientes na BD local'),
                trailing: Text(
                  '$_totalClientes',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}