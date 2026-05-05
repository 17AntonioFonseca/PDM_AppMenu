import 'package:flutter/material.dart';

class LogiRoute extends StatelessWidget {
  const LogiRoute({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: const Column(
        children: [
          Text('Está na página de Login'),
        ],
      ),
    );
  }
}
