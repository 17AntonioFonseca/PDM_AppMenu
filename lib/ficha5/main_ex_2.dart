import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cálculo de Área do Retângulo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Calculadora de Área'),
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
  late TextEditingController _baseController;
  late TextEditingController _alturaController;
  String _resultado = 'Área é: ';

  @override
  void initState() {
    super.initState();
    _baseController = TextEditingController();
    _alturaController = TextEditingController();
  }

  void _calcularArea() {
    // Substitui potenciais vírgulas por pontos normais de casas decimais
    String baseTexto = _baseController.text.replaceAll(',', '.');
    String alturaTexto = _alturaController.text.replaceAll(',', '.');
    
    double? base = double.tryParse(baseTexto);
    double? altura = double.tryParse(alturaTexto);
    
    if (base != null && altura != null) {
      double area = base * altura;
      setState(() {
        // Mostra o resultado, neste caso limitando a 2 casas decimais caso apropriado
        _resultado = 'Área é: ${area.toStringAsFixed(2)}';
      });
    } else {
      setState(() {
        _resultado = 'Área é: Inválido';
      });
    }
  }

  @override
  void dispose() {
    _baseController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          TextField(
            controller: _baseController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Insira a base do retângulo',
            ),
          ),
          TextField(
            controller: _alturaController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Insira a altura do retângulo',
            ),
          ),
          ElevatedButton(
            onPressed: _calcularArea,
            child: const Text('Calcular Área'),
          ),
          Text(_resultado),
        ],
      ),
    );
  }
}
