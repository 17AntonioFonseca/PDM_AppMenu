import 'package:flutter/material.dart';

class CozinhaScreen extends StatelessWidget {
  const CozinhaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B3F1F),
        foregroundColor: Colors.white,
        title: const Text('Mesa & Mesa — Cozinha'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.soup_kitchen_outlined, size: 80, color: Color(0xFF6B3F1F)),
            SizedBox(height: 16),
            Text(
              'Bem-vindo, Cozinha!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B3F1F),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Ecrã em construção.',
              style: TextStyle(color: Color(0xFF9C7B5E)),
            ),
          ],
        ),
      ),
    );
  }
}
