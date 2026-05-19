import 'package:flutter/material.dart';
import 'basededados.dart';

class AdminGestaoContas extends StatefulWidget {
  const AdminGestaoContas({super.key});

  @override
  State<AdminGestaoContas> createState() => _AdminGestaoContasState();
}

class _AdminGestaoContasState extends State<AdminGestaoContas> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    final users = await Basededados().listarUtilizadores();
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  void _abrirFormulario({Map<String, dynamic>? user}) async {
    final bd = Basededados();
    final mesasExistentes = await bd.listarMesas();
    final todosUsers = await bd.listarUtilizadores();

    // Encontrar mesas que já têm conta (exceto a própria mesa que estamos a editar)
    List<int> mesasComConta = todosUsers
        .where((u) => u['id_mesa'] != null && u['id'] != user?['id'])
        .map((u) => u['id_mesa'] as int)
        .toList();

    // Lista de mesas livres para associar a uma nova conta
    final mesasDisponiveis = mesasExistentes.where((m) => !mesasComConta.contains(m['id'])).toList();

    final nomeController = TextEditingController(text: user?['nome'] ?? '');
    final userController = TextEditingController(text: user?['username'] ?? '');
    final passController = TextEditingController(text: user?['password'] ?? '');
    
    String perfilSelecionado = user?['perfil'] ?? 'mesa';
    if (perfilSelecionado == 'cliente') perfilSelecionado = 'mesa'; // Ajuste automático

    int? selectedIdMesa = user?['id_mesa'];

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF5EFE6),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24, right: 24, top: 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user == null ? 'Nova Conta' : 'Editar Conta', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6B3F1F))),
                  const SizedBox(height: 16),
                  TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome (Ex: Tablet da Mesa 2)')),
                  TextField(controller: userController, decoration: const InputDecoration(labelText: 'Username (Ex: mesa2)')),
                  TextField(controller: passController, decoration: const InputDecoration(labelText: 'Password')),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: perfilSelecionado,
                    decoration: const InputDecoration(labelText: 'Perfil de Acesso'),
                    items: const [
                      DropdownMenuItem(value: 'mesa', child: Text('Mesa')),
                      DropdownMenuItem(value: 'empregado', child: Text('Empregado de Sala')),
                      DropdownMenuItem(value: 'cozinha', child: Text('Cozinha')),
                      DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          perfilSelecionado = val;
                          if (perfilSelecionado != 'mesa') {
                            selectedIdMesa = null; // Limpar a mesa associada
                          }
                        });
                      }
                    },
                  ),
                  
                  if (perfilSelecionado == 'mesa') ...[
                    const SizedBox(height: 16),
                    mesasDisponiveis.isEmpty && selectedIdMesa == null
                        ? const Text('⚠️ Não há mesas disponíveis. Tem de criar uma nova mesa primeiro no Gestor de Mesas.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                        : DropdownButtonFormField<int>(
                            value: selectedIdMesa,
                            decoration: const InputDecoration(labelText: 'Associar à Mesa Nº'),
                            items: mesasDisponiveis.map((m) {
                              return DropdownMenuItem<int>(
                                value: m['id'],
                                child: Text('Mesa ${m['numero']}'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setModalState(() {
                                selectedIdMesa = val;
                              });
                            },
                          ),
                  ],
                  
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final nome = nomeController.text.trim();
                        final username = userController.text.trim();
                        final pass = passController.text.trim();

                        if (nome.isEmpty || username.isEmpty || pass.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha todos os campos obrigatórios.')));
                          return;
                        }

                        if (perfilSelecionado == 'mesa' && selectedIdMesa == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tem de selecionar uma mesa para esta conta.')));
                          return;
                        }

                        if (user == null) {
                          await bd.inserirUtilizador(nome, username, pass, perfilSelecionado, idMesa: selectedIdMesa);
                        } else {
                          await bd.atualizarUtilizador(user['id'], nome, username, pass, perfilSelecionado, idMesa: selectedIdMesa);
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
    );
  }

  Future<void> _eliminarConta(int id) async {
    await Basededados().eliminarUtilizador(id);
    _carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        title: const Text('Gestão de Contas'),
        backgroundColor: const Color(0xFF6B3F1F),
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B3F1F)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final u = _users[index];
              final isMesa = u['perfil'] == 'mesa' || u['perfil'] == 'cliente';
              
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFEDE0D0),
                    child: Text(u['perfil'][0].toUpperCase(), style: const TextStyle(color: Color(0xFF6B3F1F), fontWeight: FontWeight.bold)),
                  ),
                  title: Text(u['nome'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(isMesa ? '@${u['username']} - Perfil Mesa' : '@${u['username']} - ${u['perfil']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _abrirFormulario(user: u)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _eliminarConta(u['id'])),
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
