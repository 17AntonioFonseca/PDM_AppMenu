import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conversor Euro para Dólar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Conversor Euro - Dólar'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _controller;
  String _resultado = 'Valor convertido é: ';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void _converter() {
    // Substitui vírgula por ponto para lidar com inputs de teclado em pt-pt
    String texto = _controller.text.replaceAll(',', '.');
    double? valorEuros = double.tryParse(texto);
    
    if (valorEuros != null) {
      double valorDolares = valorEuros * 0.92;
      setState(() {
        _resultado = 'Valor convertido é: ${valorDolares.toStringAsFixed(2)}';
      });
    } else {
      setState(() {
        _resultado = 'Valor convertido é: Inválido. Insira um número.';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      // Zona principal do ecrã utilizando estritamente Column, TextField, ElevatedButton e Text
      body: Column(
        children: [
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Insira o valor em Euros a introduzir',
            ),
          ),
          ElevatedButton(
            onPressed: _converter,
            child: const Text('Converter'),
          ),
          Text(_resultado),
        ],
      ),
    );
  }
}
