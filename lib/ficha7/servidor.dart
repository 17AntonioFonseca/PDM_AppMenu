import 'dart:convert';
import 'package:http/http.dart' as http;
import 'basededados.dart';

class Servidor {
  final String url;
  bool _ativo = false;

  Servidor(this.url);

  // Descarrega produtos da API e insere na BD sem duplicados
  Future<void> listaProdutos() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> products = data['products'];
        final db = Basededados();
        for (var product in products) {
          String nome = product['title'];
          double preco = (product['price'] as num).toDouble();
          await db.inserirProdutoSeNaoExistir(nome, preco);
        }
      }
    } catch (e) {
      print('Erro no pedido: $e');
    }
  }

  // Corre listaProdutos() imediatamente e depois repete a cada [intervalo]
  Future<void> listaProdutosPeriodica(Duration intervalo) async {
    _ativo = true;
    while (_ativo) {
      await listaProdutos();
      await Future.delayed(intervalo);
    }
  }

  void pararSincronizacao() {
    _ativo = false;
  }
}