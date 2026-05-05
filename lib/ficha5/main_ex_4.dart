import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'rotas.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Aplicação GoRouter Ex 4',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: routerEx4,
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Column(
        children: [
          const Text('Você está na Primeira Route (main_ex_4.dart)'),
          ElevatedButton(
            onPressed: () {
              context.go('/route2');
            },
            child: const Text('Ir para a Segunda Route'),
          ),
        ],
      ),
    );
  }
}
