import 'package:flutter/material.dart';
import 'basededados.dart';

class EmpregadoScreen extends StatefulWidget {
  const EmpregadoScreen({super.key});

  @override
  State<EmpregadoScreen> createState() => _EmpregadoScreenState();
}

class _EmpregadoScreenState extends State<EmpregadoScreen> {
  List<Map<String, dynamic>> _mesas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarMesas();
  }

  Future<void> _carregarMesas() async {
    setState(() => _isLoading = true);
    final mesas = await Basededados().listarMesas();
    if (mounted) {
      setState(() {
        _mesas = mesas;
        _isLoading = false;
      });
    }
  }

  Future<void> _faturarMesa(int idMesa, int numeroMesa) async {
    final bd = Basededados();
    final db = await bd.database;
    
    // Quando a mesa paga, apagamos o histórico de pratos e pedidos
    // para que fique completamente limpa para os próximos clientes.
    await db.rawDelete('DELETE FROM pedido_pratos WHERE id_pedido IN (SELECT id FROM pedidos WHERE id_mesa = ?)', [idMesa]);
    await db.rawDelete('DELETE FROM pedidos WHERE id_mesa = ?', [idMesa]);
    
    // Libertar a mesa
    await bd.atualizarEstadoMesa(idMesa, 'livre');
    
    if (mounted) {
      Navigator.pop(context); // Fecha a janela da fatura
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mesa $numeroMesa faturada e libertada com sucesso!'), 
          backgroundColor: Colors.green[800],
        ),
      );
      _carregarMesas(); // Atualiza as cores na grelha
    }
  }

  void _abrirDetalhesMesa(Map<String, dynamic> mesa) {
    if (mesa['estado'] == 'livre') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta mesa está livre e não tem conta.'), duration: Duration(seconds: 1)),
      );
      return;
    }

    final idMesa = mesa['id'];
    final numeroMesa = mesa['numero'];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFFF5EFE6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fatura - Mesa $numeroMesa',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6B3F1F)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: Basededados().listarPedidosPorMesa(idMesa),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final pedidos = snapshot.data!;
                    
                    // Verifica se há pedidos que ainda não estão prontos ou entregues
                    bool temPedidosIncompletos = pedidos.any((p) => p['estado'] == 'pendente' || p['estado'] == 'preparacao');

                    return Column(
                      children: [
                        Expanded(
                          child: pedidos.isEmpty
                            ? const Center(child: Text('Nenhum pedido efetuado ainda.'))
                            : ListView.builder(
                                itemCount: pedidos.length,
                                itemBuilder: (context, index) {
                                  final pedido = pedidos[index];
                                  return Card(
                                    elevation: 0,
                                    color: Colors.white,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.receipt, color: Color(0xFF9C7B5E)),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Ronda de Pedido #${pedido['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                    Text('Estado na cozinha: ${pedido['estado']}', style: TextStyle(color: pedido['estado'] == 'pronto' ? Colors.green[700] : Colors.orange[800], fontWeight: FontWeight.w500)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(),
                                          FutureBuilder<List<Map<String, dynamic>>>(
                                            future: Basededados().listarPratosDoPedido(pedido['id']),
                                            builder: (context, pratosSnapshot) {
                                              if (!pratosSnapshot.hasData) {
                                                return const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                                              }
                                              final pratos = pratosSnapshot.data!;
                                              if (pratos.isEmpty) return const Text('Nenhum prato associado a este pedido.');
                                              
                                              return Column(
                                                children: pratos.map((prato) {
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Expanded(child: Text('${prato['quantidade']}x ${prato['nome']}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15))),
                                                        Text('${(prato['preco'] * prato['quantidade']).toStringAsFixed(2)}€', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                        ),
                        const Divider(thickness: 2),
                        FutureBuilder<double>(
                          future: Basededados().calcularTotalMesa(idMesa),
                          builder: (context, totalSnapshot) {
                            final totalGeral = totalSnapshot.data ?? 0.0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total a Faturar:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6B3F1F))),
                                  Text(
                                    '${totalGeral.toStringAsFixed(2)}€', 
                                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFFD4821A)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: temPedidosIncompletos ? null : () => _faturarMesa(idMesa, numeroMesa),
                            icon: const Icon(Icons.point_of_sale),
                            label: Text(
                              temPedidosIncompletos ? 'Aguardar pratos da cozinha' : 'Faturar e Libertar Mesa', 
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey[400],
                              disabledForegroundColor: Colors.grey[700],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B3F1F),
        foregroundColor: Colors.white,
        title: const Text('Mesa & Mesa — Sala de Jantar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar Sala',
            onPressed: _carregarMesas,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B3F1F)))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _mesas.length,
                itemBuilder: (context, index) {
                  final mesa = _mesas[index];
                  final isOcupada = mesa['estado'] == 'ocupada';
                  
                  return GestureDetector(
                    onTap: () => _abrirDetalhesMesa(mesa),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isOcupada ? const Color(0xFFD4821A) : Colors.green[600],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isOcupada ? Icons.people_alt : Icons.check_circle_outline,
                            size: 40,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'MESA ${mesa['numero']}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            isOcupada ? 'Ocupada' : 'Livre',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
