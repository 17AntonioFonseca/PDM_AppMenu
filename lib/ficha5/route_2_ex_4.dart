import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Route2Ex4 extends StatelessWidget {
  const Route2Ex4({super.key, required this.title});

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
          const Text('Você está na Segunda Route (route_2_ex_4.dart)'),
          ElevatedButton(
            onPressed: () {
              context.go('/');
            },
            child: const Text('Voltar à Primeira Route'),
          ),
        ],
      ),
    );
  }
}
