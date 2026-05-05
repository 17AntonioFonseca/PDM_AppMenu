import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final String numeroMecanografico = 'número_mecanográfico';

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Terceira App',
      home: Scaffold(
        body: Center(
          child: Text('Aplicação desenvolvida pelo estudante: $numeroMecanografico'),
        ),
      ),
    );
  }
}
