import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'basededados.dart';
import 'servidor.dart';

class ClienteScreen extends StatefulWidget {
  const ClienteScreen({super.key});

  @override
  State<ClienteScreen> createState() => _ClienteScreenState();
}

class _ClienteScreenState extends State<ClienteScreen> {
  String _categoriaSelecionada = 'Hambúrgueres';
  List<Map<String, dynamic>> _pratos = [];
  bool _aCarregar = true;
  final List<Map<String, dynamic>> _carrinho = [];

  @override
  void initState() {
    super.initState();
    _carregarPratos();
  }

  Future<void> _carregarPratos() async {
    setState(() => _aCarregar = true);
    final bd = Basededados();
    final lista = await bd.listarPratosPorCategoria(_categoriaSelecionada);
    setState(() {
      _pratos = lista;
      _aCarregar = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final idMesa = user?['id_mesa'] as int? ?? 0;
    final numeroMesa = idMesa > 0 ? idMesa.toString() : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B3F1F),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mesa & Mesa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Mesa $numeroMesa',
              style: const TextStyle(fontSize: 12, color: Color(0xFFD4821A)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => _mostrarEstadoPedidos(idMesa),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_basket_outlined),
                onPressed: () => _abrirCarrinho(idMesa),
              ),
              if (_carrinho.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_carrinho.length}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: Column(
        children: [
          // ------ BARRA DE CATEGORIAS ------
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: const Color(0xFF6B3F1F),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: Servidor.categorias.length,
              itemBuilder: (context, index) {
                final cat = Servidor.categorias[index];
                final selecionada = _categoriaSelecionada == cat['label'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ChoiceChip(
                    label: Text(cat['label']!),
                    selected: selecionada,
                    onSelected: (val) {
                      if (val) {
                        setState(() => _categoriaSelecionada = cat['label']!);
                        _carregarPratos();
                      }
                    },
                    selectedColor: const Color(0xFFD4821A),
                    backgroundColor: const Color(0xFF4E2E16),
                    labelStyle: TextStyle(
                      color: selecionada ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),

          // ------ LISTA DE PRATOS ------
          Expanded(
            child: _aCarregar
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6B3F1F)),
                  )
                : _pratos.isEmpty
                ? const Center(
                    child: Text('Nenhum prato encontrado nesta categoria.'),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: _pratos.length,
                    itemBuilder: (context, index) {
                      final prato = _pratos[index];
                      return _buildCardPrato(prato);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPrato(Map<String, dynamic> prato) {
    return GestureDetector(
      onTap: () => _mostrarDetalhesPrato(prato),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Image.network(
                  prato['imagem'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.fastfood, size: 40, color: Colors.grey),
                  ),
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prato['nome'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${prato['preco'].toStringAsFixed(2)}€',
                    style: const TextStyle(
                      color: Color(0xFFD4821A),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ver detalhes',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blueGrey,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalhesPrato(Map<String, dynamic> prato) {
    int quantidade = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFFF5EFE6),
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                children: [
                  // Imagem de destaque
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
                        child: Image.network(
                          prato['imagem'],
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(
                                height: 250,
                                child: Icon(Icons.fastfood, size: 100),
                              ),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        right: 20,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  prato['nome'],
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6B3F1F),
                                  ),
                                ),
                              ),
                              Text(
                                '${prato['preco'].toStringAsFixed(2)}€',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFD4821A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Descrição / Ingredientes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9C7B5E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            prato['descricao'],
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                          const Spacer(),

                          // Seletor de Quantidade
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _botaoQtd(Icons.remove, () {
                                if (quantidade > 1) {
                                  setModalState(() => quantidade--);
                                }
                              }),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Text(
                                  '$quantidade',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _botaoQtd(Icons.add, () {
                                setModalState(() => quantidade++);
                              }),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Botão de Confirmação
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  final index = _carrinho.indexWhere(
                                    (item) =>
                                        item['prato']['id'] == prato['id'],
                                  );
                                  if (index >= 0) {
                                    _carrinho[index]['quantidade'] +=
                                        quantidade;
                                  } else {
                                    _carrinho.add({
                                      'prato': prato,
                                      'quantidade': quantidade,
                                    });
                                  }
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Adicionado: $quantidade x ${prato['nome']}',
                                    ),
                                    backgroundColor: Colors.green[800],
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B3F1F),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                'Adicionar ao Pedido',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _botaoQtd(IconData icone, VoidCallback acao) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF6B3F1F)),
      ),
      child: IconButton(
        icon: Icon(icone, color: const Color(0xFF6B3F1F)),
        onPressed: acao,
      ),
    );
  }

  void _abrirCarrinho(int idMesa) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            double total = 0;
            for (var item in _carrinho) {
              total += item['prato']['preco'] * item['quantidade'];
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
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
                      const Text(
                        'O Seu Pedido',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B3F1F),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: _carrinho.isEmpty
                        ? const Center(
                            child: Text(
                              'O carrinho está vazio.',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _carrinho.length,
                            itemBuilder: (context, index) {
                              final item = _carrinho[index];
                              final prato = item['prato'];
                              final qtd = item['quantidade'];
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    prato['imagem'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) =>
                                        const Icon(Icons.fastfood),
                                  ),
                                ),
                                title: Text(
                                  prato['nome'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${prato['preco'].toStringAsFixed(2)}€ x $qtd',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setModalState(() {
                                      setState(() {
                                        _carrinho.removeAt(index);
                                      });
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${total.toStringAsFixed(2)}€',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFD4821A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _carrinho.isEmpty
                          ? null
                          : () => _finalizarPedido(idMesa),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B3F1F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Enviar para a Cozinha',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _finalizarPedido(int idMesa) async {
    Navigator.pop(context); // Fechar o modal do carrinho

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4821A)),
      ),
    );

    try {
      final bd = Basededados();
      final data = DateTime.now().toIso8601String();

      // Inserir Pedido principal
      final idPedido = await bd.inserirPedido(idMesa, 'pendente', data);

      // Inserir pratos do pedido
      for (var item in _carrinho) {
        await bd.inserirPratoPedido(
          idPedido,
          item['prato']['id'],
          item['quantidade'],
        );
      }

      final firestoreEnviado = await _enviarPedidoParaFirestore(idMesa);

      // Atualizar estado da mesa para 'ocupada'
      await bd.atualizarEstadoMesa(idMesa, 'ocupada');

      // Limpar carrinho e fechar loading
      setState(() {
        _carrinho.clear();
      });

      if (mounted) {
        Navigator.pop(context); // Tira o loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              firestoreEnviado
                  ? 'Pedido enviado com sucesso para a cozinha!'
                  : 'Pedido guardado, mas o Firestore nao aceitou a notificacao.',
            ),
            backgroundColor: firestoreEnviado ? Colors.green : Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Tira o loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao guardar pedido na base de dados local.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _enviarPedidoParaFirestore(int idMesa) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final pedidosRef = FirebaseFirestore.instance.collection('pedidos');

      for (var item in _carrinho) {
        final prato = item['prato'] as Map<String, dynamic>;
        final quantidade = item['quantidade'] as int;
        final docRef = pedidosRef.doc();

        batch.set(docRef, {
          'estado': 0,
          'mesa': idMesa.toString(),
          'preco': (prato['preco'] as num).toDouble(),
          'produto': prato['nome'].toString(),
          'quantidade': quantidade,
          'criadoEm': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      return true;
    } on FirebaseException catch (e) {
      debugPrint('Erro Firestore ao enviar pedido: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Erro inesperado ao enviar pedido para Firestore: $e');
      return false;
    }
  }

  void _mostrarEstadoPedidos(int idMesa) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
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
                  const Text(
                    'Estado dos Pedidos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B3F1F),
                    ),
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
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6B3F1F),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'Ainda não fez nenhum pedido.',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    final pedidos = snapshot.data!;
                    return ListView.builder(
                      itemCount: pedidos.length,
                      itemBuilder: (context, index) {
                        final pedido = pedidos[index];
                        final idPedido = pedido['id'];
                        final estado = pedido['estado'];

                        Color estadoColor;
                        String estadoTexto;
                        switch (estado) {
                          case 'pendente':
                            estadoColor = Colors.orange;
                            estadoTexto = 'Na Fila da Cozinha';
                            break;
                          case 'preparacao':
                            estadoColor = Colors.blue;
                            estadoTexto = 'A Preparar';
                            break;
                          case 'pronto':
                            estadoColor = Colors.green;
                            estadoTexto = 'Pronto a Servir';
                            break;
                          case 'entregue':
                            estadoColor = Colors.grey;
                            estadoTexto = 'Entregue';
                            break;
                          default:
                            estadoColor = Colors.black;
                            estadoTexto = estado.toString().toUpperCase();
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ExpansionTile(
                            title: Text(
                              'Pedido #$idPedido',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Estado: $estadoTexto',
                              style: TextStyle(
                                color: estadoColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            children: [
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: Basededados().listarPratosDoPedido(
                                  idPedido,
                                ),
                                builder: (context, pratosSnapshot) {
                                  if (!pratosSnapshot.hasData) {
                                    return const SizedBox();
                                  }

                                  final listaPratos = pratosSnapshot.data!;
                                  double totalPedido = 0;

                                  for (var prato in listaPratos) {
                                    totalPedido +=
                                        (prato['preco'] as num).toDouble() *
                                        (prato['quantidade'] as int);
                                  }

                                  return Column(
                                    children: [
                                      const Divider(height: 1),
                                      ...listaPratos.map((prato) {
                                        final preco = (prato['preco'] as num)
                                            .toDouble();
                                        final qtd = prato['quantidade'];
                                        final subtotal = preco * qtd;

                                        return ListTile(
                                          dense: true,
                                          title: Text(
                                            prato['nome'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '${preco.toStringAsFixed(2)}€ x $qtd',
                                          ),
                                          trailing: Text(
                                            '${subtotal.toStringAsFixed(2)}€',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      }),
                                      Container(
                                        color: const Color(0xFFF5EFE6),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 12.0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Total do Pedido:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              '${totalPedido.toStringAsFixed(2)}€',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                                color: Color(0xFF6B3F1F),
                                              ),
                                            ),
                                          ],
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
                  },
                ),
              ),
              const Divider(thickness: 2),
              FutureBuilder<double>(
                future: Basededados().calcularTotalMesa(idMesa),
                builder: (context, snapshot) {
                  final totalGeral = snapshot.data ?? 0.0;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total a Pagar:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B3F1F),
                          ),
                        ),
                        Text(
                          '${totalGeral.toStringAsFixed(2)}€',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFD4821A),
                          ),
                        ),
                      ],
                    ),
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
