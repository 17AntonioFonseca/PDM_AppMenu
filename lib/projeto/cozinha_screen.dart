import 'package:flutter/material.dart';
import 'basededados.dart';

class CozinhaScreen extends StatefulWidget {
  const CozinhaScreen({super.key});

  @override
  State<CozinhaScreen> createState() => _CozinhaScreenState();
}

class _CozinhaScreenState extends State<CozinhaScreen> {
  List<Map<String, dynamic>> _pedidosPendentes = [];
  List<Map<String, dynamic>> _pedidosPreparacao = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarPedidos();
  }

  Future<void> _carregarPedidos() async {
    setState(() => _isLoading = true);
    final bd = Basededados();
    final pendentes = await bd.listarPedidosPorEstado('pendente');
    final preparacao = await bd.listarPedidosPorEstado('preparacao');

    if (mounted) {
      setState(() {
        _pedidosPendentes = pendentes;
        _pedidosPreparacao = preparacao;
        _isLoading = false;
      });
    }
  }

  Future<void> _alterarEstado(int idPedido, String novoEstado) async {
    await Basededados().atualizarEstadoPedido(idPedido, novoEstado);
    _carregarPedidos(); // Recarregar a lista
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pedido #$idPedido movido para: $novoEstado'),
          backgroundColor: Colors.green[800],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5EFE6),
        appBar: AppBar(
          backgroundColor: const Color(0xFF6B3F1F),
          foregroundColor: Colors.white,
          title: const Text('Mesa & Mesa — Cozinha'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Atualizar',
              onPressed: _carregarPedidos,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFFD4821A),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(icon: Icon(Icons.receipt_long), text: 'Na Fila'),
              Tab(icon: Icon(Icons.soup_kitchen), text: 'A Preparar'),
            ],
          ),
        ),
        body: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B3F1F)))
            : TabBarView(
                children: [
                  _buildListaPedidos(_pedidosPendentes, 'na fila', 'Aceitar Pedido', 'preparacao', Colors.orange),
                  _buildListaPedidos(_pedidosPreparacao, 'a preparar', 'Marcar como Pronto', 'pronto', Colors.blue),
                ],
              ),
      ),
    );
  }

  Widget _buildListaPedidos(List<Map<String, dynamic>> pedidos, String emptyMsg, String btnText, String nextState, Color badgeColor) {
    if (pedidos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Sem pedidos $emptyMsg.', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pedidos.length,
      itemBuilder: (context, index) {
        final pedido = pedidos[index];
        final idPedido = pedido['id'];
        final numMesa = pedido['numero_mesa'];
        
        // Extrair a hora da data ISO (ex: 2026-05-17T15:09:57 -> 15:09)
        String horaPedido = '?';
        if (pedido['data'] != null && pedido['data'].toString().length >= 16) {
          horaPedido = pedido['data'].toString().substring(11, 16);
        }

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ExpansionTile(
            initiallyExpanded: true,
            leading: CircleAvatar(
              backgroundColor: badgeColor,
              child: Text(numMesa.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text('Mesa $numMesa - Pedido #$idPedido', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Recebido às $horaPedido'),
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: Basededados().listarPratosDoPedido(idPedido),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator());
                  final pratos = snapshot.data!;
                  return Column(
                    children: [
                      const Divider(height: 1),
                      ...pratos.map((prato) {
                        return ListTile(
                          dense: true,
                          title: Text(prato['nome'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${prato['quantidade']}x', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        );
                      }),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton.icon(
                            onPressed: () => _alterarEstado(idPedido, nextState),
                            icon: const Icon(Icons.check),
                            label: Text(btnText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B3F1F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
