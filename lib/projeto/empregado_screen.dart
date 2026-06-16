import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'basededados.dart';
import 'connectivity_indicator.dart';

class EmpregadoScreen extends StatefulWidget {
  const EmpregadoScreen({super.key});

  @override
  State<EmpregadoScreen> createState() => _EmpregadoScreenState();
}

class _EmpregadoScreenState extends State<EmpregadoScreen> {
  List<Map<String, dynamic>> _mesas = [];
  bool _isLoading = true;

  // IDs de mesas com pelo menos um pedido no estado 'pronto' (para badge de alerta)
  final Set<int> _mesasComPedidoPronto = {};

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _pedidosSubscription;
  bool _snapshotInicialRecebido = false;

  @override
  void initState() {
    super.initState();
    _inicializarEmpregado();
  }

  Future<void> _inicializarEmpregado() async {
    await _carregarMesas(mostrarSpinner: true);
    _escutarAlteracoesPedidos();
  }

  @override
  void dispose() {
    _pedidosSubscription?.cancel();
    super.dispose();
  }

  void _escutarAlteracoesPedidos() {
    _pedidosSubscription = FirebaseFirestore.instance
        .collection('pedidos')
        .snapshots()
        .listen((snapshot) async {
          await Basededados().sincronizarComFirestore();
          
          if (!_snapshotInicialRecebido) {
            _snapshotInicialRecebido = true;
            _carregarMesas(mostrarSpinner: false);
            return;
          }

          for (final change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.modified) {
              final data = change.doc.data();
              if (data != null && data['estado'] == 2) {
                final String produto = data['produto'] ?? 'Produto';
                final String mesa = data['mesa'] ?? '?';
                final int quantidade = data['quantidade'] ?? 1;

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '🍽️ PEDIDO PRONTO: Mesa $mesa — ${quantidade}x $produto está pronto para entregar!',
                      ),
                      backgroundColor: Colors.green[800],
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              }
            }
          }

          _carregarMesas(mostrarSpinner: false);
        });
  }

  Future<void> _carregarMesas({bool mostrarSpinner = true}) async {
    if (mostrarSpinner) {
      setState(() => _isLoading = true);
    }
    await Basededados().sincronizarComFirestore();
    final mesas = await Basededados().listarMesas();

    // Calcular quais as mesas com pelo menos um pedido 'pronto'
    final Set<int> prontas = {};
    for (final mesa in mesas) {
      if (mesa['estado'] == 'ocupada') {
        final pedidos = await Basededados().listarPedidosPorMesa(mesa['id'] as int);
        if (pedidos.any((p) => p['estado'] == 'pronto')) {
          prontas.add(mesa['id'] as int);
        }
      }
    }

    if (mounted) {
      setState(() {
        _mesas = mesas;
        _mesasComPedidoPronto
          ..clear()
          ..addAll(prontas);
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmarEntregaMesa(int idMesa, int idPedido) async {
    final bd = Basededados();
    // 1. Atualizar estado no Firestore para 'entregue' (3)
    await bd.atualizarEstadoPedidoNoFirestore(idPedido, 'entregue');
    // 2. Atualizar estado localmente
    await bd.atualizarEstadoPedido(idPedido, 'entregue');
    // 3. Recarregar para remover badge
    await _carregarMesas(mostrarSpinner: false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Pedido #$idPedido marcado como entregue!'),
          backgroundColor: Colors.teal[700],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _faturarMesa(int idMesa, int numeroMesa) async {
    final bd = Basededados();
    
    // 1. Elimina os pedidos da mesa no Firestore
    await bd.faturarMesaNoFirestore(idMesa);
    
    // 2. Sincroniza com o Firestore para atualizar a BD local SQLite
    await bd.sincronizarComFirestore();
    
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
                    // Pedidos prontos para entregar (mas ainda não entregues)
                    final pedidosProntos = pedidos.where((p) => p['estado'] == 'pronto').toList();

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
                                                    Text(
                                                      pedido['estado'] == 'entregue'
                                                        ? 'Entregue ✅'
                                                        : pedido['estado'] == 'pronto'
                                                          ? 'Pronto para entregar 🔔'
                                                          : 'Em preparação…',
                                                      style: TextStyle(
                                                        color: pedido['estado'] == 'entregue'
                                                          ? Colors.teal[700]
                                                          : pedido['estado'] == 'pronto'
                                                            ? Colors.green[700]
                                                            : Colors.orange[800],
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
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
                        // Botões de "Confirmar Entrega" para pedidos prontos
                        if (pedidosProntos.isNotEmpty) ...
                          pedidosProntos.map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: () => _confirmarEntregaMesa(idMesa, p['id'] as int),
                                icon: const Icon(Icons.delivery_dining),
                                label: Text(
                                  'Confirmar Entrega do Pedido #${p['id']}',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal[700],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          )),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: (temPedidosIncompletos || pedidosProntos.isNotEmpty) ? null : () => _faturarMesa(idMesa, numeroMesa),
                            icon: const Icon(Icons.point_of_sale),
                            label: Text(
                              temPedidosIncompletos
                                ? 'Aguardar pratos da cozinha'
                                : pedidosProntos.isNotEmpty
                                  ? 'Confirme as entregas primeiro'
                                  : 'Faturar e Libertar Mesa',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
          const ConnectivityIndicator(),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar Sala',
            onPressed: () => _carregarMesas(),
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
                  childAspectRatio: 0.95,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _mesas.length,
                itemBuilder: (context, index) {
                  final mesa = _mesas[index];
                  final isOcupada = mesa['estado'] == 'ocupada';
                  final temPedidoPronto = _mesasComPedidoPronto.contains(mesa['id'] as int);

                  // Cor: verde normal = livre, laranja = ocupada, verde-esmeralda = pronto a entregar
                  final Color corCard = temPedidoPronto
                      ? Colors.teal[600]!
                      : isOcupada
                          ? const Color(0xFFD4821A)
                          : Colors.green[600]!;

                  return GestureDetector(
                    onTap: () => _abrirDetalhesMesa(mesa),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: corCard,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                temPedidoPronto
                                    ? Icons.delivery_dining
                                    : isOcupada
                                        ? Icons.people_alt
                                        : Icons.check_circle_outline,
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
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  temPedidoPronto
                                      ? 'Pronto a entregar!'
                                      : isOcupada
                                          ? 'Ocupada'
                                          : 'Livre',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Badge de alerta no canto superior direito
                        if (temPedidoPronto)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red[600],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_active,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
