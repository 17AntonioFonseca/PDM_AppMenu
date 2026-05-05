import 'package:flutter/material.dart';
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
    final user = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final numeroMesa = user?['id_mesa'] ?? '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B3F1F),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mesa & Mesa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Mesa $numeroMesa', style: const TextStyle(fontSize: 12, color: Color(0xFFD4821A))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_basket_outlined),
            onPressed: () {
              // TODO: Abrir resumo do pedido
            },
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
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B3F1F)))
                : _pratos.isEmpty
                    ? const Center(child: Text('Nenhum prato encontrado nesta categoria.'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  prato['imagem'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.fastfood, size: 40, color: Colors.grey)),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                    style: TextStyle(fontSize: 11, color: Colors.blueGrey, decoration: TextDecoration.underline),
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
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                        child: Image.network(
                          prato['imagem'],
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(height: 250, child: Icon(Icons.fastfood, size: 100)),
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
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6B3F1F)),
                                ),
                              ),
                              Text(
                                '${prato['preco'].toStringAsFixed(2)}€',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFD4821A)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Descrição / Ingredientes',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9C7B5E)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            prato['descricao'],
                            style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                          ),
                          const Spacer(),
                          
                          // Seletor de Quantidade
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _botaoQtd(Icons.remove, () {
                                if (quantidade > 1) setModalState(() => quantidade--);
                              }),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Text('$quantidade', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Adicionado: $quantidade x ${prato['nome']}')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B3F1F),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Text('Adicionar ao Pedido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
}
