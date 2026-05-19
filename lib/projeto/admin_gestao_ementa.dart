import 'package:flutter/material.dart';
import 'basededados.dart';

class AdminGestaoEmenta extends StatefulWidget {
  const AdminGestaoEmenta({super.key});

  @override
  State<AdminGestaoEmenta> createState() => _AdminGestaoEmentaState();
}

class _AdminGestaoEmentaState extends State<AdminGestaoEmenta> {
  List<Map<String, dynamic>> _pratos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    final pratos = await Basededados().listarPratos();
    if (mounted) {
      setState(() {
        _pratos = pratos;
        _isLoading = false;
      });
    }
  }

  void _abrirFormulario({Map<String, dynamic>? prato}) {
    final nomeController = TextEditingController(text: prato?['nome'] ?? '');
    final descController = TextEditingController(text: prato?['descricao'] ?? '');
    final precoController = TextEditingController(text: prato?['preco']?.toString() ?? '');
    final catController = TextEditingController(text: prato?['categoria'] ?? 'Geral');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF5EFE6),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24, right: 24, top: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(prato == null ? 'Adicionar Prato' : 'Editar Prato', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6B3F1F))),
              const SizedBox(height: 16),
              TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome do Prato')),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Descrição')),
              TextField(controller: precoController, decoration: const InputDecoration(labelText: 'Preço (€)'), keyboardType: TextInputType.number),
              TextField(controller: catController, decoration: const InputDecoration(labelText: 'Categoria (Ex: Entradas, Peixe)')),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final nome = nomeController.text;
                    final desc = descController.text;
                    final preco = double.tryParse(precoController.text.replaceAll(',', '.')) ?? 0.0;
                    final cat = catController.text;

                    if (prato == null) {
                      await Basededados().inserirPrato(nome, desc, preco, cat, '');
                    } else {
                      await Basededados().atualizarPrato(prato['id'], nome, desc, preco, cat, prato['imagem'] ?? '');
                    }
                    
                    if (mounted) Navigator.pop(context);
                    _carregarDados();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B3F1F), foregroundColor: Colors.white),
                  child: const Text('Guardar Alterações', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      }
    );
  }

  Future<void> _eliminarPrato(int id) async {
    await Basededados().eliminarPrato(id);
    _carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        title: const Text('Gestão de Ementa'),
        backgroundColor: const Color(0xFF6B3F1F),
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B3F1F)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _pratos.length,
            itemBuilder: (context, index) {
              final p = _pratos[index];
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  title: Text(p['nome'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${(p['preco'] as num).toStringAsFixed(2)}€ - ${p['categoria']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _abrirFormulario(prato: p)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _eliminarPrato(p['id'])),
                    ],
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD4821A),
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
