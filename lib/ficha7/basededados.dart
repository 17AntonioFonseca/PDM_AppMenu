import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Basededados {
  static final Basededados _instance = Basededados._internal();
  static Database? _database;

  factory Basededados() {
    return _instance;
  }

  Basededados._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bdpdm7.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE produtos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        preco REAL
      )
    ''');
  }

  // Insere só se não existir produto com o mesmo nome e preço
  Future<int> inserirProdutoSeNaoExistir(String nome, double preco) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT id FROM produtos WHERE nome = ? AND preco = ?',
      [nome, preco],
    );
    if (result.isNotEmpty) {
      return 0; // já existe, não insere
    }
    return await db.rawInsert(
      'INSERT INTO produtos(nome, preco) VALUES(?, ?)',
      [nome, preco],
    );
  }

  // Mantido da Ficha 6 para compatibilidade
  Future<int> inserirProduto(String nome, double preco, [Database? db]) async {
    final databaseToUse = db ?? await database;
    return await databaseToUse.rawInsert(
      'INSERT INTO produtos(nome, preco) VALUES(?, ?)',
      [nome, preco],
    );
  }

  Future<List<Map<String, dynamic>>> listarProdutos() async {
    final db = await database;
    return await db.rawQuery('SELECT nome, preco FROM produtos ORDER BY nome');
  }

  Future<int> contarProdutos() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM produtos',
    );
    if (result.isNotEmpty && result.first['count'] != null) {
      return result.first['count'] as int;
    }
    return 0;
  }
}