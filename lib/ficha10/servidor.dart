import 'dart:convert';
import 'package:http/http.dart' as http;
import 'basedados.dart';
import 'shapref.dart';

class Servidor {
  final String _baseUrl =
      'http://193.137.7.56:8000/produtos/api/produtos/?data_hora=';

  final Basedados _bd = Basedados();

  /// Sincroniza os dados da API para a base de dados local.
  /// Recebe a [dataHora] da última atualização (pode ser vazio "").
  Future<void> sincronizar(String dataHora) async {
    final url = Uri.parse('$_baseUrl$dataHora');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =
            jsonDecode(utf8.decode(response.bodyBytes));

        if (json['status'] == 'success') {
          // ── Produtos ──────────────────────────────────────
          final List<dynamic> produtos = json['produtos'] ?? [];
          for (final p in produtos) {
            await _bd.inserirOuAtualizarProduto({
              'id': p['id'],
              'nome': p['nome'],
              'preco': (p['preco'] as num).toDouble(),
              'foto': p['foto'] ?? '',
              'data_atualizacao': p['data_atualizacao'],
            });
          }

          // ── Clientes ──────────────────────────────────────
          final List<dynamic> clientes = json['clientes'] ?? [];
          for (final c in clientes) {
            await _bd.inserirOuAtualizarCliente({
              'id': c['id'],
              'nome': c['nome'],
              'email': c['email'],
              'telemovel': c['telemovel'],
              'morada': c['morada'],
              'data_atualizacao': c['data_atualizacao'],
            });
          }

          // Guarda a data/hora da sincronização atual
          final agora = DateTime.now().toIso8601String().replaceFirst('T', ' ').substring(0, 19);
          await ShaPref().setUltimaAtualizacao(agora);

          print('Sincronização concluída: ${produtos.length} produtos, ${clientes.length} clientes.');
        } else {
          print('API devolveu status: ${json['status']}');
        }
      } else {
        print('Erro HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Erro na sincronização: $e');
    }
  }
}