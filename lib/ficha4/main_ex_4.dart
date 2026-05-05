import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App 4 da aula 4 TP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'App 4 da aula 4 TP'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: const Icon(Icons.abc),
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
      body: Center(
        // Reproduzi o logótipo programaticamente via widgets de Flutter.
        // Em alternativa, se tiver um ficheiro de imagem na pasta assets,
        // comente a linha abaixo e substitua por:
        // child: Image.asset('assets/images/estgv_logo.png'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildLogoWidget(),
        ),
      ),
    );
  }

  Widget _buildLogoWidget() {
    const Color logoRed = Color(0xFFEE2D41);
    return FittedBox(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: logoRed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 24),
          Transform(
            // Inclinação característica do segundo elemento do logo
            transform: Matrix4.skewX(-0.4),
            child: Container(
              width: 24,
              height: 76,
              decoration: BoxDecoration(
                color: logoRed,
                // Um leve arredondamento para ficar mais idêntico, 
                // embora no logo seja apenas ligeiro.
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'P. Viseu',
                style: TextStyle(
                  color: logoRed,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                  height: 1.0,
                ),
              ),
              Text(
                'Tecnologia e Gestão Viseu',
                style: TextStyle(
                  color: logoRed,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.8,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
