import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'rotas_ex6.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'App com Drawer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: rotasEx6,
    );
  }
}

class MainEx6 extends StatelessWidget {
  const MainEx6({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            ListTile(
              title: const Text('Definições'),
              onTap: () {
                context.go('/defin');
              },
            ),
            ListTile(
              title: const Text('Login'),
              onTap: () {
                context.go('/logi');
              },
            ),
          ],
        ),
      ),
      body: const Column(
        children: [
          Text('Menu Principal. Deslize ou carregue no menu sanduiche (Drawer).'),
        ],
      ),
    );
  }
}
