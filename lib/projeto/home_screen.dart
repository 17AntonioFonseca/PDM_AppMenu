import 'package:flutter/material.dart';

// =====================================================
// HOME SCREEN
// Ecrã inicial da app - aparece durante 3 segundos
// e depois navega para o Login
// =====================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)),
    );

    _slideAnim = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );

    _controller.forward();

    // Navega para o Login após 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A0A00), // castanho escuro quase preto
              Color(0xFF3D1A00), // castanho escuro
              Color(0xFF7A3200), // castanho médio
            ],
          ),
        ),
        child: Stack(
          children: [

            // Círculo decorativo fundo superior direito
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD4821A).withOpacity(0.08),
                ),
              ),
            ),

            // Círculo decorativo fundo inferior esquerdo
            Positioned(
              bottom: -60,
              left: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD4821A).withOpacity(0.06),
                ),
              ),
            ),

            // Conteúdo principal centrado
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        // Ícone / Logo
                        ScaleTransition(
                          scale: _scaleAnim,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFD4821A).withOpacity(0.15),
                              border: Border.all(
                                color: const Color(0xFFD4821A),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.restaurant,
                              size: 60,
                              color: Color(0xFFD4821A),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Nome da app
                        Transform.translate(
                          offset: Offset(0, _slideAnim.value),
                          child: const Text(
                            'MESA & MESA',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFF5E6C8),
                              letterSpacing: 6,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Subtítulo
                        Transform.translate(
                          offset: Offset(0, _slideAnim.value),
                          child: const Text(
                            'A experiência começa aqui',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFD4821A),
                              letterSpacing: 2,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                        const SizedBox(height: 60),

                        // Loading indicator
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            color: const Color(0xFFD4821A),
                            strokeWidth: 2,
                            backgroundColor: const Color(0xFFD4821A).withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Versão no fundo
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _fadeAnim,
                builder: (context, child) => FadeTransition(
                  opacity: _fadeAnim,
                  child: const Text(
                    'v1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF7A3200),
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}