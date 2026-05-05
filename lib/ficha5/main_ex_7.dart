import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App 7',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'App 7 da Ficha 5'),
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
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      // Usando o componente NavigationBar para lidar com os 3 ecrãs simultâneos
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Ionicons.home_outline),
            selectedIcon: Icon(Ionicons.home),
            label: 'Menu 1',
          ),
          NavigationDestination(
            icon: Icon(Ionicons.search_outline),
            selectedIcon: Icon(Ionicons.search),
            label: 'Menu 2',
          ),
          NavigationDestination(
            icon: Icon(Ionicons.person_outline),
            selectedIcon: Icon(Ionicons.person),
            label: 'Menu 3',
          ),
        ],
      ),
      body: Center(
        // Array indexador exatamente com o formato pedido no enunciado
        child: <Widget>[
          const Text('Ecrã 1'),
          const Text('Ecrã 2'),
          const Text('Ecrã 3'),
        ][currentPageIndex],
      ),
    );
  }
}
