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
      
      // Limpar ementa antiga
      await db.rawDelete('DELETE FROM pratos');
      
      int totalInseridos = 0;

      // 1. Fazer UM ÚNICO pedido para ir buscar TODOS os pratos 
      final response = await http.get(Uri.parse('$_baseUrl/all'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> todosPratosPorCategoria = json.decode(response.body);

        // 2. Filtrar categorias localmente ANTES de guardar
        // O JSON devolve um mapa onde a chave é o endpoint (ex: 'burgers')
        // e o valor é a lista de pratos
        for (final categoria in categorias) {
          final catEndpoint = categoria['endpoint']!;
          final label = categoria['label']!;
          
          if (todosPratosPorCategoria.containsKey(catEndpoint)) {
            final listaPratos = todosPratosPorCategoria[catEndpoint] as List;

            for (final prato in listaPratos) {
              final nome      = prato['name']  ?? 'Sem nome';
              final descricao = prato['dsc']   ?? '';
              double preco    = (prato['price'] as num?)?.toDouble() ?? 0.0;
              final imagem    = prato['img']   ?? '';

              if (preco > 40) preco = preco / 10;
              if (preco < 3) preco = 6.50;

              await bd.inserirPrato(nome, descricao, preco, label, imagem);
              totalInseridos++;
            }
          }
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