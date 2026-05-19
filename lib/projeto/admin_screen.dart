import 'package:flutter/material.dart';
import 'servidor.dart';
import 'basededados.dart';
import 'admin_gestao_ementa.dart';
import 'admin_gestao_contas.dart';
import 'admin_gestao_mesas.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _aCarregar = false;
  int _totalPratos = 0;
  int _totalUsers = 0;
  int _totalMesas = 0;
  int _mesasOcupadas = 0;

  @override
  void initState() {
    super.initState();
    _atualizarDashboard();
  }

  Future<void> _atualizarDashboard() async {
    final bd = Basededados();
    final pratos = await bd.listarPratos();
    final utilizadores = await bd.listarUtilizadores();
    final mesas = await bd.listarMesas();
    
    int ocupadas = 0;
    for (var mesa in mesas) {
      if (mesa['estado'] == 'ocupada') ocupadas++;
    }

    if (mounted) {
      setState(() {
        _totalPratos = pratos.length;
        _totalUsers = utilizadores.length;
        _totalMesas = mesas.length;
        _mesasOcupadas = ocupadas;
      });
    }
  }

  Future<void> _importarEmenta() async {
    setState(() => _aCarregar = true);

    final servidor = Servidor();
    final sucesso = await servidor.carregarEmentaNaBD();

    await _atualizarDashboard();
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

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: iconColor),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF6B3F1F)),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 13, color: Colors.blueGrey, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B3F1F),
        foregroundColor: Colors.white,
        title: const Text('Mesa & Mesa — Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar Dados',
            onPressed: _atualizarDashboard,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFFEDE0D0),
                  child: Icon(Icons.manage_accounts, size: 30, color: Color(0xFF6B3F1F)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bem-vindo de volta,', style: TextStyle(color: Colors.blueGrey, fontSize: 14)),
                    Text(
                      user?['nome'] ?? 'Administrador',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6B3F1F)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            const Text('Visão Geral (Clique para Gerir)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6B3F1F))),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard('Gerir Mesas', '$_mesasOcupadas/$_totalMesas', Icons.room_service, Colors.red[400]!, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminGestaoMesas())).then((_) => _atualizarDashboard());
                }),
                _buildStatCard('Gerir Ementa', _totalPratos.toString(), Icons.restaurant_menu, Colors.orange[400]!, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminGestaoEmenta())).then((_) => _atualizarDashboard());
                }),
                _buildStatCard('Gerir Contas', _totalUsers.toString(), Icons.people, Colors.blue[400]!, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminGestaoContas())).then((_) => _atualizarDashboard());
                }),
                _buildStatCard('Status do Sistema', 'Online', Icons.cloud_done, Colors.green[400]!, null),
              ],
            ),
            const SizedBox(height: 40),

            const Text('Ações Rápidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6B3F1F))),
            const SizedBox(height: 16),
            if (_aCarregar)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF6B3F1F)),
                    SizedBox(height: 16),
                    Text('A sincronizar pratos da API...'),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _importarEmenta,
                  icon: const Icon(Icons.sync),
                  label: const Text('Sincronizar Ementa (API Externa)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B3F1F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
