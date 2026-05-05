import 'package:flutter/material.dart';

class Meubotao extends StatelessWidget {
  const Meubotao({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: ElevatedButton(
        onPressed: () {},
        child: const Text('Login'),
      ),
    );
  }
}
