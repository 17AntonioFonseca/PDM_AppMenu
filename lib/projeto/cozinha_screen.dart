import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _pedidosSubscription;
  bool _snapshotInicialRecebido = false;

  @override
  void initState() {
    super.initState();
    _inicializarCozinha();
  }

  Future<void> _inicializarCozinha() async {
    setState(() => _isLoading = true);
    await _carregarPedidos(mostrarSpinner: false);
    _escutarNovosPedidos();
  }

  @override
  void dispose() {
    _pedidosSubscription?.cancel();
    super.dispose();
  }

  void _escutarNovosPedidos() {
    _pedidosSubscription = FirebaseFirestore.instance
        .collection('pedidos')
        .snapshots()
        .listen((snapshot) async {
          if (_snapshotInicialRecebido) {
            for (final change in snapshot.docChanges) {
              if (change.type != DocumentChangeType.added) continue;
              final pedido = change.doc.data();
              if (pedido == null || pedido['estado'] != 0) continue;

              final quantidade = pedido['quantidade'] ?? 1;
              final produto = pedido['produto'] ?? 'Produto';
              final mesa = pedido['mesa'] ?? '?';
              final dataIso =
                  pedido['data'] ?? DateTime.now().toIso8601String();
              final idMesa = int.tryParse(mesa) ?? 0;

              // Insere no SQLite para aparecer na lista
              if (idMesa > 0) {
                await Basededados().inserirPedidoDoFirestore(
                  idMesa: idMesa,
                  produto: produto,
                  quantidade: quantidade,
                  dataIso: dataIso,
                );
              }

              // SnackBar imediato
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'NOVO PEDIDO: ${quantidade}x $produto (Mesa $mesa)',
                    ),
                    backgroundColor: Colors.red[800],
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            }
          }

          _snapshotInicialRecebido = true;
          _carregarPedidos(mostrarSpinner: false);
        });
  }

  Future<void> _carregarPedidos({bool mostrarSpinner = false}) async {
    if (mostrarSpinner) {
      setState(() => _isLoading = true);
    }
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
    // 1. Atualizar no Firestore
    await Basededados().atualizarEstadoPedidoNoFirestore(idPedido, novoEstado);

    // 2. Atualizar no SQLite local
    await Basededados().atualizarEstadoPedido(idPedido, novoEstado);

    // 3. Recarregar lista local
    _carregarPedidos(mostrarSpinner: false);

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
              onPressed: () async {
                setState(() => _isLoading = true);
                await Basededados().sincronizarComFirestore();
                _carregarPedidos(mostrarSpinner: false);
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
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
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF6B3F1F)),
              )
            : TabBarView(
                children: [
                  _buildListaPedidos(
                    _pedidosPendentes,
                    'na fila',
                    'Aceitar Pedido',
                    'preparacao',
                    Colors.orange,
                  ),
                  _buildListaPedidos(
                    _pedidosPreparacao,
                    'a preparar',
                    'Marcar como Pronto',
                    'pronto',
                    Colors.blue,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildListaPedidos(
    List<Map<String, dynamic>> pedidos,
    String emptyMsg,
    String btnText,
    String nextState,
    Color badgeColor,
  ) {
    if (pedidos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Sem pedidos $emptyMsg.',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ExpansionTile(
            initiallyExpanded: true,
            leading: CircleAvatar(
              backgroundColor: badgeColor,
              child: Text(
                numMesa.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              'Mesa $numMesa - Pedido #$idPedido',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Recebido às $horaPedido'),
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: Basededados().listarPratosDoPedido(idPedido),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    );
                  }
                  final pratos = snapshot.data!;
                  return Column(
                    children: [
                      const Divider(height: 1),
                      ...pratos.map((prato) {
                        return ListTile(
                          dense: true,
                          title: Text(
                            prato['nome'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${prato['quantidade']}x',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _alterarEstado(idPedido, nextState),
                            icon: const Icon(Icons.check),
                            label: Text(
                              btnText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B3F1F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
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
