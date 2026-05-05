import 'package:flutter/material.dart';
import 'basededados.dart';
import 'servidor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final servidor = Servidor('https://dummyjson.com/products');

  // Inicia sincronização periódica em background (sem await - loop infinito)
  // Descarrega imediatamente e repete a cada 1 minuto
  servidor.listaProdutosPeriodica(const Duration(minutes: 1));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ficha 7 - PDM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const RoutePrincipal(),
    );
  }
}

// ─────────────────────────────────────────────
// DRAWER partilhado entre todas as routes
// ─────────────────────────────────────────────
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Principal'),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const RoutePrincipal()),
                (route) => false,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.numbers),
            title: const Text('Total de Produtos'),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const RouteTotalProdutos()),
                (route) => false,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Listar Produtos'),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const RouteListarProdutos()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ROUTE PRINCIPAL
// ─────────────────────────────────────────────
class RoutePrincipal extends StatelessWidget {
  const RoutePrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha 7 - PDM'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 64, color: Colors.deepPurple),
            SizedBox(height: 16),
            Text(
              'Aplicação da Ficha 7',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Use o menu para navegar',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ROUTE TOTAL DE PRODUTOS
// ─────────────────────────────────────────────
class RouteTotalProdutos extends StatelessWidget {
  const RouteTotalProdutos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total de Produtos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: FutureBuilder<int>(
          future: Basededados().contarProdutos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Erro ao carregar dados');
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2,
                    size: 64,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total de produtos: ${snapshot.data}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ROUTE LISTAR PRODUTOS
// ─────────────────────────────────────────────
class RouteListarProdutos extends StatelessWidget {
  const RouteListarProdutos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Produtos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Basededados().listarProdutos(),
        builder: (context, snapshot) {
          // Estado de espera
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Erro
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar produtos'));
          }
          // Sucesso
          if (snapshot.hasData) {
            final produtos = snapshot.data!;
            if (produtos.isEmpty) {
              return const Center(
                child: Text('Sem produtos na base de dados.\nAguarde...'),
              );
            }
            return ListView.builder(
              itemCount: produtos.length,
              itemBuilder: (context, index) {
                final produto = produtos[index];
                return ListTile(
                  leading: const Icon(
                    Icons.shopping_cart,
                    color: Colors.deepPurple,
                  ),
                  title: Text(produto['nome'] ?? 'Sem nome'),
                  trailing: Text(
                    '${(produto['preco'] as double).toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
