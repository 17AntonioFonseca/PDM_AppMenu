import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Quarta App',
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Aplicação desenvolvida pelo estudante: número_mecanográfico'),
              Text('Aluno(a) do curso de Engenharia Informática'),
            ],
          ),
        ),
      ),
    );
  }
}
