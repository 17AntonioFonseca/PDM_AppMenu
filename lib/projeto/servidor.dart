import 'dart:convert';
import 'package:http/http.dart' as http;
import 'basededados.dart';

// =====================================================
// SERVIDOR — Mesa & Mesa
// Comunicação com a API externa:
//   https://free-food-menus-api-two.vercel.app
// =====================================================

class Servidor {

  static const String _baseUrl = 'https://free-food-menus-api-two.vercel.app';

  // Categorias disponíveis na API
  static const List<Map<String, String>> categorias = [
    {'endpoint': 'burgers',       'label': 'Hambúrgueres'},
    {'endpoint': 'pizzas',        'label': 'Pizzas'},
    {'endpoint': 'steaks',        'label': 'Carnes'},
    {'endpoint': 'sandwiches',    'label': 'Sandes'},
    {'endpoint': 'desserts',      'label': 'Sobremesas'},
    {'endpoint': 'drinks',        'label': 'Bebidas'},
    {'endpoint': 'fried-chicken', 'label': 'Frango'},
  ];

  // =====================================================
  // BUSCAR PRATOS DE UMA CATEGORIA
  // =====================================================

  Future<List<Map<String, dynamic>>> buscarPratos(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$endpoint'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dados = json.decode(response.body);
        return dados.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // =====================================================
  // CARREGAR EMENTA DA API E GUARDAR NA BASE DE DADOS
  // Deve ser chamado uma vez pelo administrador
  // para popular a tabela de pratos
  // =====================================================

  Future<bool> carregarEmentaNaBD() async {
    try {
      final bd = Basededados();
      final db = await bd.database;
      
      // Limpar ementa antiga para evitar duplicados e aplicar novos preços
      await db.rawDelete('DELETE FROM pratos');
      
      int totalInseridos = 0;

      for (final categoria in categorias) {
        final endpoint = categoria['endpoint']!;
        final label    = categoria['label']!;

        final pratos = await buscarPratos(endpoint);

        for (final prato in pratos) {
          final nome      = prato['name']  ?? 'Sem nome';
          final descricao = prato['dsc']   ?? '';
          double preco    = (prato['price'] as num?)?.toDouble() ?? 0.0;
          final imagem    = prato['img']   ?? '';

          // --- TOQUE DE REALISMO NOS PREÇOS ---
          // Se o preço for > 40, provavelmente está em cêntimos ou é irrealista
          if (preco > 40) {
            preco = preco / 10;
          }
          // Garante um preço mínimo razoável
          if (preco < 3) {
            preco = 6.50;
          }

          await bd.inserirPrato(nome, descricao, preco, label, imagem);
          totalInseridos++;
        }
      }

      return totalInseridos > 0;
    } catch (e) {
      return false;
    }
  }

  // =====================================================
  // VERIFICAR SE A EMENTA JÁ FOI CARREGADA
  // =====================================================

  Future<bool> ementaCarregada() async {
    final db     = Basededados();
    final pratos = await db.listarPratos();
    return pratos.isNotEmpty;
  }
}