import 'package:shared_preferences/shared_preferences.dart';

class ShaPref {
  static const String _chave = 'ultimaatualizacao';

  /// Devolve a data/hora da última atualização.
  /// Se ainda não existir, devolve uma string vazia "".
  Future<String> getUltimaAtualizacao() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chave) ?? '';
  }

  /// Guarda a data/hora da última atualização.
  Future<void> setUltimaAtualizacao(String dataHora) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chave, dataHora);
  }

  /// Remove a variável de última atualização (reset).
  Future<void> limparUltimaAtualizacao() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chave);
  }
}