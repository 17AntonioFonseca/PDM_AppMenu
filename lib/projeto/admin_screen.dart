import 'package:flutter/material.dart';
import 'servidor.dart';
import 'basededados.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _aCarregar = false;
  int _totalPratos = 0;

  @override
  void initState() {
    super.initState();
    _atualizarContagem();
  }

  Future<void> _atualizarContagem() async {
    final bd = Basededados();
    final pratos = await bd.listarPratos();
    setState(() {
      _totalPratos = pratos.length;
    });
  }

  Future<void> _importarEmenta() async {
    setState(() => _aCarregar = true);

    final servidor = Servidor();
    final sucesso = await servidor.carregarEmentaNaBD();

    await _atualizarContagem();
    setState(() => _aCarregar = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(sucesso ? 'Ementa carregada com sucesso!' : 'Erro ao carregar ementa.'),
          backgroundColor: sucesso ? Colors.green[800] : Colors.red[800],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obter dados do utilizador passados pelo Navigator (opcional)
    final user = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B3F1F),
        foregroundColor: Colors.white,
        title: const Text('Mesa & Mesa — Administrador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.manage_accounts_outlined, size: 80, color: Color(0xFF6B3F1F)),
              const SizedBox(height: 16),
              Text(
                'Bem-vindo, ${user?['nome'] ?? 'Administrador'}!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B3F1F),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE0D0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_totalPratos pratos na base de dados',
                  style: const TextStyle(
                    color: Color(0xFF6B3F1F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              if (_aCarregar)
                const Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF6B3F1F)),
                    SizedBox(height: 16),
                    Text('A importar pratos da API...'),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _importarEmenta,
                    icon: const Icon(Icons.download),
                    label: const Text('Carregar Ementa da API'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B3F1F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),

              const SizedBox(height: 20),
              const Text(
                'Configurações do sistema em construção.',
                style: TextStyle(color: Color(0xFF9C7B5E)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
