import 'package:flutter/material.dart';
import 'basededados.dart';

// =====================================================
// LOGIN SCREEN
// Ecrã de login para os 4 perfis:
//   - Cliente
//   - Empregado
//   - Cozinha
//   - Administrador
// =====================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // Controladores dos campos de texto
  late TextEditingController _utilizadorController;
  late TextEditingController _passwordController;

  // Perfil selecionado
  String _perfilSelecionado = 'Cliente';

  // Lista de perfis
  final List<Map<String, dynamic>> _perfis = [
    {'label': 'Cliente',        'icon': Icons.person_outline},
    {'label': 'Empregado',      'icon': Icons.room_service_outlined},
    {'label': 'Cozinha',        'icon': Icons.soup_kitchen_outlined},
    {'label': 'Administrador',  'icon': Icons.manage_accounts_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _utilizadorController = TextEditingController();
    _passwordController   = TextEditingController();
  }

  @override
  void dispose() {
    _utilizadorController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    final utilizador = _utilizadorController.text.trim();
    final password   = _passwordController.text.trim();

    if (utilizador.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor preenche todos os campos.'),
        ),
      );
      return;
    }

    // --- AUTENTICAÇÃO REAL COM A BASE DE DADOS ---
    final bd = Basededados();
    final user = await bd.autenticar(utilizador, password);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF8B1A1A),
          content: Text(
            'Utilizador ou password incorretos.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    // Verificar se o perfil selecionado no UI corresponde ao perfil na BD
    // (Por exemplo, se escolher "Admin" mas fizer login com conta de "Cliente")
    final perfilBD = user['perfil'].toString().toLowerCase();
    final perfilUI = _perfilSelecionado.toLowerCase();

    if (perfilBD != perfilUI) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange[800],
          content: Text(
            'Este utilizador não tem perfil de $_perfilSelecionado.',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    // Navegação baseada no perfil, passando os dados do utilizador
    switch (_perfilSelecionado) {
      case 'Cliente':
        Navigator.pushReplacementNamed(context, '/cliente', arguments: user);
        break;
      case 'Empregado':
        Navigator.pushReplacementNamed(context, '/empregado', arguments: user);
        break;
      case 'Cozinha':
        Navigator.pushReplacementNamed(context, '/cozinha', arguments: user);
        break;
      case 'Administrador':
        Navigator.pushReplacementNamed(context, '/admin', arguments: user);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 40),

              // ------ Cabeçalho ------
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.restaurant,
                      size: 64,
                      color: Color(0xFF6B3F1F),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Mesa & Mesa',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B3F1F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Bem-vindo! Faça o seu login.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9C7B5E),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ------ Seleção de perfil ------
              const Text(
                'Perfil',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B3F1F),
                ),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.4,
                children: _perfis.map((perfil) {
                  final bool selecionado = _perfilSelecionado == perfil['label'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _perfilSelecionado = perfil['label'];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: selecionado
                            ? const Color(0xFF6B3F1F)
                            : const Color(0xFFEDE0D0),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF6B3F1F),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            perfil['icon'] as IconData,
                            size: 18,
                            color: selecionado
                                ? Colors.white
                                : const Color(0xFF6B3F1F),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            perfil['label'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: selecionado
                                  ? Colors.white
                                  : const Color(0xFF6B3F1F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // ------ Campo Utilizador ------
              const Text(
                'Utilizador',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B3F1F),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _utilizadorController,
                keyboardType: TextInputType.text,
                autocorrect: false,
                enableSuggestions: false,
                enableInteractiveSelection: true,
                showCursor: true,
                style: const TextStyle(
                  color: Color(0xFF6B3F1F),
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Introduz o utilizador',
                  hintStyle: const TextStyle(color: Color(0xFF9C7B5E)),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF6B3F1F), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFBFA07A)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6B3F1F)),
                ),
              ),

              const SizedBox(height: 16),

              // ------ Campo Password ------
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B3F1F),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                style: const TextStyle(
                  color: Color(0xFF6B3F1F),
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Introduz a password',
                  hintStyle: const TextStyle(color: Color(0xFF9C7B5E)),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF6B3F1F), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFBFA07A)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B3F1F)),
                ),
              ),

              const SizedBox(height: 32),

              // ------ Botão Login ------
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _fazerLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B3F1F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Entrar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}