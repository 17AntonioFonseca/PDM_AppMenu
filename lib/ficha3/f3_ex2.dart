import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Segunda App',
      home: Scaffold(
        body: Text('Aplicação desenvolvida pelo estudante: número_mecanográfico'),
      ),
    );
  }
}
