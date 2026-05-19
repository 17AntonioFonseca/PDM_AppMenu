import 'package:flutter/material.dart';
import 'basededados.dart';

class AdminGestaoMesas extends StatefulWidget {
  const AdminGestaoMesas({super.key});

  @override
  State<AdminGestaoMesas> createState() => _AdminGestaoMesasState();
}

class _AdminGestaoMesasState extends State<AdminGestaoMesas> {
  List<Map<String, dynamic>> _mesas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    final mesas = await Basededados().listarMesas();
    if (mounted) {
      setState(() {
        _mesas = mesas;
        _isLoading = false;
      });
    }
  }

  void _abrirFormulario({Map<String, dynamic>? mesa}) {
    final numeroController = TextEditingController(text: mesa?['numero']?.toString() ?? '');

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
              Text(mesa == null ? 'Adicionar Mesa' : 'Editar Mesa', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6B3F1F))),
              const SizedBox(height: 16),
              TextField(controller: numeroController, decoration: const InputDecoration(labelText: 'Número da Mesa'), keyboardType: TextInputType.number),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final numero = int.tryParse(numeroController.text) ?? 0;

                    if (mesa == null) {
                      await Basededados().inserirMesa(numero);
                    } else {
                      // Note: Our DB doesn't have atualizarMesa, but typically we only update the state.
                      // Since we want to update the number, we would need to run a raw update.
                      final db = await Basededados().database;
                      await db.rawUpdate('UPDATE mesas SET numero = ? WHERE id = ?', [numero, mesa['id']]);
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

  Future<void> _eliminarMesa(int id) async {
    await Basededados().eliminarMesa(id);
    _carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        title: const Text('Gestão de Mesas'),
        backgroundColor: const Color(0xFF6B3F1F),
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B3F1F)))
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _mesas.length,
            itemBuilder: (context, index) {
              final m = _mesas[index];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('MESA ${m['numero']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6B3F1F))),
                    Text(m['estado'], style: TextStyle(color: m['estado'] == 'livre' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _abrirFormulario(mesa: m)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _eliminarMesa(m['id'])),
                      ],
                    ),
                  ],
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
